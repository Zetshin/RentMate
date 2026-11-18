# RentMate API

## Run locally

PostgreSQL must be running and the rentmate database and rentmate_app role must already exist.
Set DB_DSN in the same PowerShell terminal before starting the API:

```powershell
cd backend
$env:DB_DSN = 'host=127.0.0.1 port=5432 user=rentmate_app password=YOUR_PASSWORD dbname=rentmate sslmode=disable timezone=UTC'
go run ./cmd/api
```

Replace YOUR_PASSWORD locally. Do not commit or share the real connection string.
This version reads environment variables only; it does not automatically load a .env file.
The sslmode=disable example is for PostgreSQL on your own computer only.
For remote databases use the TLS settings required by the database provider.

The API checks the connection before starting. Success prints Connected to PostgreSQL,
then listens at http://127.0.0.1:8080.
GET /health returns {"status":"ok"}; it checks the API process, not ongoing database readiness.

Stop with Ctrl+C. To remove the variable from this terminal:

```powershell
Remove-Item Env:DB_DSN
```

## Database permissions

Creating a role and granting schema USAGE does not grant table access.
As postgres, in the rentmate database, run after creating public.users:

```sql
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.users TO rentmate_app;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO rentmate_app;
```

Migration files are not executed automatically. Run the initial migration only if users
does not already exist. This setup does not modify existing database records.

## Checks

```powershell
go test ./...
go vet ./...
```

Model SQL tests use a mock database; they do not establish a real PostgreSQL connection.

## Structure

- cmd/api/main.go: startup, application dependencies and HTTP server.
- cmd/api/database.go: PostgreSQL connection pool and startup ping.
- cmd/api/routes.go: URL routing.
- cmd/api/handlers_health.go: process health endpoint.
- internal/models: user data and database operations.
- internal/validator: username and new-password rules.
- internal/password: password hashing and comparison.
- migrations: database schema SQL.

## Registration API

POST /users accepts Content-Type: application/json:

```json
{"username":"Art","password":"example-password","confirm_password":"example-password"}
```

Usernames allow English letters only and are stored in lowercase.
New passwords require at least 8 Unicode code points and at most 72 UTF-8 bytes.
The endpoint hashes passwords before insertion. A successful response is 201
with user id, normalized username and creation time. It does not log the user in.
Invalid fields or duplicate usernames return 422, malformed JSON returns 400,
oversized bodies return 413 and incorrect Content-Type returns 415.
Database failures return a generic 500 without exposing credentials.

## Login and sessions

Run migrations/000002_create_sessions.up.sql as postgres in rentmate, then grant:

```sql
GRANT SELECT, INSERT, DELETE ON TABLE public.sessions TO rentmate_app;
```

POST /sessions accepts JSON username and password. It returns 201 with a random
Bearer token and expires_at on success, or the same 401 message for unknown
usernames and wrong passwords. Only a SHA-256 digest of the random token is stored.
Sessions expire after 24 hours, checked against database time.

GET /users/me accepts Authorization: Bearer TOKEN and returns the current user.
DELETE /sessions/current revokes that token and returns 204. No cookie or JWT is used.
Never log tokens or passwords. Use HTTPS for deployment and secure storage in the
future mobile client. Token responses use Cache-Control: no-store.

Signup and login share a process-local limit of 10 requests/minute/client IP.
The limiter reads RemoteAddr and ignores forwarded headers. Configure a trusted
proxy policy before deployment; multiple API instances need a shared limiter.
Expired session rows are rejected but not automatically deleted yet.
The sessions migration is manual; the API does not execute it.

The API remains bound to loopback for local development.
Flutter integration, property authorization and password-change/session-revocation
flows are not implemented yet. Database tests use mocks, not a live PostgreSQL server.
