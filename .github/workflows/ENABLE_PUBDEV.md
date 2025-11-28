# 🚨 FIX: Workflow publish không chạy

## ❌ Vấn đề

- ✅ Workflow bump version chạy
- ✅ Tag được tạo (v3.1.10-beta.1)
- ❌ Workflow publish KHÔNG chạy

## 🔍 Nguyên nhân

**Bạn CHƯA enable "Automated Publishing" trên pub.dev!**

OIDC requires pub.dev to be configured TRƯỚC KHI workflows có thể publish.

---

## ✅ Giải pháp: Enable trên pub.dev (5 phút)

### Bước 1: Đăng nhập pub.dev

Vào: https://pub.dev/

Click **"Sign in"** (góc trên bên phải)

### Bước 2: Navigate to Admin Page

Vào trực tiếp:

```
https://pub.dev/packages/lucide_icons_flutter/admin
```

Hoặc:

1. Tìm package: https://pub.dev/packages/lucide_icons_flutter
2. Click tab **"Admin"**

> [!IMPORTANT] > **Yêu cầu quyền**:
>
> - Bạn phải là **Uploader** của package, HOẶC
> - Bạn phải là **Admin** của publisher (nếu package thuộc publisher)
>
> Nếu không có quyền, bạn sẽ không thấy tab "Admin"!

### Bước 3: Tìm section "Automated publishing"

Scroll xuống tìm section:

```
┌─────────────────────────────────────┐
│ Automated publishing                │
│                                     │
│ [Enable publishing from GitHub      │
│  Actions]                           │
└─────────────────────────────────────┘
```

### Bước 4: Click "Enable publishing from GitHub Actions"

Một form sẽ hiện ra với 2 fields:

#### Field 1: Repository

```
vqh2602/lucide-flutter-main
```

Format: `<organization>/<repository>`

#### Field 2: Tag pattern

```
v{{version}}
```

> [!IMPORTANT] > **Tag Pattern Options**:
>
> **Option A - Single pattern (KHUYẾN NGHỊ):**
>
> ```
> v{{version}}
> ```
>
> - Matches: v3.2.0, v3.1.7-beta.1, v4.0.0-beta.2
> - Đơn giản nhất, cover cả stable và beta
>
> **Option B - Separate patterns:**
> Nếu muốn control riêng biệt, phải setup 2 lần:
>
> - Stable: `v{{version}}` (chỉ match v3.2.0, v4.0.0)
> - Beta: `v{{version}}-beta.*` (chỉ match beta versions)

**Khuyến nghị**: Dùng `v{{version}}` để đơn giản!

### Bước 5: Click "Save" hoặc "Enable"

Sau khi save, bạn sẽ thấy:

```
✅ Automated publishing enabled
Repository: vqh2602/lucide-flutter-main
Tag pattern: v{{version}}
```

---

## 🧪 Test Workflow

### Option 1: Trigger manual từ existing tag

```bash
# Xem tags hiện có
git tag -l "v3.1.*-beta.*"

# Xóa tag local và remote (để test lại)
git tag -d v3.1.10-beta.1
git push origin --delete v3.1.10-beta.1

# Push lại tag (trigger workflow)
git tag v3.1.10-beta.1
git push origin v3.1.10-beta.1
```

### Option 2: Push commit mới vào develop

```bash
git checkout develop
echo "test" >> README.md
git add README.md
git commit -m "test: verify OIDC publish workflow"
git push

# Workflow sẽ:
# 1. auto_beta_version_bump.yml chạy
# 2. Tạo tag v3.1.11-beta.1
# 3. publish_beta.yml trigger từ tag
# 4. OIDC authentication
# 5. Publish to pub.dev ✅
```

---

## 📊 Xác nhận workflows chạy

### 1. Check GitHub Actions

Vào: https://github.com/vqh2602/lucide-flutter-main/actions

Bạn sẽ thấy 2 workflows:

```
✅ Auto Beta Version Bump and Tag
✅ Publish Beta to pub.dev  ← Workflow này PHẢI chạy!
```

### 2. Check workflow logs

Click vào "Publish Beta to pub.dev" → Xem logs

Expected output:

```
✅ Checkout code
✅ Set up Flutter
✅ Setup Dart for OIDC
✅ Get dependencies
✅ Publish beta to pub.dev
    Publishing lucide_icons_flutter 3.1.11-beta.1...
    Successfully uploaded package.
✅ Create GitHub Pre-release
```

### 3. Verify trên pub.dev

Vào: https://pub.dev/packages/lucide_icons_flutter/versions

Click "**Show versions**" → Enable "**Include pre-releases**"

Bạn sẽ thấy: `3.1.11-beta.1` ✅

---

## 🐛 Troubleshooting

### Error: "Not allowed to publish"

```
The calling GitHub Action is not allowed to publish
```

**Cause**: Chưa enable automated publishing trên pub.dev

**Fix**: Làm theo bước 1-5 ở trên ☝️

---

### Error: "Tag pattern doesn't match"

```
No matching tag pattern found
```

**Cause**: Tag pattern sai hoặc tag format không đúng

**Fix**:

- Đảm bảo tag pattern là `v{{version}}`
- Tag phải có format: `v3.1.10-beta.1` (chữ v lowercase!)

---

### Workflow "Publish Beta" không chạy

**Check**:

1. ✅ Đã enable trên pub.dev?
2. ✅ Tag pattern đúng?
3. ✅ Tag đã được push? (`git push origin v3.1.10-beta.1`)
4. ✅ Workflow file exists? (`.github/workflows/publish_beta.yml`)

---

### Workflow chạy nhưng fail at publish step

**Possible causes**:

1. OIDC token invalid
2. Package name không match
3. Version already exists trên pub.dev

**Fix**: Xem logs chi tiết trong GitHub Actions

---

## 📋 Checklist Enable Automated Publishing

- [ ] Đã đăng nhập pub.dev
- [ ] Có quyền Admin/Uploader cho package
- [ ] Vào Admin page: https://pub.dev/packages/lucide_icons_flutter/admin
- [ ] Click "Enable publishing from GitHub Actions"
- [ ] Nhập repository: `vqh2602/lucide-flutter-main`
- [ ] Nhập tag pattern: `v{{version}}`
- [ ] Click Save
- [ ] Thấy confirmation "Automated publishing enabled"
- [ ] Test bằng cách push tag hoặc commit

---

## 🎯 Expected Timeline

```
Step 1: Enable on pub.dev (done once)        - 2 minutes
Step 2: Push commit to develop               - 1 second
Step 3: auto_beta_version_bump.yml runs      - 1 minute
Step 4: Tag created and pushed               - instant
Step 5: publish_beta.yml triggers            - instant
Step 6: OIDC authentication                  - 5 seconds
Step 7: Package published                    - 30 seconds
Step 8: GitHub Pre-release created           - 5 seconds

Total: ~2 minutes (after initial setup)
```

---

## ✅ Sau khi enable

Workflows sẽ hoạt động tự động:

1. Push vào `develop` → Beta version auto-published
2. Merge vào `main` → Stable version auto-published
3. Không cần làm gì thêm!

---

**Enable ngay bây giờ**: https://pub.dev/packages/lucide_icons_flutter/admin 🚀
