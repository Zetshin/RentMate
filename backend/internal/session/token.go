// Package session generates bearer tokens. Database storage belongs in models.
package session

import (
	"crypto/rand"
	"crypto/sha256"
	"encoding/base64"
	"errors"
)

var ErrInvalidToken = errors.New("invalid session token")

func NewToken() (string, []byte, error) {
	raw := make([]byte, 32)
	if _, err := rand.Read(raw); err != nil {
		return "", nil, err
	}
	token := base64.RawURLEncoding.EncodeToString(raw)
	hash := sha256.Sum256([]byte(token))
	return token, hash[:], nil
}

func TokenHash(token string) ([]byte, error) {
	if len(token) != 43 {
		return nil, ErrInvalidToken
	}
	raw, err := base64.RawURLEncoding.Strict().DecodeString(token)
	if err != nil || len(raw) != 32 {
		return nil, ErrInvalidToken
	}
	hash := sha256.Sum256([]byte(token))
	return hash[:], nil
}
