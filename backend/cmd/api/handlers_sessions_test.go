package main

import (
	"bytes"
	"database/sql"
	"database/sql/driver"
	"encoding/json"
	"errors"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"github.com/DATA-DOG/go-sqlmock"
	"github.com/Zetshin/RentMate/backend/internal/models"
	"github.com/Zetshin/RentMate/backend/internal/session"
	"golang.org/x/crypto/bcrypt"
)

func TestLogin(t *testing.T) {
	hash, err := bcrypt.GenerateFromPassword([]byte("password"), bcrypt.DefaultCost)
	if err != nil {
		t.Fatal(err)
	}
	for _, tc := range []struct {
		name                   string
		missing, wrong, broken bool
		status                 int
	}{
		{"success", false, false, false, 201}, {"wrong password", false, true, false, 401},
		{"unknown user", true, false, false, 401}, {"database down", false, false, true, 500},
	} {
		t.Run(tc.name, func(t *testing.T) {
			db, mock, err := sqlmock.New()
			if err != nil {
				t.Fatal(err)
			}
			defer db.Close()
			query := mock.ExpectQuery("SELECT .* WHERE username").WithArgs("art")
			if tc.broken {
				query.WillReturnError(errors.New("private database error"))
			} else if tc.missing {
				query.WillReturnError(sql.ErrNoRows)
			} else {
				query.WillReturnRows(sqlmock.NewRows([]string{"id", "username", "password_hash", "created_at"}).AddRow(7, "art", string(hash), time.Now()))
			}
			if tc.status == 201 {
				mock.ExpectExec("INSERT INTO sessions").WithArgs(sqlmock.AnyArg(), int64(7), sqlmock.AnyArg()).WillReturnResult(sqlmock.NewResult(0, 1))
			}
			plaintext := "password"
			if tc.wrong {
				plaintext = "incorrect"
			}
			request := httptest.NewRequest("POST", "/sessions", strings.NewReader(`{"username":"ART","password":"`+plaintext+`"}`))
			request.Header.Set("Content-Type", "application/json")
			response := httptest.NewRecorder()
			app := &application{users: models.UserModel{DB: db}, sessions: models.SessionModel{DB: db}}
			app.routes().ServeHTTP(response, request)
			if response.Code != tc.status {
				t.Fatalf("status %d: %s", response.Code, response.Body.String())
			}
			if response.Header().Get("Cache-Control") != "no-store" {
				t.Fatal("session response can be cached")
			}
			if strings.Contains(response.Body.String(), string(hash)) || strings.Contains(response.Body.String(), "private database error") {
				t.Fatal("response exposed internal data")
			}
			if tc.status == 201 {
				var result struct {
					Token     string
					ExpiresAt time.Time `json:"expires_at"`
				}
				if err := json.Unmarshal(response.Body.Bytes(), &result); err != nil {
					t.Fatal(err)
				}
				if _, err := session.TokenHash(result.Token); err != nil {
					t.Fatal(err)
				}
				if !result.ExpiresAt.After(time.Now()) {
					t.Fatal("expired token")
				}
			}
			if err := mock.ExpectationsWereMet(); err != nil {
				t.Fatal(err)
			}
		})
	}
}

type tokenHashArgument struct{ want []byte }

func (a tokenHashArgument) Match(value driver.Value) bool {
	got, ok := value.([]byte)
	return ok && bytes.Equal(got, a.want)
}

func TestSessionAccessAndLogout(t *testing.T) {
	token, hash, err := session.NewToken()
	if err != nil {
		t.Fatal(err)
	}
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close()
	app := &application{sessions: models.SessionModel{DB: db}}
	router := app.routes()
	call := func(method, path, authorization string) *httptest.ResponseRecorder {
		request := httptest.NewRequest(method, path, nil)
		if authorization != "" {
			request.Header.Set("Authorization", authorization)
		}
		response := httptest.NewRecorder()
		router.ServeHTTP(response, request)
		return response
	}
	if got := call("GET", "/users/me", "").Code; got != 401 {
		t.Fatal(got)
	}
	mock.ExpectQuery("SELECT users.id").WithArgs(tokenHashArgument{hash}).WillReturnRows(
		sqlmock.NewRows([]string{"id", "username", "created_at"}).AddRow(7, "art", time.Now()))
	if response := call("GET", "/users/me", "Bearer "+token); response.Code != 200 {
		t.Fatal(response.Body.String())
	}
	mock.ExpectExec("DELETE FROM sessions").WithArgs(tokenHashArgument{hash}).WillReturnResult(sqlmock.NewResult(0, 1))
	if got := call("DELETE", "/sessions/current", "Bearer "+token).Code; got != 204 {
		t.Fatal(got)
	}
	// Expired and revoked sessions both fail the active-session lookup.
	mock.ExpectQuery("SELECT users.id").WithArgs(tokenHashArgument{hash}).WillReturnError(sql.ErrNoRows)
	if got := call("GET", "/users/me", "Bearer "+token).Code; got != 401 {
		t.Fatal(got)
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Fatal(err)
	}
}

func TestLoginBadInput(t *testing.T) {
	for _, tc := range []struct {
		body   string
		status int
	}{
		{"{", 400}, {"{} {}", 400}, {`{"role":"owner"}`, 400},
		{`{"username":"art","password":""}`, 401},
	} {
		request := httptest.NewRequest(http.MethodPost, "/sessions", strings.NewReader(tc.body))
		request.Header.Set("Content-Type", "application/json")
		response := httptest.NewRecorder()
		(&application{}).routes().ServeHTTP(response, request)
		if response.Code != tc.status {
			t.Fatalf("status=%d", response.Code)
		}
	}
}
