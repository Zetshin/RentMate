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
	"github.com/Zetshin/RentMate/backend/internal/validator"
)

func (app *application) registerUser(w http.ResponseWriter, r *http.Request) {
	mediaType, _, err := mime.ParseMediaType(r.Header.Get("Content-Type"))
	if err != nil || mediaType != "application/json" {
		writeJSON(w, http.StatusUnsupportedMediaType, map[string]string{"error": "Content-Type must be application/json"})
		return
	}
	var input struct {
		Username        string `json:"username"`
		Password        string `json:"password"`
		ConfirmPassword string `json:"confirm_password"`
	}
	r.Body = http.MaxBytesReader(w, r.Body, 16*1024)
	decoder := json.NewDecoder(r.Body)
	decoder.DisallowUnknownFields()
	err = decoder.Decode(&input)
	if err == nil {
		// Accept exactly one JSON value, not multiple concatenated objects.
		var extra any
		if nextErr := decoder.Decode(&extra); !errors.Is(nextErr, io.EOF) {
			err = errors.New("request must contain one JSON object")
			var tooLarge *http.MaxBytesError
			if errors.As(nextErr, &tooLarge) {
				err = nextErr
			}
		}
	}
	if err != nil {
		status := http.StatusBadRequest
		var tooLarge *http.MaxBytesError
		if errors.As(err, &tooLarge) {
			status = http.StatusRequestEntityTooLarge
		}
		writeJSON(w, status, map[string]string{"error": "invalid or oversized JSON request"})
		return
	}

	fields := make(map[string]string)
	if err := validator.ValidateUsername(input.Username); err != nil {
		fields["username"] = err.Error()
	}
	if err := validator.ValidatePassword(input.Password); err != nil {
		fields["password"] = err.Error()
	}
	if input.Password != input.ConfirmPassword {
		fields["confirm_password"] = "passwords must match"
	}
	if len(fields) != 0 {
		writeJSON(w, http.StatusUnprocessableEntity, map[string]any{"errors": fields})
		return
	}

	hash, err := password.Hash(input.Password)
	if err != nil {
		writeJSON(w, http.StatusInternalServerError, map[string]string{"error": "unable to create account"})
		return
	}
	user := models.User{Username: strings.ToLower(input.Username), PasswordHash: hash}
	if err := app.users.Insert(r.Context(), &user); err != nil {
		if errors.Is(err, models.ErrDuplicateUsername) {
			writeJSON(w, http.StatusUnprocessableEntity, map[string]any{"errors": map[string]string{"username": "username already exists"}})
			return
		}
		// Do not expose database errors or the submitted credentials.
		writeJSON(w, http.StatusInternalServerError, map[string]string{"error": "unable to create account"})
		return
	}
	// Explicit response fields prevent credentials from leaking into the response.
	writeJSON(w, http.StatusCreated, map[string]any{"user": struct {
		ID        int64     `json:"id"`
		Username  string    `json:"username"`
		CreatedAt time.Time `json:"created_at"`
	}{user.ID, user.Username, user.CreatedAt}})
}
