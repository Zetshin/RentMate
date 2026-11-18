package main

import (
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestAuthRateLimit(t *testing.T) {
	limiter := authRateLimiter()
	handler := limiter(func(w http.ResponseWriter, r *http.Request) { w.WriteHeader(204) })
	for i := 0; i < 11; i++ {
		request := httptest.NewRequest("POST", "/sessions", nil)
		request.RemoteAddr = "127.0.0.1:12345"
		request.Header.Set("X-Forwarded-For", "different-address")
		response := httptest.NewRecorder()
		handler.ServeHTTP(response, request)
		want := 204
		if i == 10 {
			want = 429
		}
		if response.Code != want {
			t.Fatalf("attempt %d got %d", i, response.Code)
		}
		if i == 10 && response.Header().Get("Retry-After") == "" {
			t.Fatal("missing retry header")
		}
	}
	request := httptest.NewRequest("POST", "/sessions", nil)
	request.RemoteAddr = "127.0.0.2:12345"
	response := httptest.NewRecorder()
	handler.ServeHTTP(response, request)
	if response.Code != 204 {
		t.Fatal("different client was blocked")
	}
}
