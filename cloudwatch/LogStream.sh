#!/bin/bash

sudo yum update -y

sudo yum install -y amazon-cloudwatch-agent

sudo tee /opt/aws/amazon-cloudwatch-agent/bin/config.json > /dev/null <<EOL
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/Logfilepath",
            "log_group_name": "/groupname",
            "log_stream_name": "api_{instance_id}",
            "timestamp_format": "%Y-%m-%d %H:%M:%S"
          }
        ]
      }
    }
  }
}
EOL

sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s
