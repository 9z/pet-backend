#!/bin/bash

# AWS 설정
AWS_REGION="ap-northeast-2"
REPOSITORY_NAME="pet-backend"
AWS_PROFILE="personal"  # 사용할 AWS 프로필

echo "🚀 ECR 리포지토리를 생성합니다..."
echo "📋 사용 프로필: $AWS_PROFILE"

# ECR 리포지토리 생성
aws ecr create-repository \
    --repository-name "pet-backend" \
    --region "ap-northeast-2" \
    --profile "personal" \
    --image-scanning-configuration scanOnPush=true \
    --encryption-configuration encryptionType=AES256

# 생성 결과 확인
if [ $? -eq 0 ]; then
    echo "✅ ECR 리포지토리가 성공적으로 생성되었습니다!"
    
    # ECR 리포지토리 URI 출력
    REPOSITORY_URI=$(aws ecr describe-repositories --repository-names $REPOSITORY_NAME --region $AWS_REGION --profile $AWS_PROFILE --query 'repositories[0].repositoryUri' --output text)
    echo "📍 리포지토리 URI: $REPOSITORY_URI"
    
    echo ""
    echo "다음 명령어로 Docker 이미지를 푸시할 수 있습니다:"
    echo "aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $REPOSITORY_URI"
    echo "docker build -t $REPOSITORY_NAME ."
    echo "docker tag $REPOSITORY_NAME:latest $REPOSITORY_URI:latest"
    echo "docker push $REPOSITORY_URI:latest"
else
    echo "❌ ECR 리포지토리 생성에 실패했습니다."
    echo "AWS CLI가 설치되고 올바르게 구성되었는지 확인해주세요."
fi