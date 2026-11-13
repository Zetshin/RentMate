package models

import (
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"strings"
	"testing"
	"time"

	"github.com/DATA-DOG/go-sqlmock"
)

func TestUserJSONHidesHash(t *testing.T) {
	user := User{PasswordHash: "secret-hash"}
	data, err := json.Marshal(user)
	if err != nil {
		t.Fatal(err)
	}
	if strings.Contains(string(data), user.PasswordHash) {
		t.Fatal("JSON exposes password hash")
	}
}

type uniqueViolation struct{}

func (uniqueViolation) Error() string    { return "unique violation" }
func (uniqueViolation) SQLState() string { return "23505" }

func TestInsert(t *testing.T) {
	for _, duplicate := range []bool{false, true} {
		name := "success"
		if duplicate {
			name = "duplicate"
		}
		t.Run(name, func(t *testing.T) {
			db, mock, err := sqlmock.New()
			if err != nil {
				t.Fatal(err)
			}
			defer db.Close()
			user := User{Username: "art", PasswordHash: "prepared-hash"}
			expect := mock.ExpectQuery("INSERT INTO users").WithArgs("art", "prepared-hash")
			created := time.Now()
			if duplicate {
				expect.WillReturnError(uniqueViolation{})
			} else {
				expect.WillReturnRows(sqlmock.NewRows([]string{"id", "created_at"}).AddRow(7, created))
			}
			err = (UserModel{DB: db}).Insert(context.Background(), &user)
			if duplicate {
				if !errors.Is(err, ErrDuplicateUsername) || user.ID != 0 {
					t.Fatalf("id=%d err=%v", user.ID, err)
				}
			} else if err != nil || user.ID != 7 || user.Username != "art" || !user.CreatedAt.Equal(created) {
				t.Fatalf("id=%d err=%v", user.ID, err)
			}
			if err := mock.ExpectationsWereMet(); err != nil {
				t.Fatal(err)
			}
		})
	}
}

func TestLookupAndDelete(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close()
	m := UserModel{DB: db}
	ctx := context.Background()
	mock.ExpectQuery("SELECT .* WHERE username").WithArgs("art").WillReturnRows(
		sqlmock.NewRows([]string{"id", "username", "password_hash", "created_at"}).AddRow(7, "art", "hash", time.Now()))
	user, err := m.GetByUsername(ctx, "art")
	if err != nil || user.ID != 7 {
		t.Fatalf("lookup err=%v", err)
	}
	mock.ExpectQuery("SELECT .* WHERE id").WithArgs(int64(99)).WillReturnError(sql.ErrNoRows)
	if _, err := m.Get(ctx, 99); !errors.Is(err, ErrRecordNotFound) {
		t.Fatal(err)
	}
	for _, count := range []int64{1, 0} {
		mock.ExpectExec("DELETE FROM users").WithArgs(int64(7)).WillReturnResult(sqlmock.NewResult(0, count))
		err := m.Delete(ctx, 7)
		if count == 1 && err != nil || count == 0 && !errors.Is(err, ErrRecordNotFound) {
			t.Fatal(err)
		}
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Fatal(err)
	}
}

func TestUpdatePassword(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close()
	m := UserModel{DB: db}
	mock.ExpectExec("UPDATE users SET password_hash").WithArgs("prepared-hash", int64(7)).WillReturnResult(sqlmock.NewResult(0, 1))
	if err := m.UpdatePassword(context.Background(), 7, "prepared-hash"); err != nil {
		t.Fatal(err)
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Fatal(err)
	}
}
