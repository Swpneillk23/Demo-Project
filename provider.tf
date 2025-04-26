
provider "aws" {
    region = "us-east-1"
    profile = "Vscode"
}


terraform {
    required_version = ">=1.9"
    required_providers {
        aws ={
            source = "hashicorp/aws"
            version = "5.0.0"
        }

    }
}