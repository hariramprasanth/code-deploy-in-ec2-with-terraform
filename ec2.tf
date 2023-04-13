resource "aws_instance" "my_test_ec2_instance" {
  ami                         = "ami-0376ec8eacdf70aae"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  key_name                    = "my-test-ssh-key-pair"
  subnet_id                   = aws_subnet.my_subnet_test.id
  vpc_security_group_ids      = [aws_security_group.my_sg_ssh.id]
  user_data                   = file("./launch-instance.sh")
  iam_instance_profile        = aws_iam_instance_profile.Ec2_Role_Attachment.name
  tags = {
    Name    = "my-test-ec2-ssh"
    project = "web server"
  }
}

resource "aws_iam_instance_profile" "Ec2_Role_Attachment" {
  name = "Ec2-role-attachment"
  role = aws_iam_role.ec2_to_s3_read_role.name
}

resource "aws_iam_role" "ec2_to_s3_read_role" {
  name = "SpringWebServerEc2ToS3ReadRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "S3_Read_Policy" {
  policy_arn = aws_iam_policy.Web_server_s3_bucket_access_policy.arn
  role       = aws_iam_role.ec2_to_s3_read_role.name
}
