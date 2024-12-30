resource "aws_s3_bucket" "test" {
  bucket = "test-bucket"
  logging {
    target_bucket = "example"
  }
}
