use chrono::{DateTime, Utc};
use warp::{Rejection, Reply};
use warp::http::StatusCode;

#[derive(Debug)]
pub struct AuthError {
    pub timestamp: DateTime<Utc>,
    pub reason: AuthErrorReason,
}

#[derive(Debug)]
pub enum AuthErrorReason {
    InvalidCredentials,
    MissingCredentials,
}

impl warp::reject::Reject for AuthError {}

pub async fn auth_error(err: Rejection) -> Result<impl Reply, std::convert::Infallible> {
    if let Some(auth_error) = err.find::<AuthError>() {
        let message = match auth_error.reason {
            AuthErrorReason::MissingCredentials => "Missing Authorization Header.",
            AuthErrorReason::InvalidCredentials => "Invalid credential."
        };
        let json = warp::reply::json(&serde_json::json!({"error": message, "timestamp": auth_error.timestamp}));
        return Ok(warp::reply::with_status(json, StatusCode::UNAUTHORIZED));
    }
    Ok(warp::reply::with_status(
        warp::reply::json(&serde_json::json!({"error": "Unknown error."})),
        StatusCode::INTERNAL_SERVER_ERROR,
    ))
}
