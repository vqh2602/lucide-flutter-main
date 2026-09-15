# 🔑 Setup Personal Access Token (PAT) for Automated Publishing

## ❌ Vấn đề

GitHub Actions có hạn chế bảo mật: **Workflow được trigger bởi `GITHUB_TOKEN` KHÔNG thể trigger workflow khác**.

Khi workflow `auto_beta_version_bump.yml` tạo tag bằng `GITHUB_TOKEN`, nó **không trigger** workflow `publish_beta.yml`.

Ngoài ra, **OIDC authentication chỉ hoạt động khi workflow được trigger từ TAG**, không phải từ BRANCH.

## ✅ Giải pháp

Sử dụng **Personal Access Token (PAT)** để push tag. Khi tag được push bằng PAT, nó sẽ trigger workflow `publish_beta.yml` và OIDC sẽ hoạt động đúng.

---

## 📝 Hướng dẫn từng bước

### Bước 1: Tạo Personal Access Token

1. Vào GitHub → Click avatar → **Settings**
2. Sidebar bên trái → **Developer settings** (cuối cùng)
3. **Personal access tokens** → **Tokens (classic)**
4. Click **Generate new token (classic)**
5. Điền thông tin:
   - **Note**: `Lucide Flutter Auto Publish`
   - **Expiration**: `No expiration` (hoặc 1 year)
   - **Select scopes**:
     - ✅ `repo` (Full control of private repositories)
     - ✅ `workflow` (Update GitHub Action workflows)
6. Click **Generate token**
7. **⚠️ QUAN TRỌNG**: Copy token ngay (chỉ hiển thị 1 lần!)

### Bước 2: Thêm token vào GitHub Secrets

1. Vào repository: https://github.com/vqh2602/lucide-flutter-main
2. **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Điền:
   - **Name**: `PAT_TOKEN`
   - **Secret**: Paste token vừa copy
5. Click **Add secret**

### Bước 3: Cập nhật workflows

Sau khi thêm `PAT_TOKEN`, cần sửa 2 workflow files:

#### 📄 `auto_beta_version_bump.yml`

Thay đổi dòng 20 và 118:

```yaml
# Dòng 20: Checkout với PAT
- name: Checkout code
  uses: actions/checkout@v4
  with:
    fetch-depth: 0
    token: ${{ secrets.PAT_TOKEN }} # ← Thay GITHUB_TOKEN bằng PAT_TOKEN

# Dòng 118: Push tag với PAT
- name: Create and push Git tag
  env:
    GITHUB_TOKEN: ${{ secrets.PAT_TOKEN }} # ← Thêm dòng này
  run: |
    BETA_VERSION="${{ steps.beta_version.outputs.version }}"
    git tag -a "v$BETA_VERSION" -m "Beta Release v$BETA_VERSION"
    git push origin "v$BETA_VERSION"
```

#### 📄 `auto_version_bump.yml`

Thay đổi tương tự:

```yaml
# Dòng 30: Checkout với PAT
- name: Checkout code
  uses: actions/checkout@v4
  with:
    fetch-depth: 0
    token: ${{ secrets.PAT_TOKEN }} # ← Thay GITHUB_TOKEN bằng PAT_TOKEN

# Dòng 120: Push tag với PAT
- name: Create and push Git tag
  env:
    GITHUB_TOKEN: ${{ secrets.PAT_TOKEN }} # ← Thêm dòng này
  run: |
    NEW_VERSION="${{ steps.new_version.outputs.version }}"
    git tag -a "v$NEW_VERSION" -m "Release v$NEW_VERSION"
    git push origin "v$NEW_VERSION"
```

---

## 🚀 Quy trình sau khi setup

### Beta Release (từ `develop` branch):

```
1. Push code to develop
   ↓
2. auto_beta_version_bump.yml chạy:
   - Bump version → 3.1.14-beta.1
   - Commit & push changes
   - Tạo tag v3.1.14-beta.1 (dùng PAT_TOKEN)
   ↓
3. Tag trigger publish_beta.yml:
   - Checkout tại tag (OIDC refType = tag ✅)
   - Publish to pub.dev
   - Create GitHub Pre-release
```

### Stable Release (từ `main` branch):

```
1. Push code to main
   ↓
2. auto_version_bump.yml chạy:
   - Bump version → 3.2.0
   - Commit & push changes
   - Tạo tag v3.2.0 (dùng PAT_TOKEN)
   ↓
3. Tag trigger publish.yml:
   - Checkout tại tag (OIDC refType = tag ✅)
   - Publish to pub.dev
   - Create GitHub Release
```

---

## ⚠️ Lưu ý bảo mật

- **PAT có quyền rất cao** - Giữ bí mật tuyệt đối
- **Không commit PAT vào code** - Chỉ lưu trong GitHub Secrets
- **Nên set expiration** - Tạo token mới định kỳ (1 year)
- **Chỉ cấp quyền cần thiết** - `repo` và `workflow` là đủ

---

## 🔍 Kiểm tra

Sau khi setup xong, test bằng cách:

```bash
# Tạo commit test trên develop
git checkout develop
git commit --allow-empty -m "test: trigger beta release"
git push origin develop
```

Theo dõi tại: https://github.com/vqh2602/lucide-flutter-main/actions

Bạn sẽ thấy:

1. ✅ `Auto Beta Version Bump and Tag` chạy → tạo tag
2. ✅ `Publish Beta to pub.dev` tự động chạy → publish

---

## ❓ Troubleshooting

### Lỗi: "Resource not accessible by integration"

→ PAT chưa được thêm hoặc tên secret sai. Kiểm tra lại tên phải là `PAT_TOKEN`

### Lỗi: "publishing is only allowed from 'tag' refType"

→ Workflow vẫn đang dùng `GITHUB_TOKEN`. Đảm bảo đã sửa thành `PAT_TOKEN`

### Workflow publish không chạy

→ Kiểm tra tag pattern trong `publish_beta.yml` có match với tag được tạo không
