###############################
# Bucket for Terraform Plans
###############################
resource "aws_s3_bucket" "terraform_plans" {
  bucket = "${var.identifier}-${var.environment}-terraform-plan"
}

resource "aws_s3_bucket_public_access_block" "terraform_plans-block-public" {
  bucket                  = aws_s3_bucket.terraform_plans.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


####################################
# Bucket for Terraform State Files
####################################
resource "aws_s3_bucket" "terraform_state_files" {
  bucket = "${var.identifier}-${var.environment}-terraform-state-files"
}

resource "aws_s3_bucket_public_access_block" "terraform_state_files-block-public" {
  bucket                  = aws_s3_bucket.terraform_state_files.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}