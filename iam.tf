data "aws_iam_policy_document" "allow_s3_statefile_access" {
  statement {
    actions = [
      "s3:ListBucket",
    ]

    effect = "Allow"

    resources = [
      aws_s3_bucket.statefiles.arn,
    ]
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]

    effect = "Allow"

    resources = [
      "${aws_s3_bucket.statefiles.arn}/*",
    ]
  }
}

resource "aws_iam_policy" "allow_s3_statefile_access" {
  name        = "bpm-preview-s3-statefile"
  description = "Allow BPM preview provisioning role to manage statefiles"
  policy      = data.aws_iam_policy_document.allow_s3_statefile_access.json
}

data "aws_iam_policy_document" "allow_s3_bucket_management" {
  statement {
    actions = [
      "s3:CreateBucket",
      "s3:DeleteBucket",
      "s3:DeleteBucketPolicy",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion",
      "s3:GetAccelerateConfiguration",
      "s3:GetBucketAcl",
      "s3:GetBucketCORS",
      "s3:GetBucketLocation",
      "s3:GetBucketLogging",
      "s3:GetBucketNotification",
      "s3:GetBucketObjectLockConfiguration",
      "s3:GetBucketOwnershipControls",
      "s3:GetBucketPolicy",
      "s3:GetBucketPolicyStatus",
      "s3:GetBucketPublicAccessBlock",
      "s3:GetBucketRequestPayment",
      "s3:GetBucketTagging",
      "s3:GetBucketVersioning",
      "s3:GetBucketWebsite",
      "s3:GetEncryptionConfiguration",
      "s3:GetLifecycleConfiguration",
      "s3:GetReplicationConfiguration",
      "s3:ListBucket",
      "s3:ListBucketVersions",
      "s3:PutBucketPolicy",
      "s3:PutBucketPublicAccessBlock",
    ]

    effect = "Allow"

    resources = [
      "arn:aws:s3:::gatech-me-robojackets-bpm-preview-*"
    ]
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]

    effect = "Allow"

    resources = [
      "arn:aws:s3:::gatech-me-robojackets-bpm-preview-*/*",
    ]
  }
}

resource "aws_iam_policy" "allow_s3_bucket_management" {
  name        = "bpm-preview-s3-management"
  description = "Allow BPM preview provisioning role to manage S3 buckets and objects"
  policy      = data.aws_iam_policy_document.allow_s3_bucket_management.json
}

data "aws_iam_policy_document" "allow_cloudfront_management" {
  statement {
    actions = [
      "cloudfront:*"
    ]

    effect = "Allow"

    resources = [
      "arn:aws:cloudfront::771971951923:*"
    ]
  }
}

resource "aws_iam_policy" "allow_cloudfront_management" {
  name        = "bpm-preview-cloudfront-management"
  description = "Allow BPM preview provisioning role to manage CloudFront distributions"
  policy      = data.aws_iam_policy_document.allow_cloudfront_management.json
}

data "aws_iam_policy_document" "bpm_preview_provisioning_assume_role_policy" {
  statement {
    actions = [
      "sts:AssumeRoleWithWebIdentity",
    ]

    principals {
      type = "Federated"
      identifiers = [
        "arn:aws:iam::771971951923:oidc-provider/token.actions.githubusercontent.com",
      ]
    }

    condition {
      test = "StringEquals"
      values = [
        "sts.amazonaws.com",
      ]
      variable = "token.actions.githubusercontent.com:aud"
    }

    condition {
      test = "StringLike"
      values = [
        "repo:RoboJackets/business-process-manual:*"
      ]
      variable = "token.actions.githubusercontent.com:sub"
    }

    effect = "Allow"
  }
}

resource "aws_iam_role" "bpm_preview_provisioning" {
  assume_role_policy = data.aws_iam_policy_document.bpm_preview_provisioning_assume_role_policy.json

  description = "Provisions preview environments for business-process-manual"

  name = "bpm-preview-provisioning"

  max_session_duration = 3600
}

resource "aws_iam_role_policy_attachment" "attach_statefile_policy" {
  role       = aws_iam_role.bpm_preview_provisioning.name
  policy_arn = aws_iam_policy.allow_s3_statefile_access.arn
}

resource "aws_iam_role_policy_attachment" "attach_s3_management_policy" {
  role       = aws_iam_role.bpm_preview_provisioning.name
  policy_arn = aws_iam_policy.allow_s3_bucket_management.arn
}

resource "aws_iam_role_policy_attachment" "attach_cloudfront_policy" {
  role       = aws_iam_role.bpm_preview_provisioning.name
  policy_arn = aws_iam_policy.allow_cloudfront_management.arn
}
