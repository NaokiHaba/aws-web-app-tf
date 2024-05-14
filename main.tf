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