variable "instance-type" {
    type = string
    default = "t2.micro"
}

variable "ami-id" {
    type = string
    default = "ami-08a52ddb321b32a8c"
}

variable "availability-zone" {
    type = string
    default = "us-east-1a"
}

variable "instance-id" {
    type = string
    default = "i-075359f2fa60c8dba"
}

variable "volume-id" {
    type = string
    default = "vol-0d31199e3d6929bef"
}

variable "bucket-name" {
    type = string
    default =  "terraform-aws-s3-static-website-0010"
}

