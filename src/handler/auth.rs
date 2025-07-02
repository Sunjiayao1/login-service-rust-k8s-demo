use crate::errors::{AuthError, AuthErrorReason};
use base64::prelude::*;
use chrono::Utc;
use metrics::increment_counter;
use warp::reject;

const USERNAME: &str = "username";
const PASSWORD: &str = "password";

pub async fn authorize(auth_header: Option<String>) -> Result<impl warp::Reply, warp::Rejection> {
    match auth_header {
        Some(header) if validate_basic_auth(&header, USERNAME, PASSWORD) => {
            increment_counter!("login_success_total");
            Ok(warp::reply::html("Hello, protected endpoint! Authenticate!"))
        }
        Some(_) => {
            increment_counter!("login_failure_total");
            Err(reject::custom(AuthError {
                reason: AuthErrorReason::InvalidCredentials,
                timestamp: Utc::now(),
            }))
        }
        None => {
            increment_counter!("login_failure_total");
            Err(warp::reject::custom(AuthError {
                reason: AuthErrorReason::MissingCredentials,
                timestamp: Utc::now(),
            }))
        }
    }
}

fn validate_basic_auth(auth_header: &str, correct_user: &str, correct_password: &str) -> bool {
    if let Ok(auth) = BASE64_STANDARD.decode(auth_header.strip_prefix("Basic ").unwrap_or("")) {
        if let Ok(auth_str) = String::from_utf8(auth) {
            let mut parts = auth_str.splitn(2, ':');
            if let (Some(user), Some(password)) = (parts.next(), parts.next()) {
                return user == correct_user && password == correct_password;
            }
        }
    }
    false
}
