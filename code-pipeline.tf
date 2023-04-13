resource "aws_codepipeline" "spring_web_server_pipeline" {
  name     = "spring-web-server-pipeline"
  role_arn = aws_iam_role.web_server_codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.web_server_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source-artifact"]
      configuration = {
        RepositoryName = "${aws_codecommit_repository.spring_web_server_repo.repository_name}"
        BranchName     = "main"
      }
    }
  }

  stage {
    name = "Build"
    action {
      name             = "WebServerBuild"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source-artifact"]
      output_artifacts = ["web-server-build-artifacts"]
      configuration = {
        ProjectName = aws_codebuild_project.spring_web_server_build.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name             = "WebserverDeploy"
      category         = "Deploy"
      owner            = "AWS"
      provider         = "CodeDeploy"
      version          = "1"
      input_artifacts  = ["web-server-build-artifacts"]
      output_artifacts = []
      configuration = {
        ApplicationName     = "${aws_codedeploy_app.Spring_web_server_app.name}"
        DeploymentGroupName = "${aws_codedeploy_deployment_group.spring_webserver_code_deployment_group.deployment_group_name}"
      }
    }
  }

  tags = {
    project = "web server"
  }
}

resource "aws_iam_role" "web_server_codepipeline_role" {
  name = "SpringWebServerPipelineRole"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "codepipeline.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
  tags = {
    project = "web server"
  }
}

resource "aws_iam_role_policy" "web_server_codepipeline_policy" {
  name = "SpringWebServerPipelineRole"
  role = aws_iam_role.web_server_codepipeline_role.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "codecommit:UploadArchive",
          "codecommit:Get*",
        ],
        "Resource" : aws_codecommit_repository.spring_web_server_repo.arn
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild",
        ],
        "Resource" : "${aws_codebuild_project.spring_web_server_build.arn}"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "codedeploy:*"
        ]
        "Resource" : ["${aws_codedeploy_deployment_group.spring_webserver_code_deployment_group.arn}", "arn:aws:codedeploy:*:*:deploymentconfig:*", "${aws_codedeploy_app.Spring_web_server_app.arn}"]
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_s3_bucket_policy_web_server_codepipeline" {
  role       = aws_iam_role.web_server_codepipeline_role.id
  policy_arn = aws_iam_policy.Web_server_s3_bucket_access_policy.arn
}