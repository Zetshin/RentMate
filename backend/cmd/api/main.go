package main

import (
	"errors"
	"log"
	"net/http"
	"time"
)

// application groups the dependencies used by this API's handlers.
type application struct{}

func main() {
	app := &application{}
	server := &http.Server{
		Addr:              "127.0.0.1:8080",
		Handler:           app.routes(),
		ReadHeaderTimeout: 5 * time.Second,
		ReadTimeout:       10 * time.Second,
		WriteTimeout:      10 * time.Second,
		IdleTimeout:       60 * time.Second,
	}

	log.Printf("RentMate API listening on http://%s", server.Addr)
	if err := server.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
		log.Fatal(err)
	}
}
