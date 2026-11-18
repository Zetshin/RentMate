package session

import (
	"bytes"
	"strings"
	"testing"
)

func TestToken(t *testing.T) {
	token, hash, err := NewToken()
	if err != nil {
		t.Fatal(err)
	}
	got, err := TokenHash(token)
	if err != nil || !bytes.Equal(hash, got) {
		t.Fatal("token hash does not match")
	}
	other, _, err := NewToken()
	if err != nil || token == other {
		t.Fatal("tokens not unique")
	}
	for _, invalid := range []string{"", "abc", strings.Repeat("!", 43)} {
		if _, err := TokenHash(invalid); err == nil {
			t.Fatal("accepted invalid token")
		}
	}
}
