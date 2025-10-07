# Hướng dẫn upload repo_B lên GitHub

## Vấn đề hiện tại
ArgoCD không thể sync vì repo GitHub [Project_cms_CI_CD_FPT_repoB_DevOps](https://github.com/QuanMBL4255142/Project_cms_CI_CD_FPT_repoB_DevOps.git) đang trống.

## Giải pháp

### Cách 1: Upload thủ công qua GitHub Web UI

1. **Truy cập repo GitHub**: https://github.com/QuanMBL4255142/Project_cms_CI_CD_FPT_repoB_DevOps
2. **Tạo thư mục k8s**: Click "Create new file" → nhập `k8s/` → Enter
3. **Upload từng file**:
   - `k8s/namespace.yaml`
   - `k8s/configmap.yaml`
   - `k8s/secret.yaml`
   - `k8s/django-deployment.yaml`
   - `k8s/postgres-deployment.yaml`
   - `k8s/ingress.yaml`
   - `k8s/hpa.yaml`
   - `k8s/network-policy.yaml`
   - `k8s/pdb.yaml`
   - `argocd-application.yaml`

### Cách 2: Sử dụng GitHub CLI (nếu có)

```bash
# Cài đặt GitHub CLI
# Sau đó chạy:
gh auth login
gh repo clone QuanMBL4255142/Project_cms_CI_CD_FPT_repoB_DevOps
cd Project_cms_CI_CD_FPT_repoB_DevOps
# Copy files từ repo_B vào đây
git add .
git commit -m "Add ArgoCD and Kubernetes manifests"
git push
```

### Cách 3: Sử dụng Personal Access Token

1. **Tạo Personal Access Token**:
   - Vào GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
   - Generate new token với quyền `repo`
   - Copy token

2. **Cấu hình Git với token**:
```bash
git remote set-url origin https://YOUR_TOKEN@github.com/QuanMBL4255142/Project_cms_CI_CD_FPT_repoB_DevOps.git
git push -u origin main
```

## Sau khi upload thành công

1. **Kiểm tra repo GitHub** có thư mục `k8s/` với các manifest
2. **Chạy ArgoCD Application**:
```bash
kubectl apply -f argocd-application.yaml
```
3. **Kiểm tra trạng thái**:
```bash
kubectl get applications -n argocd
kubectl describe application django-product-api -n argocd-new
```

## Cấu trúc repo cần có:
```
Project_cms_CI_CD_FPT_repoB_DevOps/
├── k8s/
│   ├── namespace.yaml
│   ├── configmap.yaml
│   ├── secret.yaml
│   ├── django-deployment.yaml
│   ├── postgres-deployment.yaml
│   ├── ingress.yaml
│   ├── hpa.yaml
│   ├── network-policy.yaml
│   └── pdb.yaml
└── argocd-application.yaml
```
