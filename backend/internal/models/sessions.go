package models

import (
	"context"
	"database/sql"
	"errors"
	"time"
)

type SessionModel struct{ DB *sql.DB }

func (m SessionModel) Insert(ctx context.Context, tokenHash []byte, userID int64, expiresAt time.Time) error {
	ctx, cancel := context.WithTimeout(ctx, 3*time.Second)
	defer cancel()
	_, err := m.DB.ExecContext(ctx,
		"INSERT INTO sessions (token_hash, user_id, expires_at) VALUES ($1, $2, $3)",
		tokenHash, userID, expiresAt)
	return err
}

func (m SessionModel) GetUser(ctx context.Context, tokenHash []byte) (*User, error) {
	ctx, cancel := context.WithTimeout(ctx, 3*time.Second)
	defer cancel()
	var user User
	err := m.DB.QueryRowContext(ctx, `
  SELECT users.id, users.username, users.created_at
  FROM sessions JOIN users ON users.id = sessions.user_id
  WHERE sessions.token_hash = $1 AND sessions.expires_at > CURRENT_TIMESTAMP`,
		tokenHash).Scan(&user.ID, &user.Username, &user.CreatedAt)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, ErrRecordNotFound
	}
	if err != nil {
		return nil, err
	}
	return &user, nil
}

func (m SessionModel) Delete(ctx context.Context, tokenHash []byte) error {
	ctx, cancel := context.WithTimeout(ctx, 3*time.Second)
	defer cancel()
	_, err := m.DB.ExecContext(ctx, "DELETE FROM sessions WHERE token_hash = $1", tokenHash)
	return err
}
