#!/bin/bash

# AWS 설정
AWS_REGION="ap-northeast-2"
AWS_PROFILE="personal"
CLUSTER_NAME="pet-backend-cluster"

echo "🚀 ECS 클러스터를 생성합니다..."
echo "📋 사용 프로필: $AWS_PROFILE"
echo "🏗️ 클러스터 이름: $CLUSTER_NAME"

# ECS 클러스터 생성 (Fargate 사용)
aws ecs create-cluster \
    --cluster-name $CLUSTER_NAME \
    --capacity-providers FARGATE \
    --default-capacity-provider-strategy capacityProvider=FARGATE,weight=1 \
    --profile $AWS_PROFILE \
    --region $AWS_REGION

if [ $? -eq 0 ]; then
    echo "✅ ECS 클러스터가 성공적으로 생성되었습니다!"
    echo "📍 클러스터 이름: $CLUSTER_NAME"
    
    # 클러스터 상태 확인
    echo "🔍 클러스터 상태 확인 중..."
    aws ecs describe-clusters \
        --clusters $CLUSTER_NAME \
        --profile $AWS_PROFILE \
        --region $AWS_REGION \
        --query 'clusters[0].{Name:clusterName,Status:status,ActiveServicesCount:activeServicesCount,RunningTasksCount:runningTasksCount}' \
        --output table
else
    echo "❌ ECS 클러스터 생성에 실패했습니다."
    exit 1
fi