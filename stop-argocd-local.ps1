# Script để dừng ArgoCD và Django app
Write-Host "=== Dừng ArgoCD và Django App ===" -ForegroundColor Green

# Dừng port forwarding jobs
Write-Host "Dừng port forwarding..." -ForegroundColor Yellow
Get-Job | Where-Object { $_.State -eq "Running" } | Stop-Job
Get-Job | Remove-Job

# Xóa Django app
Write-Host "Xóa Django app..." -ForegroundColor Yellow
kubectl delete -f .\k8s\ingress.yaml --ignore-not-found=true
kubectl delete -f .\k8s\django-deployment.yaml --ignore-not-found=true
kubectl delete -f .\k8s\postgres-deployment.yaml --ignore-not-found=true
kubectl delete -f .\k8s\secret.yaml --ignore-not-found=true
kubectl delete -f .\k8s\configmap.yaml --ignore-not-found=true
kubectl delete -f .\k8s\namespace.yaml --ignore-not-found=true

# Xóa ArgoCD (tùy chọn)
$response = Read-Host "Bạn có muốn xóa ArgoCD không? (y/N)"
if ($response -eq "y" -or $response -eq "Y") {
    Write-Host "Xóa ArgoCD..." -ForegroundColor Yellow
    kubectl delete namespace argocd --ignore-not-found=true
}

Write-Host "=== Đã dừng tất cả services ===" -ForegroundColor Green
