#!/bin/bash

sudo yum update -y
sudo yum install -y jq curl
sudo yum install python3-pip -y


aws s3 cp s3://wsi-1234-test-artifactory/app.py .

sudo mkdir /var/log/app
sudo touch /var/log/app/app.log
sudo chown -R ec2-user:ec2-user /var/log/app
sudo chmod 755 /var/log/app

pip3 install flask

sudo yum install -y amazon-cloudwatch-agent

sudo tee /opt/aws/amazon-cloudwatch-agent/bin/config.json > /dev/null <<EOL
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/app/app.log",
            "log_group_name": "/aws/ec2/wsi",
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

nohup python3 app.py &
