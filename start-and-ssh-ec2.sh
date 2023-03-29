#!/bin/bash
##################################################
# Start EC2 instance and make ssh connection
# Arguments:
#   INSTANCE_ID: EC2 instance ID
#   KEY_PAIR: PATH of your keypair file
##################################################

set -euxo pipefail

# コマンドライン引数からインスタンスID、キーペアを取得
INSTANCE_ID="$1"
KEY_PAIR="$2"

# インスタンスの状態を取得
state=$(aws ec2 describe-instances \
  --instance-ids "${INSTANCE_ID}" \
  --query 'Reservations[0].Instances[0].State.Name' \
  --output text)

# インスタンスが起動していない場合は起動する
if [[ "${state}" != "running" ]]; then
  echo "Starting EC2 instance..."
  aws ec2 start-instances --instance-ids "${INSTANCE_ID}" >/dev/null
fi

# インスタンスが起動するまで待機する
echo "Waiting for EC2 instance to start..."
aws ec2 wait instance-running --instance-ids "${INSTANCE_ID}"

# グローバルIPアドレスを取得する
GLOBAL_IP=$(aws ec2 describe-instances \
  --instance-ids "${INSTANCE_ID}" \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text)

# ssh接続を試行する
echo "Connecting to EC2 instance..."
ssh -i "${KEY_PAIR}" ec2-user@"${GLOBAL_IP}"
