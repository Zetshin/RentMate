package main

import (
	"encoding/json"
	"errors"
	"io"
	"mime"
	"net/http"
	"strings"
	"time"

	"github.com/Zetshin/RentMate/backend/internal/models"
	"github.com/Zetshin/RentMate/backend/internal/password"
	"github.com/Zetshin/RentMate/backend/internal/session"
	"github.com/Zetshin/RentMate/backend/internal/validator"
)

// A valid bcrypt hash at the same cost as Hash() makes unknown-user checks
// perform password comparison too. This value is not a real account credential.
const dummyPasswordHash = "$2a$10$7EqJtq98hPqEX7fNZaFWoO5h8paD9NW9d.C0qQjZgGqYy6vFj9kIW"

func (app *application) loginUser(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Cache-Control", "no-store")
	var input struct {
		Username string `json:"username"`
		Password string `json:"password"`
	}
	if !readAuthJSON(w, r, &input) {
		return
	}
	if validator.ValidateUsername(input.Username) != nil || input.Password == "" || len(input.Password) > 72 {
		invalidCredentials(w)
		return
	}
	user, err := app.users.GetByUsername(r.Context(), strings.ToLower(input.Username))
	if err != nil && !errors.Is(err, models.ErrRecordNotFound) {
		writeJSON(w, 500, map[string]string{"error": "unable to log in"})
		return
	}
	hash := dummyPasswordHash
	if user != nil {
		hash = user.PasswordHash
	}
	matches, err := password.Matches(hash, input.Password)
	if err != nil {
		writeJSON(w, 500, map[string]string{"error": "unable to log in"})
		return
	}
	if user == nil || !matches {
		invalidCredentials(w)
		return
	}
	token, tokenHash, err := session.NewToken()
	if err != nil {
		writeJSON(w, 500, map[string]string{"error": "unable to create session"})
		return
	}
	expiresAt := time.Now().UTC().Add(24 * time.Hour)
	if err := app.sessions.Insert(r.Context(), tokenHash, user.ID, expiresAt); err != nil {
		writeJSON(w, 500, map[string]string{"error": "unable to create session"})
		return
	}
	writeJSON(w, http.StatusCreated, map[string]any{
		"token": token, "token_type": "Bearer", "expires_at": expiresAt,
	})
}

func invalidCredentials(w http.ResponseWriter) {
	writeJSON(w, http.StatusUnauthorized, map[string]string{"error": "invalid username or password"})
}

func readAuthJSON(w http.ResponseWriter, r *http.Request, input any) bool {
	mediaType, _, err := mime.ParseMediaType(r.Header.Get("Content-Type"))
	if err != nil || mediaType != "application/json" {
		writeJSON(w, 415, map[string]string{"error": "Content-Type must be application/json"})
		return false
	}
	r.Body = http.MaxBytesReader(w, r.Body, 16*1024)
	decoder := json.NewDecoder(r.Body)
	decoder.DisallowUnknownFields()
	err = decoder.Decode(input)
	if err == nil {
		var extra any
		err = decoder.Decode(&extra)
		if errors.Is(err, io.EOF) {
			return true
		}
	}
	var tooLarge *http.MaxBytesError
	status := http.StatusBadRequest
	if errors.As(err, &tooLarge) {
		status = http.StatusRequestEntityTooLarge
	}
	writeJSON(w, status, map[string]string{"error": "invalid or oversized JSON request"})
	return false
}

func bearerHash(r *http.Request) ([]byte, error) {
	headers := r.Header.Values("Authorization")
	if len(headers) != 1 {
		return nil, session.ErrInvalidToken
	}
	parts := strings.Fields(headers[0])
	if len(parts) != 2 || !strings.EqualFold(parts[0], "Bearer") {
		return nil, session.ErrInvalidToken
	}
	return session.TokenHash(parts[1])
}

func (app *application) currentUser(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Cache-Control", "no-store")
	hash, err := bearerHash(r)
	if err != nil {
		w.Header().Set("WWW-Authenticate", "Bearer")
		writeJSON(w, 401, map[string]string{"error": "invalid or expired session"})
		return
	}
	user, err := app.sessions.GetUser(r.Context(), hash)
	if errors.Is(err, models.ErrRecordNotFound) {
		w.Header().Set("WWW-Authenticate", "Bearer")
		writeJSON(w, 401, map[string]string{"error": "invalid or expired session"})
		return
	}
	if err != nil {
		writeJSON(w, 500, map[string]string{"error": "unable to read account"})
		return
	}
	writeJSON(w, 200, map[string]any{"user": struct {
		ID        int64     `json:"id"`
		Username  string    `json:"username"`
		CreatedAt time.Time `json:"created_at"`
	}{user.ID, user.Username, user.CreatedAt}})
}

func (app *application) logoutUser(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Cache-Control", "no-store")
	hash, err := bearerHash(r)
	if err != nil {
		writeJSON(w, 401, map[string]string{"error": "invalid session"})
		return
	}
	if err := app.sessions.Delete(r.Context(), hash); err != nil {
		writeJSON(w, 500, map[string]string{"error": "unable to log out"})
		return
	}
	w.WriteHeader(http.StatusNoContent)
}
