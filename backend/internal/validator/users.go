package validator

import (
	"errors"
	"unicode/utf8"
)

var (
	ErrInvalidUsername = errors.New("username must contain only English letters")
	ErrInvalidPassword = errors.New("password must have at least 8 characters and at most 72 bytes")
)

func ValidateUsername(username string) error {
	if username == "" {
		return ErrInvalidUsername
	}
	for _, ch := range username {
		if !(ch >= 'a' && ch <= 'z' || ch >= 'A' && ch <= 'Z') {
			return ErrInvalidUsername
		}
	}
	return nil
}

// ValidatePassword checks new passwords, not credentials during login.
func ValidatePassword(password string) error {
	if !utf8.ValidString(password) || utf8.RuneCountInString(password) < 8 || len(password) > 72 {
		return ErrInvalidPassword
	}
	return nil
}
