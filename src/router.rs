use warp::{Filter, Rejection, Reply};
use crate::errors;
use crate::handler::{
    healthz::healthz_handler,
    metrics::metrics_handler,
    auth::authorize,
};

pub fn routes_filter() -> impl Filter<Extract=impl Reply, Error=Rejection> + Clone {
    let healthz = warp::path("healthz").and_then(healthz_handler);
    let metrics = warp::path("metrics").and_then(metrics_handler);
    let auth = warp::path("auth")
        .and(warp::filters::header::optional::<String>("authorization"))
        .and_then(authorize)
        .recover(errors::auth_error);

    warp::get().and(healthz.or(metrics).or(auth))
}
