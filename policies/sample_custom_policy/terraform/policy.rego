package policies.sample_custom_policy

input_type := "tf"

resource_type := "aws_s3_bucket"

default allow = false

allow {
  input.logging[_].target_bucket = "example"
}
