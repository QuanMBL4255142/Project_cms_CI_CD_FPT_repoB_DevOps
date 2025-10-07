# Script deploy trực tiếp các manifest Kubernetes
# Sử dụng khi ArgoCD chưa hoạt động

Write-Host "🚀 Bắt đầu deploy trực tiếp các manifest..." -ForegroundColor Green

# 1. Tạo namespace
Write-Host "🏗️ Tạo namespace..." -ForegroundColor Yellow
kubectl apply -f k8s/namespace.yaml

# 2. Tạo ConfigMap và Secret
Write-Host "🔧 Tạo ConfigMap và Secret..." -ForegroundColor Yellow
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secret.yaml

# 3. Deploy PostgreSQL
Write-Host "🗄️ Deploy PostgreSQL..." -ForegroundColor Yellow
kubectl apply -f k8s/postgres-deployment.yaml

# 4. Đợi PostgreSQL sẵn sàng
Write-Host "⏳ Đợi PostgreSQL sẵn sàng..." -ForegroundColor Yellow
kubectl wait --for=condition=ready pod -l app=postgres -n argocd-new --timeout=300s

# 5. Deploy Django
Write-Host "🐍 Deploy Django..." -ForegroundColor Yellow
kubectl apply -f k8s/django-deployment.yaml

# 6. Deploy Ingress
Write-Host "🌐 Deploy Ingress..." -ForegroundColor Yellow
kubectl apply -f k8s/ingress.yaml

# 7. Deploy HPA
Write-Host "📊 Deploy HPA..." -ForegroundColor Yellow
kubectl apply -f k8s/hpa.yaml

# 8. Deploy Network Policy
Write-Host "🔒 Deploy Network Policy..." -ForegroundColor Yellow
kubectl apply -f k8s/network-policy.yaml

# 9. Deploy PodDisruptionBudget
Write-Host "🛡️ Deploy PodDisruptionBudget..." -ForegroundColor Yellow
kubectl apply -f k8s/pdb.yaml

# 10. Kiểm tra trạng thái
Write-Host "📊 Kiểm tra trạng thái..." -ForegroundColor Yellow
kubectl get all -n argocd-new

# 11. Kiểm tra pods
Write-Host "🐳 Kiểm tra pods..." -ForegroundColor Yellow
kubectl get pods -n argocd-new -o wide

# 12. Kiểm tra services
Write-Host "🌐 Kiểm tra services..." -ForegroundColor Yellow
kubectl get services -n argocd-new

# 13. Kiểm tra ingress
Write-Host "🚪 Kiểm tra ingress..." -ForegroundColor Yellow
kubectl get ingress -n argocd-new

# 14. Kiểm tra logs Django
Write-Host "📋 Kiểm tra logs Django..." -ForegroundColor Yellow
kubectl logs -n argocd-new -l app=django-app --tail=10

Write-Host "✅ Hoàn thành deploy!" -ForegroundColor Green
Write-Host "🌐 Truy cập Django API tại: http://django.local" -ForegroundColor Cyan
Write-Host "📊 Kiem tra trang thai: kubectl get all -n argocd-new" -ForegroundColor Cyan
