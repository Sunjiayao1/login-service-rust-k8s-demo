use warp::{Reply, Rejection};
use metrics::increment_counter;

pub async fn healthz_handler() -> Result<impl Reply, Rejection> {
    increment_counter!("requests_healthz_total");
    Ok(warp::reply::html("Healthy!"))
}
