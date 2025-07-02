#[cfg(test)]
mod tests {
    use tokio;
    use std::error::Error;
    use warp::Filter;
    use warp::test::request;

    fn api_filter() -> impl Filter<Extract = impl warp::Reply, Error = warp::Rejection> + Clone {
        warp::path("healthz").map(|| "Healthy!")
            .or(warp::path("auth")
                .and(warp::header::exact("authorization", "Basic dXNlcm5hbWU6cGFzc3dvcmQ=")) // base64 username:password
                .map(|| "Hello, protected endpoint! Authenticate!"))
    }

    #[tokio::test]
    async fn test_public_endpoint() -> Result<(), Box<dyn Error>> {
        let filter = api_filter();
        let resp = request()
            .method("GET")
            .path("/healthz")
            .reply(&filter)
            .await;

        assert_eq!(resp.status(), 200);
        assert_eq!(resp.body(), "Healthy!");
        Ok(())
    }

    #[tokio::test]
    async fn test_protected_endpoint_with_basic_auth() -> Result<(), Box<dyn Error>> {
        let filter = api_filter();
        let auth_header_value = "Basic dXNlcm5hbWU6cGFzc3dvcmQ=";

        let resp = request()
            .method("GET")
            .path("/auth")
            .header("authorization", auth_header_value)
            .reply(&filter)
            .await;

        assert_eq!(resp.status(), 200);
        assert_eq!(resp.body(), "Hello, protected endpoint! Authenticate!");
        Ok(())
    }
}
