resource "aws_codebuild_project" "spring_web_server_build" {
  name          = "spring-web-server-build"
  build_timeout = "20"
  service_role  = aws_iam_role.spring_web_server_code_build_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true
  }
  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }

  tags = {
    project = "web server"
  }
}

resource "aws_iam_role" "spring_web_server_code_build_role" {
  name = "SpringWebServerBuildRole"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "codebuild.amazonaws.com"
          },
          "Action" : "sts:AssumeRole"
        }
      ]
  })
}
resource "aws_iam_role_policy" "web_server_codebuild_policy" {
  name = "WebServerBuildPolicy"
  role = aws_iam_role.spring_web_server_code_build_role.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Resource" : [
          "*"
        ],
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
      },
    ]
  })
}


resource "aws_iam_role_policy_attachment" "code_build_policy_attach" {
  role       = aws_iam_role.spring_web_server_code_build_role.name
  policy_arn = aws_iam_policy.Web_server_s3_bucket_access_policy.arn
}

