// Package password hashes and compares passwords. Input policy belongs in validator.
package password

import (
	"errors"

	"golang.org/x/crypto/bcrypt"
)

   func Hash(plaintext string) (string, error) {
	hash, err := bcrypt.GenerateFromPassword([]byte(plaintext), bcrypt.DefaultCost)
	if err != nil {
		return "", err
	}
	return string(hash), nil
}

func Matches(hash, plaintext string) (bool, error) {
	if len(plaintext) > 72 {
		return false, nil
	}
	err := bcrypt.CompareHashAndPassword([]byte(hash), []byte(plaintext))
	if errors.Is(err, bcrypt.ErrMismatchedHashAndPassword) {
		return false, nil
	}
	return err == nil, err
}
