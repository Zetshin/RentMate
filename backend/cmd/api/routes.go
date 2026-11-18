package main

import (
	"net/http"
)

func (app *application) routes() http.Handler {
	mux := http.NewServeMux()
	limitAuth := authRateLimiter()
	mux.HandleFunc("GET /health", app.health)
	mux.HandleFunc("POST /users", limitAuth(app.registerUser))
	mux.HandleFunc("POST /sessions", limitAuth(app.loginUser))
	mux.HandleFunc("GET /users/me", app.currentUser)
	mux.HandleFunc("DELETE /sessions/current", app.logoutUser)
	return mux
}
