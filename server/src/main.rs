mod account;
mod auth;
mod config;
mod db;
mod email;
mod error;
mod push;
mod sync;
mod teams;

use std::net::SocketAddr;
use std::sync::Arc;

use axum::routing::{delete, get, post};
use sqlx::PgPool;
use tower_http::cors::{Any, CorsLayer};
use tower_http::trace::TraceLayer;
use tracing_subscriber::EnvFilter;

use crate::config::Config;
use crate::sync::relay::Relay;

#[derive(Clone)]
pub struct AppState {
    pub db: PgPool,
    pub config: Arc<Config>,
    pub relay: Relay,
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
        db: pool.clone(),
        config: Arc::new(config),
        relay: Relay::new(),
    };

    // Spawn envelope expiry cleanup task
    let cleanup_pool = pool.clone();
    tokio::spawn(async move {
        loop {
            tokio::time::sleep(tokio::time::Duration::from_secs(3600)).await;
            match sqlx::query("DELETE FROM envelope_queue WHERE expires_at < NOW()")
                .execute(&cleanup_pool)
                .await
            {
                Ok(r) => {
                    if r.rows_affected() > 0 {
                        tracing::info!("cleaned up {} expired envelopes", r.rows_affected());
                    }
                }
                Err(e) => tracing::error!("envelope cleanup failed: {e}"),
            }
        }
    });

    let cors = CorsLayer::new()
        .allow_origin(Any)
        .allow_methods(Any)
        .allow_headers(Any);

    let app = axum::Router::new()
        // Health
        .route("/health", get(health))
        // Auth (no JWT required)
        .route("/auth/send-code", post(auth::handlers::send_code))
        .route("/auth/verify", post(auth::handlers::verify))
        // Teams
        .route("/teams", post(teams::handlers::create_team))
        .route(
            "/teams/{invite_code}",
            get(teams::handlers::resolve_invite),
        )
        .route("/teams/{id}/join", post(teams::handlers::join_team))
        .route(
            "/teams/{id}/members/{email}",
            delete(teams::handlers::remove_member),
        )
        // Push
        .route("/push/register", post(push::handlers::register_push))
        // Account
        .route("/account", delete(account::handlers::delete_account))
        // WebSocket sync
        .route("/sync", get(sync::ws::ws_handler))
        // Middleware
        .layer(TraceLayer::new_for_http())
        .layer(cors)
        .with_state(state.clone());

    let addr = SocketAddr::from(([0, 0, 0, 0], state.config.port));
    tracing::info!("listening on {}", addr);

    let listener = tokio::net::TcpListener::bind(addr).await.unwrap();
    axum::serve(listener, app).await.unwrap();
}

async fn health() -> &'static str {
    "ok"
}
