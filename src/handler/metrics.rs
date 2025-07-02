use once_cell::sync::Lazy;
use warp::{Reply, Rejection};
use metrics_exporter_prometheus::{PrometheusBuilder, PrometheusHandle};
use warp::http::Response;

static PROMETHEUS_HANDLE: Lazy<PrometheusHandle> = Lazy::new(|| {
    PrometheusBuilder::new()
        .install_recorder()
        .expect("Failed to install Prometheus recorder")
});

pub async fn metrics_handler() -> Result<impl Reply, Rejection> {
    let body = PROMETHEUS_HANDLE.render();
    Ok(Response::builder()
        .header("Content-Type", "text/plain")
        .body(body)
        .unwrap())
}
