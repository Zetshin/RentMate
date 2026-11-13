package main

import (
	"encoding/json"
	"net/http"
)

// health reports that the API process can handle requests, not database readiness.
func (app *application) health(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	if err := json.NewEncoder(w).Encode(map[string]string{"status": "ok"}); err != nil {
		return
	}
}
