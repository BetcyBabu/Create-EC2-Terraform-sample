
provider "aws" {
  region     = var.region
  access_key = var.accesskey
  secret_key = var.seckey
}

resource "aws_key_pair" "newkey" {
  key_name   = "newkey"
  public_key = file("terraform")
}

resource "aws_security_group" "webserver03" {
  name        = "allow_webserver"
  description = "Allow http/s inbound traffic"

  ingress = [
      
    {
    description      = ""
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    prefix_list_ids = []
    security_groups = []
    self = false

    },
    
    {
    description      = ""
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    prefix_list_ids = []
    security_groups = []
    self = false
    },
    
    ]

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_http"
  }

  lifecycle {
    create_before_destroy = true
  }
  
}


resource "aws_security_group" "allow_ssh03" {
  name        = "allow_ssh"
  description = "Allow ssh inbound traffic"

  ingress {
    description      = ""
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_instance" "web" {
  ami           = var.ami
  instance_type = var.type
  associate_public_ip_address = "true"
  key_name = aws_key_pair.newkey.id
  vpc_security_group_ids = [aws_security_group.allow_ssh03.id, aws_security_group.webserver03.id]
  user_data = file("userdata.sh")

  tags = {
    Name = "web"
  }
}