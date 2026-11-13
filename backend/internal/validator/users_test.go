package validator

import (
	"strings"
	"testing"
)

func TestValidateUsername(t *testing.T) {
	for _, tc := range []struct {
		value string
		valid bool
	}{
		{"Art", true}, {"art", true}, {"", false}, {"art1", false}, {"art name", false}, {"ชื่อ", false},
	} {
		if got := ValidateUsername(tc.value) == nil; got != tc.valid {
			t.Fatalf("username %q valid=%v", tc.value, got)
		}
	}
}

func TestValidatePassword(t *testing.T) {
	for _, tc := range []struct {
		value string
		valid bool
	}{
		{"password", true}, {"short", false}, {strings.Repeat("a", 72), true},
		{strings.Repeat("a", 73), false}, {strings.Repeat("ก", 8), true}, {"invalid\xff", false},
	} {
		if got := ValidatePassword(tc.value) == nil; got != tc.valid {
			t.Fatalf("password case valid=%v want=%v", got, tc.valid)
		}
	}
}
