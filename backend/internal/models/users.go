package models

import (
	"context"
	"database/sql"
	"errors"
	"time"
)

var (
	ErrRecordNotFound    = errors.New("record not found")
	ErrDuplicateUsername = errors.New("username already exists")
)

type User struct {
	ID           int64
	Username     string
	PasswordHash string `json:"-"`
	CreatedAt    time.Time
}

type UserModel struct {
	DB *sql.DB
}

// Insert stores a validated, normalized username and an already hashed password.
func (m UserModel) Insert(ctx context.Context, user *User) error {
	ctx, cancel := context.WithTimeout(ctx, 3*time.Second)
	defer cancel()
	var id int64
	var createdAt time.Time
	err := m.DB.QueryRowContext(ctx, `
		INSERT INTO users (username, password_hash)
		VALUES ($1, $2)
		RETURNING id, created_at`, user.Username, user.PasswordHash).Scan(&id, &createdAt)
	if err != nil {
		// PostgreSQL drivers expose SQLSTATE; do not match human-readable errors.
		var state interface{ SQLState() string }
		if errors.As(err, &state) && state.SQLState() == "23505" {
			return ErrDuplicateUsername
		}
		return err
	}
	user.ID, user.CreatedAt = id, createdAt
	return nil
}

func (m UserModel) Get(ctx context.Context, id int64) (*User, error) {
	if id < 1 {
		return nil, ErrRecordNotFound
	}
	return m.get(ctx, `SELECT id, username, password_hash, created_at FROM users WHERE id = $1`, id)
}

func (m UserModel) GetByUsername(ctx context.Context, username string) (*User, error) {
	return m.get(ctx, `SELECT id, username, password_hash, created_at FROM users WHERE username = $1`, username)
}

func (m UserModel) get(ctx context.Context, query string, arg any) (*User, error) {
	ctx, cancel := context.WithTimeout(ctx, 3*time.Second)
	defer cancel()
	var user User
	err := m.DB.QueryRowContext(ctx, query, arg).Scan(&user.ID, &user.Username, &user.PasswordHash, &user.CreatedAt)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, ErrRecordNotFound
	}
	if err != nil {
		return nil, err
	}
	return &user, nil
}

// UpdatePassword changes only the stored hash; authorization belongs in the handler.
func (m UserModel) UpdatePassword(ctx context.Context, id int64, passwordHash string) error {
	if id < 1 {
		return ErrRecordNotFound
	}
	return m.execExisting(ctx, `UPDATE users SET password_hash = $1 WHERE id = $2`, passwordHash, id)
}

// Delete is a hard delete. Future tenancy foreign keys must protect rental history.
func (m UserModel) Delete(ctx context.Context, id int64) error {
	if id < 1 {
		return ErrRecordNotFound
	}
	return m.execExisting(ctx, `DELETE FROM users WHERE id = $1`, id)
}

func (m UserModel) execExisting(ctx context.Context, query string, args ...any) error {
	ctx, cancel := context.WithTimeout(ctx, 3*time.Second)
	defer cancel()
	result, err := m.DB.ExecContext(ctx, query, args...)
	if err != nil {
		return err
	}
	count, err := result.RowsAffected()
	if err != nil {
		return err
	}
	if count == 0 {
		return ErrRecordNotFound
	}
	return nil
}
