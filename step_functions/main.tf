provider "aws" {
  region     = "ap-northeast-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "aws_iam_role" "step_functions_role" {
  name = "step_functions_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "states.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "sample_step_functions_policy" {
  name = "sample_step_functions_policy"
  role = aws_iam_role.step_functions_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : [
          "lambda:InvokeFunction"
        ],
        "Resource" : [
          "arn:aws:lambda:ap-northeast-1:876462513854:function:random_test:*",
          "arn:aws:lambda:ap-northeast-1:876462513854:function:random_test"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "xray:PutTraceSegments",
          "xray:PutTelemetryRecords",
          "xray:GetSamplingRules",
          "xray:GetSamplingTargets"
        ],
        "Resource" : [
          "*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "appflow_full_access_attachment" {
  role       = aws_iam_role.step_functions_role.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonAppFlowFullAccess"
}

resource "aws_sfn_state_machine" "state_machine" {
  name     = "my_state_machine"
  role_arn = aws_iam_role.step_functions_role.arn

  definition = <<EOF
{
  "Comment": "sample state machine",
  "StartAt": "init",
  "States": {
    "init": {
      "Type": "Pass",
      "Next": "CanExecute",
      "ResultPath": "$.iter",
      "Result": {
        "items": [
          "1",
          "2",
          "3",
          "DONE"
        ]
      }
    },
    "CanExecute": {
      "Type": "Choice",
      "Choices": [
        {
          "Not": {
            "Variable": "$.iter.items[0]",
            "StringEquals": "DONE"
          },
          "Next": "Lambda Invoke"
        }
      ],
      "Default": "StartFlow"
    },
    "Lambda Invoke": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters": {
        "Payload.$": "$",
        "FunctionName": "arn:aws:lambda:ap-northeast-1:876462513854:function:random_test:$LATEST"
      },
      "Retry": [
        {
          "ErrorEquals": [
            "Lambda.ServiceException",
            "Lambda.AWSLambdaException",
            "Lambda.SdkClientException",
            "Lambda.TooManyRequestsException"
          ],
          "IntervalSeconds": 1,
          "MaxAttempts": 3,
          "BackoffRate": 2
        }
      ],
      "Next": "isResultTrue",
      "ResultPath": "$.output"
    },
    "isResultTrue": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.output.Payload.result",
          "NumericEquals": 1,
          "Comment": "isTrue",
          "Next": "StartFlow"
        },
        {
          "Variable": "$.output.Payload.result",
          "NumericEquals": 0,
          "Comment": "isFalse",
          "Next": "popElement"
        }
      ],
      "Default": "StartFlow"
    },
    "popElement": {
      "Type": "Pass",
      "Next": "CanExecute",
      "Parameters": {
        "iter": {
          "items.$": "$.iter.items[1:]"
        }
      }
    },
    "StartFlow": {
      "Type": "Task",
      "Parameters": {
        "FlowName": "flow"
      },
      "Resource": "arn:aws:states:::aws-sdk:appflow:startFlow",
      "Next": "Wait"
    },
    "Wait": {
      "Type": "Wait",
      "Seconds": 10,
      "Next": "DescribeFlow"
    },
    "DescribeFlow": {
      "Type": "Task",
      "Parameters": {
        "FlowName": "flow"
      },
      "Resource": "arn:aws:states:::aws-sdk:appflow:describeFlow",
      "Next": "DescribeFlowExecutionRecords"
    },
    "DescribeFlowExecutionRecords": {
      "Type": "Task",
      "End": true,
      "Parameters": {
        "FlowName": "flow"
      },
      "Resource": "arn:aws:states:::aws-sdk:appflow:describeFlowExecutionRecords"
    }
  }
}
EOF
}
