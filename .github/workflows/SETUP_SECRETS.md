# 🔐 HƯỚNG DẪN: Thêm Secrets vào GitHub

## Bước 1: Lấy Credentials

Bạn đã có credentials từ `dart pub login`. File location:

```
~/Library/Application Support/dart/pub-credentials.json
```

## Bước 2: Copy Tokens

Từ JSON output, copy 2 giá trị sau:

### ✅ PUB_DEV_ACCESS_TOKEN

```
token
```

### ✅ PUB_DEV_REFRESH_TOKEN

```
token
```

## Bước 3: Thêm vào GitHub Secrets

### 3.1. Mở GitHub Repository

```
https://github.com/vqh2602/lucide-flutter-main
```

### 3.2. Vào Settings → Secrets

1. Click tab **Settings** (góc trên bên phải)
2. Sidebar bên trái → Click **Secrets and variables** → **Actions**

### 3.3. Thêm Secret #1: PUB_DEV_ACCESS_TOKEN

1. Click nút **New repository secret** (màu xanh)
2. **Name**: `PUB_DEV_ACCESS_TOKEN`
3. **Secret**: Paste access token (chuỗi bắt đầu với `ya29.a0...`)
4. Click **Add secret**

### 3.4. Thêm Secret #2: PUB_DEV_REFRESH_TOKEN

1. Click nút **New repository secret** lần nữa
2. **Name**: `PUB_DEV_REFRESH_TOKEN`
3. **Secret**: Paste refresh token (chuỗi bắt đầu với `1//0e...`)
4. Click **Add secret**

## Bước 4: Verify

Sau khi thêm xong, bạn sẽ thấy 2 secrets:

- ✅ PUB_DEV_ACCESS_TOKEN
- ✅ PUB_DEV_REFRESH_TOKEN

⚠️ **Lưu ý**: Bạn không thể xem lại giá trị secret sau khi đã save. Chỉ có thể update hoặc xóa.

## Bước 5: Test Workflow

Tạo develop branch và test:

```bash
# Tạo develop branch
git checkout -b develop
git push -u origin develop

# Make a test change
echo "# Test workflow" >> README.md
git add README.md
git commit -m "test: beta workflow"
git push origin develop

# Check workflow
# → GitHub → Actions tab
# → Xem "Auto Publish Beta Version" workflow
```

---

## ⚠️ QUAN TRỌNG: Về Token Expiration

- **Access Token** (ya29...) hết hạn sau **1-2 giờ**
- **Refresh Token** (1//0e...) tồn tại **rất lâu** (tháng/năm)
- Workflow tự động dùng refresh token để renew access token
- **Bạn KHÔNG cần update secrets thường xuyên!**

Chỉ update khi workflow báo authentication error (rất hiếm).

---

## 📸 Screenshot Reference

Path to add secrets:

```
GitHub Repo
  └─ Settings
      └─ Secrets and variables
          └─ Actions
              └─ New repository secret
```

Form fields:

```
┌─────────────────────────────────────────┐
│ Name *                                  │
│ ┌─────────────────────────────────────┐ │
│ │ PUB_DEV_ACCESS_TOKEN                │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ Secret *                                │
│ ┌─────────────────────────────────────┐ │
│ │ ya29.a0ATi6K2t67o_M-W8f2Kcg...      │ │
│ │                                     │ │
│ └─────────────────────────────────────┘ │
│                                         │
│        [ Add secret ]                   │
└─────────────────────────────────────────┘
```

---

✅ **Hoàn tất!** Workflow đã sẵn sàng tự động publish!
