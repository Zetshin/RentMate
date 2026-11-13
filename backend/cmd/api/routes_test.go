package main

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestHealth(t *testing.T) {
	request := httptest.NewRequest(http.MethodGet, "/health", nil)
	response := httptest.NewRecorder()
	app := &application{}
	app.routes().ServeHTTP(response, request)
	if response.Code != http.StatusOK {
		t.Fatalf("status = %d; want 200", response.Code)
	}
	var body map[string]string
	if err := json.Unmarshal(response.Body.Bytes(), &body); err != nil {
		t.Fatal(err)
	}
	if body["status"] != "ok" {
		t.Fatalf("body = %v; want status ok", body)
	}
}

func TestRoutesRejectUnknownPathAndMethod(t *testing.T) {
	for _, test := range []struct {
		method string
		path   string
		want   int
	}{
		{http.MethodPost, "/health", http.StatusMethodNotAllowed},
		{http.MethodGet, "/missing", http.StatusNotFound},
	} {
		response := httptest.NewRecorder()
		app := &application{}
		app.routes().ServeHTTP(response, httptest.NewRequest(test.method, test.path, nil))
		if response.Code != test.want {
			t.Errorf("%s %s = %d; want %d", test.method, test.path, response.Code, test.want)
		}
	}
}
