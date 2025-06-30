mod errors;
mod auth;
mod router;

#[tokio::main]
async fn main() {
    println!("Starting login-service on 0.0.0.0:8081");
    let routes = router::routes_filter();
    warp::serve(routes).run(([0, 0, 0, 0], 8081)).await;
}
