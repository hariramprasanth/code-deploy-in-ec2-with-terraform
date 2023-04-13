resource "aws_codedeploy_deployment_group" "spring_webserver_code_deployment_group" {
  app_name              = aws_codedeploy_app.Spring_web_server_app.name
  deployment_group_name = "spring-webserver-code-deployment-group"
  service_role_arn      = aws_iam_role.web_server_code_deploy_role.arn

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "my-test-ec2-ssh"
    }
  }
  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

}



resource "aws_iam_role" "web_server_code_deploy_role" {
  name = "web-server-code-deploy-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "codedeploy.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "AWSCodeDeployRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role       = aws_iam_role.web_server_code_deploy_role.name
}