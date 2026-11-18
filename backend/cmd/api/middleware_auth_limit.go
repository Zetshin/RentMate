package main

import (
	"net"
	"net/http"
	"strconv"
	"sync"
	"time"
)

type authAttempt struct {
	count int
	reset time.Time
}

// authRateLimiter is process-local. It trusts RemoteAddr, not client-supplied
// forwarded headers. Proxy and multi-instance deployments need separate setup.
func authRateLimiter() func(http.HandlerFunc) http.HandlerFunc {
	var mu sync.Mutex
	attempts := make(map[string]authAttempt)
	return func(next http.HandlerFunc) http.HandlerFunc {
		return func(w http.ResponseWriter, r *http.Request) {
			host, _, err := net.SplitHostPort(r.RemoteAddr)
			if err != nil {
				host = r.RemoteAddr
			}
			now := time.Now()
			mu.Lock()
			for key, attempt := range attempts {
				if !now.Before(attempt.reset) {
					delete(attempts, key)
				}
			}
			attempt, exists := attempts[host]
			if !exists && len(attempts) >= 4096 {
				mu.Unlock()
				w.Header().Set("Retry-After", "60")
				writeJSON(w, 429, map[string]string{"error": "too many authentication attempts"})
				return
			}
			if !exists {
				attempt.reset = now.Add(time.Minute)
			}
			if attempt.count >= 10 {
				retry := int(time.Until(attempt.reset).Seconds()) + 1
				mu.Unlock()
				w.Header().Set("Retry-After", strconv.Itoa(retry))
				writeJSON(w, 429, map[string]string{"error": "too many authentication attempts"})
				return
			}
			attempt.count++
			attempts[host] = attempt
			mu.Unlock()
			next(w, r)
		}
	}
}
