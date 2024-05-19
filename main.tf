provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_vpc" "tastylog-dev-vpc" {
  cidr_block = "192.168.0.0/20"

  // テナンシー: インスタンスが実行される物理ハードウェアを他のAWSアカウントと共有するか
  // default: 複数のAWSアカウントのインスタンスが同じサーバー上で動作することがある
  instance_tenancy = "default"

  tags = {
    Name = "tastylog-dev-vpc"
  }
}

resource "aws_subnet" "tastylog-dev-public-a" {
  vpc_id            = aws_vpc.tastylog-dev-vpc.id
  availability_zone = "ap-northeast-1a"
  cidr_block        = "192.168.1.0/24"

  tags = {
    Name = "tastylog-dev-public-a"
  }
}

resource "aws_subnet" "tastylog-dev-public-c" {
  vpc_id            = aws_vpc.tastylog-dev-vpc.id
  availability_zone = "ap-northeast-1c"
  cidr_block        = "192.168.2.0/24"

  tags = {
    Name = "tastylog-dev-public-c"
  }
}

resource "aws_subnet" "tastylog-dev-private-a" {
  vpc_id            = aws_vpc.tastylog-dev-vpc.id
  availability_zone = "ap-northeast-1a"
  cidr_block        = "192.168.3.0/24"

  tags = {
    Name = "tastylog-dev-private-a"
  }
}

resource "aws_subnet" "tastylog-dev-private-c" {
  vpc_id            = aws_vpc.tastylog-dev-vpc.id
  availability_zone = "ap-northeast-1c"
  cidr_block        = "192.168.4.0/24"

  tags = {
    Name = "tastylog-dev-private-c"
  }
}

resource "aws_route_table" "tastylog-dev-public-network" {
  vpc_id = aws_vpc.tastylog-dev-vpc.id

  tags = {
    Name = "tastylog-dev-public-network"
  }
}

resource "aws_route_table" "tastylog-dev-private-network" {
  vpc_id = aws_vpc.tastylog-dev-vpc.id

  tags = {
    Name = "tastylog-dev-private-network"
  }
}

resource "aws_route_table_association" "tastylog-dev-public-a" {
  subnet_id      = aws_subnet.tastylog-dev-public-a.id
  route_table_id = aws_route_table.tastylog-dev-public-network.id
}

resource "aws_route_table_association" "tastylog-dev-public-c" {
  subnet_id      = aws_subnet.tastylog-dev-public-c.id
  route_table_id = aws_route_table.tastylog-dev-public-network.id
}

resource "aws_route_table_association" "tastylog-dev-private-a" {
  subnet_id      = aws_subnet.tastylog-dev-private-a.id
  route_table_id = aws_route_table.tastylog-dev-private-network.id
}

resource "aws_route_table_association" "tastylog-dev-private-c" {
  subnet_id      = aws_subnet.tastylog-dev-private-c.id
  route_table_id = aws_route_table.tastylog-dev-private-network.id
}

resource "aws_security_group" "tastylog-dev-web-sg" {
  name        = "tastylog-dev-web-sg"
  vpc_id      = aws_vpc.tastylog-dev-vpc.id
  description = "testylog dev web security group"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tastylog-dev-web-sg"
  }
}

resource "aws_security_group_rule" "web_to_app" {
  type                     = "egress"
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.tastylog-dev-web-sg.id
  source_security_group_id = aws_security_group.tastylog-dev-app-sg.id
}

resource "aws_security_group" "tastylog-dev-app-sg" {
  name        = "tastylog-dev-app-sg"
  vpc_id      = aws_vpc.tastylog-dev-vpc.id
  description = "testylog dev app security group"

  egress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    prefix_list_ids = ["pl-61a54008"]
  }

  egress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    prefix_list_ids = ["pl-61a54008"]
  }

  tags = {
    Name = "tastylog-dev-app-sg"
  }
}

resource "aws_security_group_rule" "app_from_web" {
  type                     = "ingress"
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.tastylog-dev-app-sg.id
  source_security_group_id = aws_security_group.tastylog-dev-web-sg.id
}

resource "aws_security_group_rule" "app_to_db" {
  type                     = "egress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.tastylog-dev-app-sg.id
  source_security_group_id = aws_security_group.tastylog-dev-db-sg.id
}

resource "aws_security_group" "tastylog-dev-mng-sg" {
  name        = "tastylog-dev-mng-sg"
  vpc_id      = aws_vpc.tastylog-dev-vpc.id
  description = "testylog dev mng security group"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tastylog-dev-mng-sg"
  }
}

resource "aws_security_group" "tastylog-dev-db-sg" {
  name        = "tastylog-dev-db-sg"
  vpc_id      = aws_vpc.tastylog-dev-vpc.id
  description = "testylog dev db security group"

  tags = {
    Name = "tastylog-dev-db-sg"
  }
}

resource "aws_security_group_rule" "db_from_app" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.tastylog-dev-db-sg.id
  source_security_group_id = aws_security_group.tastylog-dev-app-sg.id
}