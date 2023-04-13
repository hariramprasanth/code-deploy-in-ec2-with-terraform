resource "aws_codedeploy_app" "Spring_web_server_app" {
  compute_platform = "Server"
  name             = "SpringWebServerApp"
}