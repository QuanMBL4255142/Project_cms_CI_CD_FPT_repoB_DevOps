# Script cài đặt ArgoCD
Write-Host "=== Cài đặt ArgoCD ===" -ForegroundColor Green

# Tạo namespace argocd nếu chưa có
Write-Host "Tạo namespace argocd..." -ForegroundColor Yellow
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

# Cài đặt ArgoCD
Write-Host "Cài đặt ArgoCD..." -ForegroundColor Yellow
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Chờ ArgoCD pods sẵn sàng
Write-Host "Chờ ArgoCD khởi động..." -ForegroundColor Yellow
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s

Write-Host "ArgoCD đã được cài đặt thành công!" -ForegroundColor Green
