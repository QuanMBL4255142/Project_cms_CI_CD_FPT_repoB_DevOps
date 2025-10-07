# Script chính để chạy ArgoCD trên local
param(
    [switch]$SkipArgoCD,
    [switch]$SkipDjango
)

Write-Host "=== Triển khai ArgoCD và Django App trên Local ===" -ForegroundColor Green

# Kiểm tra kubectl và cluster
Write-Host "Kiểm tra Kubernetes cluster..." -ForegroundColor Yellow
try {
    kubectl cluster-info
    Write-Host "Kubernetes cluster đã sẵn sàng" -ForegroundColor Green
} catch {
    Write-Host "Lỗi: Không thể kết nối đến Kubernetes cluster" -ForegroundColor Red
    Write-Host "Hãy đảm bảo bạn đã khởi động một cluster (minikube, kind, hoặc Docker Desktop)" -ForegroundColor Yellow
    exit 1
}

# Cài đặt ArgoCD nếu chưa có
if (-not $SkipArgoCD) {
    Write-Host "=== Cài đặt ArgoCD ===" -ForegroundColor Green
    & .\setup-argocd.ps1
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Lỗi khi cài đặt ArgoCD" -ForegroundColor Red
        exit 1
    }
}

# Triển khai Django app nếu chưa có
if (-not $SkipDjango) {
    Write-Host "=== Triển khai Django App ===" -ForegroundColor Green
    
    # Triển khai Kubernetes manifests trực tiếp
    Write-Host "Triển khai Kubernetes manifests..." -ForegroundColor Yellow
    kubectl apply -f .\k8s\namespace.yaml
    kubectl apply -f .\k8s\configmap.yaml
    kubectl apply -f .\k8s\secret.yaml
    kubectl apply -f .\k8s\postgres-deployment.yaml
    kubectl apply -f .\k8s\django-deployment.yaml
    kubectl apply -f .\k8s\ingress.yaml
    
    # Chờ pods sẵn sàng
    Write-Host "Chờ Django app khởi động..." -ForegroundColor Yellow
    kubectl wait --for=condition=ready pod -l app=django-app -n django-product-api --timeout=300s
    kubectl wait --for=condition=ready pod -l app=postgres -n django-product-api --timeout=300s
}

# Thiết lập port forwarding
Write-Host "=== Thiết lập Port Forwarding ===" -ForegroundColor Green

# Port forward cho ArgoCD
Write-Host "Thiết lập port forward cho ArgoCD..." -ForegroundColor Yellow
$argocdJob = Start-Job -ScriptBlock {
    kubectl port-forward svc/argocd-server -n argocd 8080:443
}

# Port forward cho Django app
Write-Host "Thiết lập port forward cho Django app..." -ForegroundColor Yellow
$djangoJob = Start-Job -ScriptBlock {
    kubectl port-forward svc/django-service -n django-product-api 8000:8000
}

# Chờ port forwarding sẵn sàng
Start-Sleep -Seconds 3

# Lấy thông tin truy cập
Write-Host "=== Thông tin truy cập ===" -ForegroundColor Green
Write-Host "ArgoCD UI: https://localhost:8080" -ForegroundColor Cyan
Write-Host "Django API: http://localhost:8000" -ForegroundColor Cyan

# Lấy mật khẩu ArgoCD
try {
    $adminPassword = kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | ForEach-Object { [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_)) }
    Write-Host "ArgoCD Username: admin" -ForegroundColor Yellow
    Write-Host "ArgoCD Password: $adminPassword" -ForegroundColor Yellow
} catch {
    Write-Host "Không thể lấy mật khẩu ArgoCD" -ForegroundColor Red
}

Write-Host "=== Triển khai hoàn tất ===" -ForegroundColor Green
Write-Host "Để dừng port forwarding, chạy: Get-Job | Stop-Job" -ForegroundColor Yellow
Write-Host "Để xem logs: kubectl logs -f deployment/django-app -n django-product-api" -ForegroundColor Yellow
