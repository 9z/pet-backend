#!/bin/bash

# AWS 설정
AWS_REGION="ap-northeast-2"
AWS_PROFILE="personal"
REPOSITORY_NAME="pet-backend"

echo "🚀 ECS 태스크 정의를 생성합니다..."
echo "📋 사용 프로필: $AWS_PROFILE"

# AWS 계정 ID 가져오기
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --profile $AWS_PROFILE --query Account --output text)
ECR_REPOSITORY_URI="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPOSITORY_NAME"

echo "📍 ECR URI: $ECR_REPOSITORY_URI"

# CloudWatch 로그 그룹 생성
echo "📝 CloudWatch 로그 그룹 생성 중..."
aws logs create-log-group \
    --log-group-name "/ecs/pet-backend" \
    --profile $AWS_PROFILE \
    --region $AWS_REGION 2>/dev/null || echo "로그 그룹이 이미 존재합니다."

# 태스크 정의 파일에서 플레이스홀더 교체
echo "🔄 태스크 정의 파일 준비 중..."
sed "s|\[AWS_ACCOUNT_ID\]|$AWS_ACCOUNT_ID|g; s|\[ECR_REPOSITORY_URI\]|$ECR_REPOSITORY_URI|g" \
    deploy/task-definition.json > deploy/task-definition-final.json

# 태스크 정의 등록
echo "📋 태스크 정의 등록 중..."
aws ecs register-task-definition \
    --cli-input-json file://deploy/task-definition-final.json \
    --profile $AWS_PROFILE \
    --region $AWS_REGION

if [ $? -eq 0 ]; then
    echo "✅ ECS 태스크 정의가 성공적으로 생성되었습니다!"
    
    # 생성된 태스크 정의 확인
    echo "🔍 태스크 정의 상태 확인 중..."
    aws ecs describe-task-definition \
        --task-definition pet-backend-task \
        --profile $AWS_PROFILE \
        --region $AWS_REGION \
        --query 'taskDefinition.{Family:family,Revision:revision,Status:status,Cpu:cpu,Memory:memory}' \
        --output table
    
    # 임시 파일 정리
    rm -f deploy/task-definition-final.json
else
    echo "❌ ECS 태스크 정의 생성에 실패했습니다."
    rm -f deploy/task-definition-final.json
    exit 1
fi