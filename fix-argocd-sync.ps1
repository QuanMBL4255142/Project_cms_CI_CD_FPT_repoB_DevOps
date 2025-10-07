# Script khắc phục lỗi ArgoCD sync - Phiên bản cải tiến
# Chạy script này để khắc phục vấn đề sync trong ArgoCD

Write-Host "🔧 Bắt đầu khắc phục lỗi ArgoCD sync..." -ForegroundColor Green

# 1. Kiểm tra trạng thái ArgoCD
Write-Host "📊 Kiểm tra trạng thái ArgoCD..." -ForegroundColor Yellow
kubectl get applications -n argocd

# 2. Kiểm tra namespace
Write-Host "🏗️ Kiểm tra namespace..." -ForegroundColor Yellow
kubectl get namespace argocd-new

# 3. Xóa application cũ nếu có lỗi
Write-Host "🗑️ Xóa application cũ nếu có lỗi..." -ForegroundColor Yellow
kubectl delete application django-product-api -n argocd-new --ignore-not-found=true

# 4. Đợi namespace được tạo
Write-Host "⏳ Đợi namespace được tạo..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# 5. Tạo namespace nếu chưa có
Write-Host "🏗️ Tạo namespace nếu chưa có..." -ForegroundColor Yellow
kubectl apply -f k8s/namespace.yaml

# 6. Tạo lại application
Write-Host "🚀 Tạo lại ArgoCD Application..." -ForegroundColor Yellow
kubectl apply -f argocd-application.yaml

# 7. Đợi application được tạo
Write-Host "⏳ Đợi application được tạo..." -ForegroundColor Yellow
Start-Sleep -Seconds 20

# 8. Kiểm tra trạng thái sync
Write-Host "📈 Kiểm tra trạng thái sync..." -ForegroundColor Yellow
kubectl get applications -n argocd
kubectl describe application django-product-api -n argocd-new

# 9. Kiểm tra pods
Write-Host "🐳 Kiểm tra trạng thái pods..." -ForegroundColor Yellow
kubectl get pods -n argocd-new -o wide

# 10. Kiểm tra services
Write-Host "🌐 Kiểm tra services..." -ForegroundColor Yellow
kubectl get services -n argocd-new

# 11. Kiểm tra ingress
Write-Host "🚪 Kiểm tra ingress..." -ForegroundColor Yellow
kubectl get ingress -n argocd-new

# 12. Kiểm tra logs nếu có lỗi
Write-Host "📋 Kiểm tra logs ArgoCD..." -ForegroundColor Yellow
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server --tail=20

# 13. Kiểm tra logs Django nếu có
Write-Host "📋 Kiểm tra logs Django..." -ForegroundColor Yellow
kubectl logs -n argocd-new -l app=django-app --tail=10

# 14. Kiểm tra events
Write-Host "📋 Kiểm tra events..." -ForegroundColor Yellow
kubectl get events -n argocd-new --sort-by='.lastTimestamp'

Write-Host "✅ Hoàn thành khắc phục lỗi ArgoCD!" -ForegroundColor Green
Write-Host "🌐 Truy cập ArgoCD UI tại: http://localhost:8080" -ForegroundColor Cyan
Write-Host "🌐 Truy cập Django API tại: http://django.local" -ForegroundColor Cyan
Write-Host "📊 Kiem tra trang thai: kubectl get all -n argocd-new" -ForegroundColor Cyan
