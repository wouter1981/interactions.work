# Phase 1: Repository Restructuring + Relay Server

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove the old Rust/Flutter/Git-based codebase and build the relay server that both native apps will connect to.

**Architecture:** Rust (Axum) relay server with PostgreSQL. REST API for auth/teams, WebSocket for E2E encrypted envelope relay. The server is deliberately dumb — it stores team IDs, member emails, and encrypted blobs. It never sees content.

**Tech Stack:** Rust 2021, Axum 0.8+, sqlx (PostgreSQL), tokio, tokio-tungstenite, serde/serde_json, jsonwebtoken, uuid, chrono, reqwest (for Resend API).

**Spec:** `docs/superpowers/specs/2026-03-22-interactions-work-v1-design.md`

**This is Phase 1 of 4:**
- Phase 1: Repo restructuring + relay server (this plan)
- Phase 2: iOS app (separate plan)
- Phase 3: Android app (separate plan)
- Phase 4: Marketing website (separate plan)

---

## File Structure

```
server/
├── Cargo.toml
├── .env.example
├── migrations/
│   └── 001_initial.sql
├── src/
│   ├── main.rs                    # Entry point, server startup
│   ├── config.rs                  # Environment configuration
│   ├── db.rs                      # Database pool setup
│   ├── error.rs                   # Error types and responses
│   ├── auth/
│   │   ├── mod.rs                 # Auth module exports
│   │   ├── handlers.rs            # POST /auth/send-code, POST /auth/verify
│   │   ├── jwt.rs                 # JWT creation, validation, middleware
│   │   └── code.rs                # 6-digit code generation, storage, verification
│   ├── teams/
│   │   ├── mod.rs                 # Teams module exports
│   │   ├── handlers.rs            # POST /teams, GET /teams/:code, POST /teams/:id/join, DELETE member
│   │   └── models.rs              # Team, TeamMember types
│   ├── push/
│   │   ├── mod.rs                 # Push module exports
│   │   └── handlers.rs            # POST /push/register
│   ├── account/
│   │   ├── mod.rs                 # Account module exports
│   │   └── handlers.rs            # DELETE /account
│   ├── sync/
│   │   ├── mod.rs                 # Sync module exports
│   │   ├── ws.rs                  # WebSocket upgrade, connection handler
│   │   ├── envelope.rs            # Envelope type, validation
│   │   └── relay.rs               # Message routing, offline queue
│   └── email.rs                   # Resend API client
tests/
└── interop/
    └── README.md                  # Placeholder for cross-platform test vectors
```

---

## Task 1: Remove Old Codebase

**Files:**
- Delete: `rust/`, `flutter/`, `check.sh`, `run.sh`, `flutter_rust_bridge.yaml`
- Keep: `docs/`, `CLAUDE.md`, `README.md`, `.claude/`

- [ ] **Step 1: Remove old directories and files**

```bash
git rm -r rust/ flutter/ check.sh run.sh flutter_rust_bridge.yaml
```

Note: Keep `docs/` (has our specs and intent), `CLAUDE.md` (updated), `README.md` (will update later), and `.claude/`.

- [ ] **Step 2: Commit**

```bash
git add -A
git commit -m "chore: remove old Rust/Flutter/Git-based codebase

The previous architecture (Rust core + Flutter + Ratatui TUI + Git storage)
is replaced by native iOS + Android apps with E2E encrypted relay server.
See docs/superpowers/specs/2026-03-22-interactions-work-v1-design.md"
```

---

## Task 2: Initialize Server Cargo Project

**Files:**
- Create: `server/Cargo.toml`
- Create: `server/src/main.rs`
- Create: `server/.env.example`

- [ ] **Step 1: Create server directory and initialize Cargo project**

```bash
mkdir -p server/src
```

- [ ] **Step 2: Write Cargo.toml**

Create `server/Cargo.toml`:

```toml
[package]
name = "interactions-server"
version = "0.1.0"
edition = "2021"

[dependencies]
axum = { version = "0.8", features = ["ws"] }
axum-extra = { version = "0.10", features = ["typed-header"] }
tokio = { version = "1", features = ["full"] }
tokio-tungstenite = "0.26"
serde = { version = "1", features = ["derive"] }
serde_json = "1"
sqlx = { version = "0.8", features = ["runtime-tokio", "postgres", "uuid", "chrono"] }
uuid = { version = "1", features = ["v4", "serde"] }
chrono = { version = "0.4", features = ["serde"] }
jsonwebtoken = "9"
reqwest = { version = "0.12", features = ["json"] }
tower-http = { version = "0.6", features = ["cors", "trace"] }
tracing = "0.1"
tracing-subscriber = { version = "0.3", features = ["env-filter"] }
dotenvy = "0.15"
rand = "0.8"
base64 = "0.22"
thiserror = "2"
```

- [ ] **Step 3: Write minimal main.rs**

Create `server/src/main.rs`:

```rust
use std::net::SocketAddr;
use tracing_subscriber::EnvFilter;

#[tokio::main]
async fn main() {
    dotenvy::dotenv().ok();

    tracing_subscriber::fmt()
        .with_env_filter(EnvFilter::from_default_env())
        .init();

    let app = axum::Router::new()
        .route("/health", axum::routing::get(|| async { "ok" }));

    let addr = SocketAddr::from(([0, 0, 0, 0], 3000));
    tracing::info!("listening on {}", addr);

    let listener = tokio::net::TcpListener::bind(addr).await.unwrap();
    axum::serve(listener, app).await.unwrap();
}
```

- [ ] **Step 4: Write .env.example**

Create `server/.env.example`:

```
DATABASE_URL=postgres://interactions:interactions@localhost:5432/interactions
JWT_SECRET=change-me-to-a-random-64-char-string
RESEND_API_KEY=re_your_api_key
RUST_LOG=interactions_server=debug,tower_http=debug
```

- [ ] **Step 5: Verify it compiles**

```bash
cd server && cargo check
```

Expected: compiles with no errors.

- [ ] **Step 6: Commit**

```bash
git add server/
git commit -m "feat(server): initialize Cargo project with Axum skeleton"
```

---

## Task 3: Configuration and Database Setup

**Files:**
- Create: `server/src/config.rs`
- Create: `server/src/db.rs`
- Create: `server/src/error.rs`
- Create: `server/migrations/001_initial.sql`
- Modify: `server/src/main.rs`

- [ ] **Step 1: Write config.rs**

Create `server/src/config.rs`:

```rust
use std::env;

pub struct Config {
    pub database_url: String,
    pub jwt_secret: String,
    pub resend_api_key: String,
    pub port: u16,
}

impl Config {
    pub fn from_env() -> Self {
        Self {
            database_url: env::var("DATABASE_URL")
                .expect("DATABASE_URL must be set"),
            jwt_secret: env::var("JWT_SECRET")
                .expect("JWT_SECRET must be set"),
            resend_api_key: env::var("RESEND_API_KEY")
                .unwrap_or_default(),
            port: env::var("PORT")
                .ok()
                .and_then(|p| p.parse().ok())
                .unwrap_or(3000),
        }
    }
}
```

- [ ] **Step 2: Write error.rs**

Create `server/src/error.rs`:

```rust
use axum::http::StatusCode;
use axum::response::{IntoResponse, Response};
use serde_json::json;

#[derive(Debug, thiserror::Error)]
pub enum AppError {
    #[error("not found")]
    NotFound,

    #[error("unauthorized")]
    Unauthorized,

    #[error("forbidden")]
    Forbidden,

    #[error("bad request: {0}")]
    BadRequest(String),

    #[error("internal error: {0}")]
    Internal(String),

    #[error(transparent)]
    Sqlx(#[from] sqlx::Error),
}

impl IntoResponse for AppError {
    fn into_response(self) -> Response {
        let (status, message) = match &self {
            AppError::NotFound => (StatusCode::NOT_FOUND, self.to_string()),
            AppError::Unauthorized => (StatusCode::UNAUTHORIZED, self.to_string()),
            AppError::Forbidden => (StatusCode::FORBIDDEN, self.to_string()),
            AppError::BadRequest(_) => (StatusCode::BAD_REQUEST, self.to_string()),
            AppError::Internal(_) => (StatusCode::INTERNAL_SERVER_ERROR, "internal error".into()),
            AppError::Sqlx(_) => (StatusCode::INTERNAL_SERVER_ERROR, "internal error".into()),
        };

        let body = axum::Json(json!({ "error": message }));
        (status, body).into_response()
    }
}
```

- [ ] **Step 3: Write db.rs**

Create `server/src/db.rs`:

```rust
use sqlx::postgres::PgPoolOptions;
use sqlx::PgPool;

pub async fn create_pool(database_url: &str) -> PgPool {
    PgPoolOptions::new()
        .max_connections(10)
        .connect(database_url)
        .await
        .expect("failed to connect to database")
}

pub async fn run_migrations(pool: &PgPool) {
    sqlx::migrate!("./migrations")
        .run(pool)
        .await
        .expect("failed to run migrations");
}
```

- [ ] **Step 4: Write initial migration**

Create `server/migrations/001_initial.sql`:

```sql
CREATE TABLE users (
    email TEXT PRIMARY KEY,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE verification_codes (
    email TEXT NOT NULL,
    code TEXT NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_verification_codes_email ON verification_codes(email);

CREATE TABLE teams (
    id UUID PRIMARY KEY,
    name TEXT NOT NULL,
    invite_code TEXT NOT NULL UNIQUE,
    team_type TEXT NOT NULL DEFAULT 'professional',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_teams_invite_code ON teams(invite_code);

CREATE TABLE team_members (
    team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    email TEXT NOT NULL REFERENCES users(email) ON DELETE CASCADE,
    role TEXT NOT NULL DEFAULT 'member',
    joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (team_id, email)
);

CREATE TABLE sessions (
    token_hash TEXT PRIMARY KEY,
    email TEXT NOT NULL REFERENCES users(email) ON DELETE CASCADE,
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_sessions_email ON sessions(email);

CREATE TABLE envelope_queue (
    id UUID PRIMARY KEY,
    team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    sender_id TEXT NOT NULL,
    recipient_id TEXT NOT NULL,
    encrypted_payload TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMPTZ NOT NULL DEFAULT (NOW() + INTERVAL '30 days')
);
CREATE INDEX idx_envelope_queue_recipient ON envelope_queue(recipient_id, team_id);

CREATE TABLE push_tokens (
    email TEXT NOT NULL REFERENCES users(email) ON DELETE CASCADE,
    platform TEXT NOT NULL,
    token TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (email, token)
);
```

- [ ] **Step 5: Update main.rs to use config and db**

Replace `server/src/main.rs`:

```rust
mod config;
mod db;
mod error;

use std::net::SocketAddr;
use std::sync::Arc;

use axum::extract::State;
use sqlx::PgPool;
use tracing_subscriber::EnvFilter;

use crate::config::Config;

#[derive(Clone)]
pub struct AppState {
    pub db: PgPool,
    pub config: Arc<Config>,
}

#[tokio::main]
async fn main() {
    dotenvy::dotenv().ok();

    tracing_subscriber::fmt()
        .with_env_filter(EnvFilter::from_default_env())
        .init();

    let config = Config::from_env();
    let pool = db::create_pool(&config.database_url).await;
    db::run_migrations(&pool).await;

    let state = AppState {
        db: pool,
        config: Arc::new(config),
    };

    let app = axum::Router::new()
        .route("/health", axum::routing::get(health))
        .with_state(state.clone());

    let addr = SocketAddr::from(([0, 0, 0, 0], state.config.port));
    tracing::info!("listening on {}", addr);

    let listener = tokio::net::TcpListener::bind(addr).await.unwrap();
    axum::serve(listener, app).await.unwrap();
}

async fn health(State(state): State<AppState>) -> &'static str {
    // Verify DB is reachable
    let _ = sqlx::query("SELECT 1")
        .execute(&state.db)
        .await;
    "ok"
}
```

- [ ] **Step 6: Verify it compiles**

```bash
cd server && cargo check
```

Expected: compiles with no errors.

- [ ] **Step 7: Commit**

```bash
git add server/
git commit -m "feat(server): add config, database, error handling, and initial migration"
```

---

## Task 4: Auth — 6-Digit Code Generation and Verification

**Files:**
- Create: `server/src/auth/mod.rs`
- Create: `server/src/auth/code.rs`
- Create: `server/src/auth/jwt.rs`
- Create: `server/src/auth/handlers.rs`
- Create: `server/src/email.rs`
- Modify: `server/src/main.rs`

- [ ] **Step 1: Write auth/code.rs — code generation and verification**

Create `server/src/auth/code.rs`:

```rust
use chrono::{Duration, Utc};
use rand::Rng;
use sqlx::PgPool;

use crate::error::AppError;

pub fn generate_code() -> String {
    let mut rng = rand::thread_rng();
    let code: u32 = rng.gen_range(100_000..1_000_000);
    format!("{:06}", code)
}

pub async fn store_code(pool: &PgPool, email: &str, code: &str) -> Result<(), AppError> {
    // Delete any existing codes for this email
    sqlx::query("DELETE FROM verification_codes WHERE email = $1")
        .bind(email)
        .execute(pool)
        .await?;

    let expires_at = Utc::now() + Duration::minutes(10);

    sqlx::query(
        "INSERT INTO verification_codes (email, code, expires_at) VALUES ($1, $2, $3)"
    )
        .bind(email)
        .bind(code)
        .bind(expires_at)
        .execute(pool)
        .await?;

    Ok(())
}

pub async fn verify_code(pool: &PgPool, email: &str, code: &str) -> Result<bool, AppError> {
    let result = sqlx::query_scalar::<_, i64>(
        "DELETE FROM verification_codes WHERE email = $1 AND code = $2 AND expires_at > NOW() RETURNING 1"
    )
        .bind(email)
        .bind(code)
        .fetch_optional(pool)
        .await?;

    Ok(result.is_some())
}
```

- [ ] **Step 2: Write auth/jwt.rs — JWT creation and validation**

Create `server/src/auth/jwt.rs`:

```rust
use axum::extract::{FromRequestParts, State};
use axum::http::request::Parts;
use chrono::{Duration, Utc};
use jsonwebtoken::{decode, encode, DecodingKey, EncodingKey, Header, Validation};
use serde::{Deserialize, Serialize};

use crate::error::AppError;
use crate::AppState;

#[derive(Debug, Serialize, Deserialize)]
pub struct Claims {
    pub sub: String, // email
    pub exp: i64,
    pub iat: i64,
}

pub fn create_token(email: &str, secret: &str) -> Result<String, AppError> {
    let now = Utc::now();
    let claims = Claims {
        sub: email.to_string(),
        exp: (now + Duration::days(30)).timestamp(),
        iat: now.timestamp(),
    };

    encode(
        &Header::default(),
        &claims,
        &EncodingKey::from_secret(secret.as_bytes()),
    )
    .map_err(|e| AppError::Internal(e.to_string()))
}

pub fn validate_token(token: &str, secret: &str) -> Result<Claims, AppError> {
    decode::<Claims>(
        token,
        &DecodingKey::from_secret(secret.as_bytes()),
        &Validation::default(),
    )
    .map(|data| data.claims)
    .map_err(|_| AppError::Unauthorized)
}

/// Extractor that validates JWT from Authorization header
pub struct AuthUser {
    pub email: String,
}

impl<S> FromRequestParts<S> for AuthUser
where
    S: Send + Sync,
    AppState: FromRef<S>,
{
    type Rejection = AppError;

    async fn from_request_parts(parts: &mut Parts, state: &S) -> Result<Self, Self::Rejection> {
        let app_state = AppState::from_ref(state);

        let auth_header = parts
            .headers
            .get("authorization")
            .and_then(|v| v.to_str().ok())
            .ok_or(AppError::Unauthorized)?;

        let token = auth_header
            .strip_prefix("Bearer ")
            .ok_or(AppError::Unauthorized)?;

        let claims = validate_token(token, &app_state.config.jwt_secret)?;
        Ok(AuthUser { email: claims.sub })
    }
}

// Helper trait for state extraction
use std::convert::Infallible;

pub trait FromRef<T> {
    fn from_ref(input: &T) -> Self;
}

impl FromRef<AppState> for AppState {
    fn from_ref(input: &AppState) -> Self {
        input.clone()
    }
}
```

- [ ] **Step 3: Write email.rs — Resend API client**

Create `server/src/email.rs`:

```rust
use reqwest::Client;
use serde_json::json;

use crate::error::AppError;

pub async fn send_verification_code(
    api_key: &str,
    to_email: &str,
    code: &str,
) -> Result<(), AppError> {
    if api_key.is_empty() {
        // Development mode: log the code instead of sending
        tracing::info!("VERIFICATION CODE for {}: {}", to_email, code);
        return Ok(());
    }

    let client = Client::new();
    let response = client
        .post("https://api.resend.com/emails")
        .header("Authorization", format!("Bearer {}", api_key))
        .json(&json!({
            "from": "interactions.work <noreply@interactions.work>",
            "to": [to_email],
            "subject": "Your verification code",
            "text": format!("Your verification code is: {}\n\nThis code expires in 10 minutes.", code)
        }))
        .send()
        .await
        .map_err(|e| AppError::Internal(e.to_string()))?;

    if !response.status().is_success() {
        let body = response.text().await.unwrap_or_default();
        return Err(AppError::Internal(format!("email send failed: {}", body)));
    }

    Ok(())
}
```

- [ ] **Step 4: Write auth/handlers.rs**

Create `server/src/auth/handlers.rs`:

```rust
use axum::extract::State;
use axum::Json;
use serde::{Deserialize, Serialize};

use crate::error::AppError;
use crate::AppState;

use super::code::{generate_code, store_code, verify_code};
use super::jwt::create_token;

#[derive(Deserialize)]
pub struct SendCodeRequest {
    pub email: String,
}

#[derive(Serialize)]
pub struct SendCodeResponse {
    pub message: String,
}

pub async fn send_code(
    State(state): State<AppState>,
    Json(req): Json<SendCodeRequest>,
) -> Result<Json<SendCodeResponse>, AppError> {
    let email = req.email.trim().to_lowercase();
    if email.is_empty() || !email.contains('@') {
        return Err(AppError::BadRequest("invalid email".into()));
    }

    // Ensure user exists
    sqlx::query("INSERT INTO users (email) VALUES ($1) ON CONFLICT DO NOTHING")
        .bind(&email)
        .execute(&state.db)
        .await?;

    let code = generate_code();
    store_code(&state.db, &email, &code).await?;

    crate::email::send_verification_code(
        &state.config.resend_api_key,
        &email,
        &code,
    )
    .await?;

    Ok(Json(SendCodeResponse {
        message: "verification code sent".into(),
    }))
}

#[derive(Deserialize)]
pub struct VerifyRequest {
    pub email: String,
    pub code: String,
}

#[derive(Serialize)]
pub struct VerifyResponse {
    pub token: String,
}

pub async fn verify(
    State(state): State<AppState>,
    Json(req): Json<VerifyRequest>,
) -> Result<Json<VerifyResponse>, AppError> {
    let email = req.email.trim().to_lowercase();

    let valid = verify_code(&state.db, &email, &req.code).await?;
    if !valid {
        return Err(AppError::Unauthorized);
    }

    let token = create_token(&email, &state.config.jwt_secret)?;

    Ok(Json(VerifyResponse { token }))
}
```

- [ ] **Step 5: Write auth/mod.rs**

Create `server/src/auth/mod.rs`:

```rust
pub mod code;
pub mod handlers;
pub mod jwt;
```

- [ ] **Step 6: Update main.rs to register auth routes**

Update `server/src/main.rs` — add modules and routes:

```rust
mod auth;
mod config;
mod db;
mod email;
mod error;

use std::net::SocketAddr;
use std::sync::Arc;

use axum::extract::State;
use axum::routing::{get, post};
use sqlx::PgPool;
use tracing_subscriber::EnvFilter;

use crate::config::Config;

#[derive(Clone)]
pub struct AppState {
    pub db: PgPool,
    pub config: Arc<Config>,
}

#[tokio::main]
async fn main() {
    dotenvy::dotenv().ok();

    tracing_subscriber::fmt()
        .with_env_filter(EnvFilter::from_default_env())
        .init();

    let config = Config::from_env();
    let pool = db::create_pool(&config.database_url).await;
    db::run_migrations(&pool).await;

    let state = AppState {
        db: pool,
        config: Arc::new(config),
    };

    let app = axum::Router::new()
        .route("/health", get(health))
        .route("/auth/send-code", post(auth::handlers::send_code))
        .route("/auth/verify", post(auth::handlers::verify))
        .with_state(state.clone());

    let addr = SocketAddr::from(([0, 0, 0, 0], state.config.port));
    tracing::info!("listening on {}", addr);

    let listener = tokio::net::TcpListener::bind(addr).await.unwrap();
    axum::serve(listener, app).await.unwrap();
}

async fn health(State(state): State<AppState>) -> &'static str {
    let _ = sqlx::query("SELECT 1").execute(&state.db).await;
    "ok"
}
```

- [ ] **Step 7: Verify it compiles**

```bash
cd server && cargo check
```

Expected: compiles with no errors.

- [ ] **Step 8: Commit**

```bash
git add server/
git commit -m "feat(server): add auth endpoints — send-code and verify with JWT"
```

---

## Task 5: Teams — Create, Invite, Join, Remove

**Files:**
- Create: `server/src/teams/mod.rs`
- Create: `server/src/teams/models.rs`
- Create: `server/src/teams/handlers.rs`
- Modify: `server/src/main.rs`

- [ ] **Step 1: Write teams/models.rs**

Create `server/src/teams/models.rs`:

```rust
use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

#[derive(Debug, Serialize, Deserialize, sqlx::FromRow)]
pub struct Team {
    pub id: Uuid,
    pub name: String,
    pub invite_code: String,
    pub team_type: String,
    pub created_at: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize, sqlx::FromRow)]
pub struct TeamMember {
    pub team_id: Uuid,
    pub email: String,
    pub role: String,
    pub joined_at: DateTime<Utc>,
}
```

- [ ] **Step 2: Write teams/handlers.rs**

Create `server/src/teams/handlers.rs`:

```rust
use axum::extract::{Path, State};
use axum::Json;
use rand::Rng;
use serde::{Deserialize, Serialize};
use uuid::Uuid;

use crate::auth::jwt::AuthUser;
use crate::error::AppError;
use crate::AppState;

fn generate_invite_code() -> String {
    use rand::distributions::Alphanumeric;
    use rand::Rng;
    let code: String = rand::thread_rng()
        .sample_iter(&Alphanumeric)
        .take(8)
        .map(char::from)
        .collect();
    code.to_uppercase()
}

// POST /teams
#[derive(Deserialize)]
pub struct CreateTeamRequest {
    pub name: String,
    pub team_type: Option<String>,
}

#[derive(Serialize)]
pub struct CreateTeamResponse {
    pub id: Uuid,
    pub name: String,
    pub invite_code: String,
    pub team_type: String,
}

pub async fn create_team(
    State(state): State<AppState>,
    auth: AuthUser,
    Json(req): Json<CreateTeamRequest>,
) -> Result<Json<CreateTeamResponse>, AppError> {
    let name = req.name.trim().to_string();
    if name.is_empty() {
        return Err(AppError::BadRequest("team name required".into()));
    }

    let id = Uuid::new_v4();
    let invite_code = generate_invite_code();
    let team_type = req.team_type.unwrap_or_else(|| "professional".into());

    sqlx::query("INSERT INTO teams (id, name, invite_code, team_type) VALUES ($1, $2, $3, $4)")
        .bind(id)
        .bind(&name)
        .bind(&invite_code)
        .bind(&team_type)
        .execute(&state.db)
        .await?;

    // Creator becomes leader
    sqlx::query("INSERT INTO team_members (team_id, email, role) VALUES ($1, $2, 'leader')")
        .bind(id)
        .bind(&auth.email)
        .execute(&state.db)
        .await?;

    Ok(Json(CreateTeamResponse {
        id,
        name,
        invite_code,
        team_type,
    }))
}

// GET /teams/:invite_code
#[derive(Serialize)]
pub struct ResolveInviteResponse {
    pub id: Uuid,
    pub name: String,
}

pub async fn resolve_invite(
    State(state): State<AppState>,
    Path(invite_code): Path<String>,
) -> Result<Json<ResolveInviteResponse>, AppError> {
    let team = sqlx::query_as::<_, (Uuid, String)>(
        "SELECT id, name FROM teams WHERE invite_code = $1"
    )
        .bind(&invite_code)
        .fetch_optional(&state.db)
        .await?
        .ok_or(AppError::NotFound)?;

    Ok(Json(ResolveInviteResponse {
        id: team.0,
        name: team.1,
    }))
}

// POST /teams/:id/join
pub async fn join_team(
    State(state): State<AppState>,
    auth: AuthUser,
    Path(team_id): Path<Uuid>,
) -> Result<Json<serde_json::Value>, AppError> {
    // Verify team exists
    let exists = sqlx::query_scalar::<_, bool>("SELECT EXISTS(SELECT 1 FROM teams WHERE id = $1)")
        .bind(team_id)
        .fetch_one(&state.db)
        .await?;

    if !exists {
        return Err(AppError::NotFound);
    }

    sqlx::query(
        "INSERT INTO team_members (team_id, email, role) VALUES ($1, $2, 'member') ON CONFLICT DO NOTHING"
    )
        .bind(team_id)
        .bind(&auth.email)
        .execute(&state.db)
        .await?;

    Ok(Json(serde_json::json!({ "message": "joined" })))
}

// DELETE /teams/:id/members/:email
pub async fn remove_member(
    State(state): State<AppState>,
    auth: AuthUser,
    Path((team_id, member_email)): Path<(Uuid, String)>,
) -> Result<Json<serde_json::Value>, AppError> {
    // Check requester is a leader
    let role = sqlx::query_scalar::<_, String>(
        "SELECT role FROM team_members WHERE team_id = $1 AND email = $2"
    )
        .bind(team_id)
        .bind(&auth.email)
        .fetch_optional(&state.db)
        .await?
        .ok_or(AppError::Forbidden)?;

    if role != "leader" {
        return Err(AppError::Forbidden);
    }

    // Can't remove yourself if you're the last leader
    if member_email == auth.email {
        let leader_count = sqlx::query_scalar::<_, i64>(
            "SELECT COUNT(*) FROM team_members WHERE team_id = $1 AND role = 'leader'"
        )
            .bind(team_id)
            .fetch_one(&state.db)
            .await?;

        if leader_count <= 1 {
            return Err(AppError::BadRequest("cannot remove the last leader".into()));
        }
    }

    sqlx::query("DELETE FROM team_members WHERE team_id = $1 AND email = $2")
        .bind(team_id)
        .bind(&member_email)
        .execute(&state.db)
        .await?;

    Ok(Json(serde_json::json!({ "message": "removed" })))
}
```

- [ ] **Step 3: Write teams/mod.rs**

Create `server/src/teams/mod.rs`:

```rust
pub mod handlers;
pub mod models;
```

- [ ] **Step 4: Update main.rs to register team routes**

Add to `server/src/main.rs`:

```rust
mod teams;
```

And add routes to the router:

```rust
.route("/teams", post(teams::handlers::create_team))
.route("/teams/:invite_code", get(teams::handlers::resolve_invite))
.route("/teams/:id/join", post(teams::handlers::join_team))
.route("/teams/:id/members/:email", axum::routing::delete(teams::handlers::remove_member))
```

- [ ] **Step 5: Verify it compiles**

```bash
cd server && cargo check
```

- [ ] **Step 6: Commit**

```bash
git add server/
git commit -m "feat(server): add team endpoints — create, resolve invite, join, remove member"
```

---

## Task 6: Push Registration and Account Deletion

**Files:**
- Create: `server/src/push/mod.rs`
- Create: `server/src/push/handlers.rs`
- Create: `server/src/account/mod.rs`
- Create: `server/src/account/handlers.rs`
- Modify: `server/src/main.rs`

- [ ] **Step 1: Write push/handlers.rs**

Create `server/src/push/handlers.rs`:

```rust
use axum::extract::State;
use axum::Json;
use serde::Deserialize;

use crate::auth::jwt::AuthUser;
use crate::error::AppError;
use crate::AppState;

#[derive(Deserialize)]
pub struct RegisterPushRequest {
    pub platform: String, // "ios" or "android"
    pub token: String,
}

pub async fn register_push(
    State(state): State<AppState>,
    auth: AuthUser,
    Json(req): Json<RegisterPushRequest>,
) -> Result<Json<serde_json::Value>, AppError> {
    sqlx::query(
        "INSERT INTO push_tokens (email, platform, token) VALUES ($1, $2, $3) ON CONFLICT (email, token) DO UPDATE SET platform = $2"
    )
        .bind(&auth.email)
        .bind(&req.platform)
        .bind(&req.token)
        .execute(&state.db)
        .await?;

    Ok(Json(serde_json::json!({ "message": "registered" })))
}
```

- [ ] **Step 2: Write push/mod.rs**

Create `server/src/push/mod.rs`:

```rust
pub mod handlers;
```

- [ ] **Step 3: Write account/handlers.rs**

Create `server/src/account/handlers.rs`:

```rust
use axum::extract::State;
use axum::Json;

use crate::auth::jwt::AuthUser;
use crate::error::AppError;
use crate::AppState;

pub async fn delete_account(
    State(state): State<AppState>,
    auth: AuthUser,
) -> Result<Json<serde_json::Value>, AppError> {
    // Cascading deletes handle team_members, sessions, push_tokens, envelope_queue
    // via FK constraints with ON DELETE CASCADE
    sqlx::query("DELETE FROM users WHERE email = $1")
        .bind(&auth.email)
        .execute(&state.db)
        .await?;

    Ok(Json(serde_json::json!({ "message": "account deleted" })))
}
```

- [ ] **Step 4: Write account/mod.rs**

Create `server/src/account/mod.rs`:

```rust
pub mod handlers;
```

- [ ] **Step 5: Update main.rs with push and account routes**

Add modules:

```rust
mod account;
mod push;
```

Add routes:

```rust
.route("/push/register", post(push::handlers::register_push))
.route("/account", axum::routing::delete(account::handlers::delete_account))
```

- [ ] **Step 6: Verify it compiles**

```bash
cd server && cargo check
```

- [ ] **Step 7: Commit**

```bash
git add server/
git commit -m "feat(server): add push registration and GDPR account deletion"
```

---

## Task 7: WebSocket Relay — Envelope Routing

**Files:**
- Create: `server/src/sync/mod.rs`
- Create: `server/src/sync/envelope.rs`
- Create: `server/src/sync/ws.rs`
- Create: `server/src/sync/relay.rs`
- Modify: `server/src/main.rs`

- [ ] **Step 1: Write sync/envelope.rs**

Create `server/src/sync/envelope.rs`:

```rust
use serde::{Deserialize, Serialize};
use uuid::Uuid;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Envelope {
    pub envelope_id: Uuid,
    pub team_id: Uuid,
    pub sender_id: String,
    pub timestamp: i64,
    pub recipients: Recipients,
    pub payload: String, // base64-encoded encrypted blob
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(untagged)]
pub enum Recipients {
    All(String),        // "all"
    Specific(Vec<String>), // ["member-id-1", "member-id-2"]
}

impl Recipients {
    pub fn is_all(&self) -> bool {
        matches!(self, Recipients::All(s) if s == "all")
    }

    pub fn member_ids(&self) -> Vec<&str> {
        match self {
            Recipients::All(_) => vec![],
            Recipients::Specific(ids) => ids.iter().map(|s| s.as_str()).collect(),
        }
    }
}
```

- [ ] **Step 2: Write sync/relay.rs — connection registry and message routing**

Create `server/src/sync/relay.rs`:

```rust
use std::collections::HashMap;
use std::sync::Arc;

use sqlx::PgPool;
use tokio::sync::{mpsc, RwLock};
use uuid::Uuid;

use super::envelope::Envelope;

type Tx = mpsc::UnboundedSender<String>;

/// Tracks connected clients: (team_id, email) → sender channel
#[derive(Clone, Default)]
pub struct Relay {
    connections: Arc<RwLock<HashMap<(Uuid, String), Tx>>>,
}

impl Relay {
    pub fn new() -> Self {
        Self::default()
    }

    pub async fn register(&self, team_id: Uuid, email: String, tx: Tx) {
        self.connections.write().await.insert((team_id, email), tx);
    }

    pub async fn unregister(&self, team_id: &Uuid, email: &str) {
        self.connections.write().await.remove(&(*team_id, email.to_string()));
    }

    pub async fn route_envelope(&self, envelope: &Envelope, pool: &PgPool, sender_email: &str) {
        let conns = self.connections.read().await;

        if envelope.recipients.is_all() {
            // Send to all connected team members except sender
            for ((team_id, email), tx) in conns.iter() {
                if *team_id == envelope.team_id && email != sender_email {
                    let msg = serde_json::to_string(envelope).unwrap();
                    let _ = tx.send(msg);
                }
            }

            // Queue for offline members
            self.queue_for_offline(envelope, pool, sender_email, None).await;
        } else {
            // Send to specific recipients
            for recipient_id in envelope.recipients.member_ids() {
                let key = (envelope.team_id, recipient_id.to_string());
                if let Some(tx) = conns.get(&key) {
                    let msg = serde_json::to_string(envelope).unwrap();
                    let _ = tx.send(msg);
                } else {
                    // Queue for this offline recipient
                    let _ = self.queue_single(envelope, pool, recipient_id).await;
                }
            }
        }
    }

    async fn queue_for_offline(
        &self,
        envelope: &Envelope,
        pool: &PgPool,
        sender_email: &str,
        _specific: Option<&[&str]>,
    ) {
        // Get all team members who are NOT currently connected
        let members: Vec<String> = sqlx::query_scalar(
            "SELECT email FROM team_members WHERE team_id = $1 AND email != $2"
        )
            .bind(envelope.team_id)
            .bind(sender_email)
            .fetch_all(pool)
            .await
            .unwrap_or_default();

        let conns = self.connections.read().await;
        for member_email in members {
            let key = (envelope.team_id, member_email.clone());
            if !conns.contains_key(&key) {
                let _ = self.queue_single(envelope, pool, &member_email).await;
            }
        }
    }

    async fn queue_single(&self, envelope: &Envelope, pool: &PgPool, recipient: &str) -> Result<(), sqlx::Error> {
        sqlx::query(
            "INSERT INTO envelope_queue (id, team_id, sender_id, recipient_id, encrypted_payload) VALUES ($1, $2, $3, $4, $5)"
        )
            .bind(envelope.envelope_id)
            .bind(envelope.team_id)
            .bind(&envelope.sender_id)
            .bind(recipient)
            .bind(&envelope.payload)
            .execute(pool)
            .await?;

        Ok(())
    }

    pub async fn deliver_queued(&self, pool: &PgPool, team_id: Uuid, email: &str, tx: &Tx) {
        let envelopes: Vec<(Uuid, String, String, i64, String)> = sqlx::query_as(
            "DELETE FROM envelope_queue WHERE team_id = $1 AND recipient_id = $2 AND expires_at > NOW() RETURNING id, team_id::text, sender_id, EXTRACT(EPOCH FROM created_at)::bigint, encrypted_payload"
        )
            .bind(team_id)
            .bind(email)
            .fetch_all(pool)
            .await
            .unwrap_or_default();

        for (id, _team, sender, ts, payload) in envelopes {
            let env = serde_json::json!({
                "envelope_id": id,
                "team_id": team_id,
                "sender_id": sender,
                "timestamp": ts,
                "recipients": "all",
                "payload": payload
            });
            let _ = tx.send(env.to_string());
        }
    }
}
```

- [ ] **Step 3: Write sync/ws.rs — WebSocket connection handler**

Create `server/src/sync/ws.rs`:

```rust
use axum::extract::ws::{Message, WebSocket};
use axum::extract::{Query, State, WebSocketUpgrade};
use axum::response::IntoResponse;
use futures_util::{SinkExt, StreamExt};
use serde::Deserialize;
use tokio::sync::mpsc;
use uuid::Uuid;

use crate::auth::jwt::validate_token;
use crate::error::AppError;
use crate::AppState;

use super::envelope::Envelope;
use super::relay::Relay;

#[derive(Deserialize)]
pub struct SyncParams {
    pub token: String,
    pub team_id: Uuid,
}

pub async fn ws_handler(
    ws: WebSocketUpgrade,
    State(state): State<AppState>,
    State(relay): State<Relay>,
    Query(params): Query<SyncParams>,
) -> Result<impl IntoResponse, AppError> {
    // Validate JWT
    let claims = validate_token(&params.token, &state.config.jwt_secret)?;
    let email = claims.sub;

    // Verify membership
    let is_member = sqlx::query_scalar::<_, bool>(
        "SELECT EXISTS(SELECT 1 FROM team_members WHERE team_id = $1 AND email = $2)"
    )
        .bind(params.team_id)
        .bind(&email)
        .fetch_one(&state.db)
        .await
        .map_err(|e| AppError::Internal(e.to_string()))?;

    if !is_member {
        return Err(AppError::Forbidden);
    }

    let team_id = params.team_id;
    let pool = state.db.clone();

    Ok(ws.on_upgrade(move |socket| handle_socket(socket, relay, pool, team_id, email)))
}

async fn handle_socket(socket: WebSocket, relay: Relay, pool: sqlx::PgPool, team_id: Uuid, email: String) {
    let (mut ws_sender, mut ws_receiver) = socket.split();
    let (tx, mut rx) = mpsc::unbounded_channel::<String>();

    // Register connection
    relay.register(team_id, email.clone(), tx.clone()).await;

    // Deliver any queued envelopes
    relay.deliver_queued(&pool, team_id, &email, &tx).await;

    // Spawn task to forward outgoing messages
    let send_task = tokio::spawn(async move {
        while let Some(msg) = rx.recv().await {
            if ws_sender.send(Message::Text(msg.into())).await.is_err() {
                break;
            }
        }
    });

    // Process incoming messages
    let relay_clone = relay.clone();
    let pool_clone = pool.clone();
    let email_clone = email.clone();

    while let Some(Ok(msg)) = ws_receiver.next().await {
        if let Message::Text(text) = msg {
            match serde_json::from_str::<Envelope>(&text) {
                Ok(envelope) => {
                    if envelope.team_id == team_id {
                        relay_clone.route_envelope(&envelope, &pool_clone, &email_clone).await;
                    }
                }
                Err(e) => {
                    tracing::warn!("invalid envelope from {}: {}", email_clone, e);
                }
            }
        }
    }

    // Cleanup
    relay.unregister(&team_id, &email).await;
    send_task.abort();
    tracing::debug!("{} disconnected from team {}", email, team_id);
}
```

- [ ] **Step 4: Write sync/mod.rs**

Create `server/src/sync/mod.rs`:

```rust
pub mod envelope;
pub mod relay;
pub mod ws;
```

- [ ] **Step 5: Update main.rs with WebSocket route and Relay state**

Update `server/src/main.rs` to include sync module, create Relay, and add the WS route. The AppState needs to include the Relay:

```rust
mod sync;

// Update AppState:
#[derive(Clone)]
pub struct AppState {
    pub db: PgPool,
    pub config: Arc<Config>,
    pub relay: sync::relay::Relay,
}

// In main():
let relay = sync::relay::Relay::new();

let state = AppState {
    db: pool,
    config: Arc::new(config),
    relay,
};

// Add route:
.route("/sync", get(sync::ws::ws_handler))
```

Note: The ws_handler needs to extract both AppState and Relay. Since Relay is inside AppState, adjust the handler to use `State(state): State<AppState>` and access `state.relay`.

- [ ] **Step 6: Add futures-util dependency**

Add to `server/Cargo.toml`:

```toml
futures-util = "0.3"
```

- [ ] **Step 7: Verify it compiles**

```bash
cd server && cargo check
```

- [ ] **Step 8: Commit**

```bash
git add server/
git commit -m "feat(server): add WebSocket relay with envelope routing and offline queue"
```

---

## Task 8: CORS, Tracing, and Server Polish

**Files:**
- Modify: `server/src/main.rs`

- [ ] **Step 1: Add CORS middleware and request tracing**

Update `server/src/main.rs` to add CORS (needed for website invite handler) and request logging:

```rust
use tower_http::cors::{Any, CorsLayer};
use tower_http::trace::TraceLayer;

// In main(), wrap the router:
let cors = CorsLayer::new()
    .allow_origin(Any)
    .allow_methods(Any)
    .allow_headers(Any);

let app = axum::Router::new()
    // ... routes ...
    .layer(TraceLayer::new_for_http())
    .layer(cors)
    .with_state(state.clone());
```

- [ ] **Step 2: Add envelope expiry cleanup task**

Add a background task in `main()` to periodically clean up expired envelopes:

```rust
// Spawn cleanup task
let cleanup_pool = state.db.clone();
tokio::spawn(async move {
    loop {
        tokio::time::sleep(tokio::time::Duration::from_secs(3600)).await;
        let result = sqlx::query("DELETE FROM envelope_queue WHERE expires_at < NOW()")
            .execute(&cleanup_pool)
            .await;
        match result {
            Ok(r) => tracing::info!("cleaned up {} expired envelopes", r.rows_affected()),
            Err(e) => tracing::error!("envelope cleanup failed: {}", e),
        }
    }
});
```

- [ ] **Step 3: Verify it compiles**

```bash
cd server && cargo check
```

- [ ] **Step 4: Commit**

```bash
git add server/
git commit -m "feat(server): add CORS, request tracing, and envelope expiry cleanup"
```

---

## Task 9: Docker Compose for Local Development

**Files:**
- Create: `docker-compose.yml` (root)
- Create: `server/Dockerfile`

- [ ] **Step 1: Write docker-compose.yml**

Create `docker-compose.yml` in project root:

```yaml
services:
  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: interactions
      POSTGRES_PASSWORD: interactions
      POSTGRES_DB: interactions
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data

volumes:
  pgdata:
```

- [ ] **Step 2: Write server Dockerfile**

Create `server/Dockerfile`:

```dockerfile
FROM rust:1.82-slim AS builder
WORKDIR /app
COPY . .
RUN cargo build --release

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*
COPY --from=builder /app/target/release/interactions-server /usr/local/bin/
CMD ["interactions-server"]
```

- [ ] **Step 3: Commit**

```bash
git add docker-compose.yml server/Dockerfile
git commit -m "chore: add docker-compose for local PostgreSQL and server Dockerfile"
```

---

## Task 10: Create Interop Test Scaffold and Protocol Doc Placeholder

**Files:**
- Create: `tests/interop/README.md`
- Create: `docs/protocol/README.md`

- [ ] **Step 1: Write interop test README**

Create `tests/interop/README.md`:

```markdown
# Interoperability Tests

Cross-platform test vectors to verify iOS and Android implementations speak the same protocol.

## What to Test

- Envelope serialization/deserialization
- Encryption: both apps encrypt/decrypt with the same test keys
- Conflict resolution: both apps resolve the same conflicts identically
- Sync state: both apps reach the same state given the same sequence of envelopes

## Format

Test vectors are JSON files. Each contains:
- Input: a sequence of operations or envelopes
- Expected output: the resulting state or decrypted content

Both apps load these vectors and verify their implementation produces the expected output.
```

- [ ] **Step 2: Write protocol README**

Create `docs/protocol/README.md`:

```markdown
# Protocol Specification

Wire format and sync protocol for interactions.work.

The design spec at `docs/superpowers/specs/2026-03-22-interactions-work-v1-design.md` contains the initial protocol definition. This directory will hold the detailed wire format documentation as it evolves.

## Contents

- Envelope format (JSON over WebSocket)
- Payload format (encrypted, decrypted on device)
- Key exchange protocol
- Conflict resolution rules
- Sync state machine
```

- [ ] **Step 3: Commit**

```bash
git add tests/ docs/protocol/
git commit -m "docs: add interop test scaffold and protocol documentation placeholder"
```

---

## Summary

After completing all 10 tasks, the repository will have:

1. Old codebase removed
2. Relay server with all REST endpoints (auth, teams, push, account deletion)
3. WebSocket relay for E2E encrypted envelopes with offline queue
4. PostgreSQL migrations
5. Docker Compose for local development
6. Scaffolding for interop tests and protocol documentation

The server is ready for the native apps (Phase 2 and 3) to connect to.
