#!/bin/bash

# AWS 설정
AWS_REGION="ap-northeast-2"
REPOSITORY_NAME="pet-backend"
AWS_PROFILE="personal"  # 사용할 AWS 프로필
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --profile $AWS_PROFILE --query Account --output text)
REPOSITORY_URI="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPOSITORY_NAME"

echo "🚀 Docker 이미지를 ECR에 푸시합니다..."
echo "📋 사용 프로필: $AWS_PROFILE"
echo "📍 리포지토리: $REPOSITORY_URI"

# ECR에 로그인
echo "🔐 ECR에 로그인 중..."
aws ecr get-login-password --region $AWS_REGION --profile $AWS_PROFILE | docker login --username AWS --password-stdin $REPOSITORY_URI

if [ $? -ne 0 ]; then
    echo "❌ ECR 로그인에 실패했습니다."
    exit 1
fi

# Docker 이미지 빌드
echo "🔨 Docker 이미지를 빌드 중..."
docker build -t $REPOSITORY_NAME .

if [ $? -ne 0 ]; then
    echo "❌ Docker 이미지 빌드에 실패했습니다."
    exit 1
fi

# 타임스탬프 태그 생성
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

# 이미지 태깅
echo "🏷️ 이미지를 태깅 중..."
docker tag $REPOSITORY_NAME:latest $REPOSITORY_URI:latest
docker tag $REPOSITORY_NAME:latest $REPOSITORY_URI:$TIMESTAMP

echo "📋 생성된 태그: latest, $TIMESTAMP"

# 이미지 푸시
echo "📤 이미지를 ECR에 푸시 중..."
docker push $REPOSITORY_URI:latest

if [ $? -eq 0 ]; then
    echo "✅ latest 태그 푸시 완료"
    
    docker push $REPOSITORY_URI:$TIMESTAMP
    
    if [ $? -eq 0 ]; then
        echo "✅ $TIMESTAMP 태그 푸시 완료"
    else
        echo "❌ $TIMESTAMP 태그 푸시 실패"
    fi
else
    echo "❌ latest 태그 푸시 실패"
    exit 1
fi

if [ $? -eq 0 ]; then
    echo "✅ 이미지가 성공적으로 ECR에 푸시되었습니다!"
    echo "📍 이미지 URI: $REPOSITORY_URI:latest"
else
    echo "❌ 이미지 푸시에 실패했습니다."
    exit 1
fi