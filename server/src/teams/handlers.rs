use axum::extract::{Path, State};
use axum::Json;
use rand::distributions::Alphanumeric;
use rand::Rng;
use serde::{Deserialize, Serialize};
use uuid::Uuid;

use crate::auth::jwt::AuthUser;
use crate::error::AppError;
use crate::AppState;

fn generate_invite_code() -> String {
    let code: String = rand::thread_rng()
        .sample_iter(&Alphanumeric)
        .take(8)
        .map(char::from)
        .collect();
    code.to_uppercase()
}

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
        "SELECT id, name FROM teams WHERE invite_code = $1",
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

pub async fn join_team(
    State(state): State<AppState>,
    auth: AuthUser,
    Path(team_id): Path<Uuid>,
) -> Result<Json<serde_json::Value>, AppError> {
    let exists =
        sqlx::query_scalar::<_, bool>("SELECT EXISTS(SELECT 1 FROM teams WHERE id = $1)")
            .bind(team_id)
            .fetch_one(&state.db)
            .await?;

    if !exists {
        return Err(AppError::NotFound);
    }

    sqlx::query(
        "INSERT INTO team_members (team_id, email, role) VALUES ($1, $2, 'member') ON CONFLICT DO NOTHING",
    )
    .bind(team_id)
    .bind(&auth.email)
    .execute(&state.db)
    .await?;

    Ok(Json(serde_json::json!({ "message": "joined" })))
}

pub async fn remove_member(
    State(state): State<AppState>,
    auth: AuthUser,
    Path((team_id, member_email)): Path<(Uuid, String)>,
) -> Result<Json<serde_json::Value>, AppError> {
    // Check requester is a leader
    let role = sqlx::query_scalar::<_, String>(
        "SELECT role FROM team_members WHERE team_id = $1 AND email = $2",
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
            "SELECT COUNT(*) FROM team_members WHERE team_id = $1 AND role = 'leader'",
        )
        .bind(team_id)
        .fetch_one(&state.db)
        .await?;

        if leader_count <= 1 {
            return Err(AppError::BadRequest(
                "cannot remove the last leader".into(),
            ));
        }
    }

    sqlx::query("DELETE FROM team_members WHERE team_id = $1 AND email = $2")
        .bind(team_id)
        .bind(&member_email)
        .execute(&state.db)
        .await?;

    Ok(Json(serde_json::json!({ "message": "removed" })))
}
