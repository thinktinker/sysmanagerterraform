terraform {
  backend "s3" {
    bucket = "martin-us-east-2-ssm-state-bucket"  #Bucket used to store the terraform states
    key    = "martin-ssm-demo.tfstate"    #Change the value  of this to yourname-ssm.tfstate for  example
    region = "us-east-2"                  #Set the state at which the bucket is
  }
}