package main

import (
	"context"
	"errors"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/Zetshin/RentMate/backend/internal/models"
)

// application groups the dependencies used by this API's handlers.
type application struct {
	users    models.UserModel
	sessions models.SessionModel
}

func main() {
	if err := run(); err != nil {
		log.Fatal(err)
	}
}

func run() error {
	db, err := openDB(context.Background(), os.Getenv("DB_DSN"))
	if err != nil {
		return err
	}
	defer db.Close()
	log.Print("Connected to PostgreSQL")

	app := &application{
		users:    models.UserModel{DB: db},
		sessions: models.SessionModel{DB: db},
	}
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
		return err
	}
	return nil
}
