package main

import (
	"context"
	"strings"
	"testing"
)

func TestOpenDBRejectsMissingDSN(t *testing.T) {
	for _, dsn := range []string{"", "   "} {
		db, err := openDB(context.Background(), dsn)
		if db != nil || err == nil {
			t.Fatal("expected missing configuration error")
		}
	}
}

func TestOpenDBDoesNotExposeCredentials(t *testing.T) {
	const secret = "private-test-password"
	db, err := openDB(context.Background(), "postgres://user:"+secret+"@localhost:invalid/rentmate")
	if db != nil || err == nil {
		t.Fatal("expected invalid configuration error")
	}
	if strings.Contains(err.Error(), secret) {
		t.Fatal("error exposes password")
	}
}

func TestOpenDBCancelledConnection(t *testing.T) {
	ctx, cancel := context.WithCancel(context.Background())
	cancel()
	db, err := openDB(ctx, "host=127.0.0.1 port=5432 user=rentmate_app password=test-only dbname=rentmate sslmode=disable")
	if db != nil || err == nil {
		t.Fatal("cancelled connection should fail")
	}
}
