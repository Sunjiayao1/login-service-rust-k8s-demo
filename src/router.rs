use warp::{Filter, Rejection, Reply};
use crate::auth::authorize;
use crate::errors;

pub fn routes_filter() -> impl Filter<Extract=impl Reply, Error=Rejection> + Clone {
    warp::get().and(
        warp::path("healthz")
            .map(|| { warp::reply::html("Healthy!") })
            .or(
                warp::path("auth")
                    .and(warp::filters::header::optional::<String>("authorization"))
                    .and_then(authorize)
                    .recover(errors::auth_error)
            )
    )
}
