use base64::prelude::*;
use chrono::Utc;
use crate::errors::{AuthError, AuthErrorReason};

pub async fn authorize(auth_header: Option<String>) -> Result<impl warp::Reply, warp::Rejection> {
    let username = "username";
    let password = "password";
    if let Some(auth_header) = auth_header {
        if validate_basic_auth(&auth_header, &username, &password) {
            Ok(warp::reply::html("Hello, protected endpoint! Authenticate!"))
        } else {
            Err(warp::reject::custom(AuthError {
                reason: AuthErrorReason::InvalidCredentials,
                timestamp: Utc::now(),
            }))
        }
    } else {
        Err(warp::reject::custom(AuthError {
            reason: AuthErrorReason::MissingCredentials,
            timestamp: Utc::now(),
        }))
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
