resource "aws_codecommit_repository" "spring_web_server_repo" {
  repository_name = "spring-web-server-repo"
  tags = {
    project = "web server"
  }
}