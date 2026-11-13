package password

import (
	"strings"
	"testing"
)

func TestHashAndMatches(t *testing.T) {
	hash, err := Hash("correct password")
	if err != nil {
		t.Fatal(err)
	}
	if hash == "correct password" {
		t.Fatal("stored plaintext")
	}
	for _, tc := range []struct {
		value string
		want  bool
	}{
		{"correct password", true}, {"wrong password", false}, {strings.Repeat("a", 73), false},
	} {
		got, err := Matches(hash, tc.value)
		if err != nil || got != tc.want {
			t.Fatalf("matches=%v err=%v", got, err)
		}
	}
	if _, err := Hash(strings.Repeat("a", 73)); err == nil {
		t.Fatal("accepted overlong password")
	}
	if _, err := Matches("malformed hash", "password"); err == nil {
		t.Fatal("ignored malformed hash")
	}
}
