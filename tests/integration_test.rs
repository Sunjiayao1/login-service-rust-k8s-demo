#[cfg(test)]
mod tests {
    use reqwest::Client;
    use tokio;
    use std::error::Error;
    use serde_json::Value;

    #[tokio::test]
    async fn test_public_endpoint() -> Result<(), Box<dyn Error>> {
        let response = reqwest::get("http://localhost:8081/healthz").await?;
        assert_eq!(response.status(), 200);
        let body = response.text().await?;
        assert_eq!(body, "Healthy!");
        Ok(())
    }

    #[tokio::test]
    async fn test_protected_endpoint_with_basic_auth() -> Result<(), Box<dyn Error>> {
        let client = Client::new();
        let response = client
            .get("http://localhost:8081/auth")
            .basic_auth("username", Some("password"))
            .send()
            .await?;
        assert_eq!(response.status(), 200);
        let body = response.text().await?;
        assert_eq!(body, "Hello, protected endpoint! Authenticate!");
        Ok(())
    }
}
