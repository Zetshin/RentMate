package main

import (
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
	"golang.org/x/crypto/bcrypt"
)

type passwordHashArgument struct{ plaintext string }

func (a passwordHashArgument) Match(value driver.Value) bool {
	hash, ok := value.(string)
	return ok && bcrypt.CompareHashAndPassword([]byte(hash), []byte(a.plaintext)) == nil
}

type registrationDuplicateError struct{}

func (registrationDuplicateError) Error() string    { return "duplicate username" }
func (registrationDuplicateError) SQLState() string { return "23505" }

func TestRegisterUserDatabaseResults(t *testing.T) {
	for _, tc := range []struct {
		name   string
		dbErr  error
		status int
	}{
		{"created", nil, http.StatusCreated},
		{"duplicate", registrationDuplicateError{}, http.StatusUnprocessableEntity},
		{"database failure", errors.New("internal database detail"), http.StatusInternalServerError},
	} {
		t.Run(tc.name, func(t *testing.T) {
			db, mock, err := sqlmock.New()
			if err != nil {
				t.Fatal(err)
			}
			defer db.Close()
			createdAt := time.Date(2026, 11, 16, 12, 0, 0, 0, time.UTC)
			query := mock.ExpectQuery("INSERT INTO users").WithArgs("art", passwordHashArgument{"correct-password"})
			if tc.dbErr != nil {
				query.WillReturnError(tc.dbErr)
			} else {
				query.WillReturnRows(sqlmock.NewRows([]string{"id", "created_at"}).AddRow(7, createdAt))
			}
			app := &application{users: models.UserModel{DB: db}}
			request := httptest.NewRequest(http.MethodPost, "/users", strings.NewReader(
				`{"username":"Art","password":"correct-password","confirm_password":"correct-password"}`))
			request.Header.Set("Content-Type", "application/json")
			response := httptest.NewRecorder()
			app.routes().ServeHTTP(response, request)
			if response.Code != tc.status {
				t.Fatalf("status=%d body=%s", response.Code, response.Body.String())
			}
			body := response.Body.String()
			for _, secret := range []string{"correct-password", "password_hash", "internal database detail", "$2"} {
				if strings.Contains(body, secret) {
					t.Fatalf("response exposes private data: %s", body)
				}
			}
			if tc.status == http.StatusCreated {
				var result struct {
					User struct {
						ID        int64
						Username  string
						CreatedAt time.Time `json:"created_at"`
					}
				}
				if err := json.Unmarshal(response.Body.Bytes(), &result); err != nil {
					t.Fatal(err)
				}
				if result.User.ID != 7 || result.User.Username != "art" || !result.User.CreatedAt.Equal(createdAt) {
					t.Fatalf("unexpected user: %+v", result.User)
				}
			}
			if err := mock.ExpectationsWereMet(); err != nil {
				t.Fatal(err)
			}
		})
	}
}

func TestRegisterUserRejectsInvalidRequests(t *testing.T) {
	for _, tc := range []struct {
		name, body, contentType string
		status                  int
	}{
		{"content type", "{}", "text/plain", 415},
		{"malformed", "{", "application/json", 400},
		{"multiple objects", "{} {}", "application/json", 400},
		{"unknown role", `{"username":"art","password":"password","confirm_password":"password","role":"admin"}`, "application/json", 400},
		{"wrong field type", `{"username":42}`, "application/json", 400},
		{"missing fields", "{}", "application/json", 422},
		{"invalid username", `{"username":"art1","password":"password","confirm_password":"password"}`, "application/json", 422},
		{"short password", `{"username":"art","password":"short","confirm_password":"short"}`, "application/json", 422},
		{"mismatch", `{"username":"art","password":"password","confirm_password":"different"}`, "application/json", 422},
		{"overlong password", `{"username":"art","password":"` + strings.Repeat("a", 73) + `"}`, "application/json", 422},
		{"oversized", `{"username":"` + strings.Repeat("a", 17000) + `"}`, "application/json", 413},
	} {
		t.Run(tc.name, func(t *testing.T) {
			// A nil model connection ensures rejected input never reaches the database.
			app := &application{}
			request := httptest.NewRequest(http.MethodPost, "/users", strings.NewReader(tc.body))
			request.Header.Set("Content-Type", tc.contentType)
			response := httptest.NewRecorder()
			app.routes().ServeHTTP(response, request)
			if response.Code != tc.status {
				t.Fatalf("status=%d want=%d body=%s", response.Code, tc.status, response.Body.String())
			}
		})
	}
}
