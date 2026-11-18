package main

import (
	"context"
	"database/sql"
	"errors"
	"strings"
	"time"

	_ "github.com/jackc/pgx/v5/stdlib"
)

func openDB(ctx context.Context, dsn string) (*sql.DB, error) {
	if strings.TrimSpace(dsn) == "" {
		return nil, errors.New("DB_DSN is required; set it before starting the API")
	}
	db, err := sql.Open("pgx", dsn)
	if err != nil {
		// Driver errors may include the connection string, including its password.
		return nil, errors.New("invalid DB_DSN; check the PostgreSQL connection settings")
	}
	db.SetMaxOpenConns(10)
	db.SetMaxIdleConns(5)
	db.SetConnMaxIdleTime(5 * time.Minute)

	ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()
	if err := db.PingContext(ctx); err != nil {
		db.Close()
		return nil, errors.New("cannot connect to PostgreSQL; check the service, host, port, database and credentials")
	}
	return db, nil
}
