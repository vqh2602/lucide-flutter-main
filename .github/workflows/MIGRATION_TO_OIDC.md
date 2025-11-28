# 🔄 MIGRATION: Từ Manual Tokens → OIDC (Official Method)

## ⚠️ Vấn đề với workflow hiện tại

Workflow hiện tại (`auto_publish.yml`, `auto_publish_beta.yml`) sử dụng:

- ❌ Manual tokens (`PUB_DEV_ACCESS_TOKEN`, `PUB_DEV_REFRESH_TOKEN`)
- ❌ Tự tạo credentials file
- ❌ Phức tạp và dễ lỗi
- ❌ Tokens có thể expire

## ✅ Phương pháp CHÍNH THỨC của Dart

Dart khuyến nghị dùng **OIDC (OpenID Connect)**:

- ✅ **KHÔNG cần** lưu tokens trong GitHub Secrets
- ✅ GitHub tự động tạo temporary token
- ✅ An toàn hơn nhiều
- ✅ Đơn giản hơn
- ✅ Được Dart team maintain

**Tài liệu**: https://dart.dev/tools/pub/automated-publishing

---

## 📋 Hướng dẫn Migration

### Bước 1: Enable Automated Publishing trên pub.dev

#### 1.1. Đăng nhập pub.dev

Vào: https://pub.dev/

#### 1.2. Navigate to Admin page

```
https://pub.dev/packages/lucide_icons_flutter/admin
```

Bạn phải là:

- **Uploader** của package, hoặc
- **Admin** của publisher (nếu package thuộc publisher)

#### 1.3. Enable Automated Publishing

Trong section **"Automated publishing"**:

1. Click **"Enable publishing from GitHub Actions"**

2. Nhập thông tin:

   ```
   Repository: vqh2602/lucide-flutter-main
   Tag pattern: v{{version}}
   ```

3. Click **Save**

> [!IMPORTANT] > **Tag Pattern Options:**
>
> - Stable releases: `v{{version}}` (matches: v3.2.0, v4.0.0)
> - Beta releases: `v{{version}}-beta.*` hoặc riêng biệt
> - Multiple packages: `package_name-v{{version}}`

---

### Bước 2: Chọn phương án

Có 2 phương án:

#### Option A: Dùng Official Reusable Workflow (KHUYẾN NGHỊ)

**Ưu điểm**:

- ✅ Đơn giản nhất
- ✅ Maintained by Dart team
- ✅ Auto updates

**Nhược điểm**:

- ❌ Ít customize
- ❌ Phải manual tạo tags (không auto version bump)

**File**: `publish_official.yml`

**Workflow**:

```
1. Manual update pubspec.yaml → version: 3.2.0
2. Commit changes
3. Create tag: git tag v3.2.0
4. Push tag: git push origin v3.2.0
5. Workflow tự động publish
```

---

#### Option B: Custom Workflow + Auto Version Bump (HIỆN TẠI)

**Ưu điểm**:

- ✅ Tự động bump version
- ✅ Tự động tạo tags
- ✅ Tự động update CHANGELOG
- ✅ Flexible

**Nhược điểm**:

- ❌ Phức tạp hơn
- ❌ Cần maintain

**Files**: `auto_publish.yml`, `auto_publish_beta.yml`

**Cần update**:

- Thay vì dùng manual tokens
- Dùng OIDC authentication

---

### Bước 3: Update Workflow (nếu chọn Option A)

#### 3.1. Rename/Disable old workflows

```bash
# Backup old workflows
mv .github/workflows/auto_publish.yml .github/workflows/auto_publish.yml.backup
mv .github/workflows/auto_publish_beta.yml .github/workflows/auto_publish_beta.yml.backup

# Or keep both (test trước)
```

#### 3.2. Activate official workflows

```bash
# Rename official workflows
mv .github/workflows/publish_official.yml .github/workflows/publish.yml
mv .github/workflows/publish_beta_official.yml .github/workflows/publish_beta.yml
```

#### 3.3. Remove GitHub Secrets (nếu không dùng nữa)

Vào: https://github.com/vqh2602/lucide-flutter-main/settings/secrets/actions

Xóa:

- `PUB_DEV_ACCESS_TOKEN` (không cần nữa!)
- `PUB_DEV_REFRESH_TOKEN` (không cần nữa!)

---

### Bước 4: Test Workflow Mới

#### 4.1. Update version in pubspec.yaml

```yaml
# pubspec.yaml
version: 3.1.8-beta.1
```

#### 4.2. Commit changes

```bash
git add pubspec.yaml
git commit -m "chore: bump version to 3.1.8-beta.1"
git push
```

#### 4.3. Create and push tag

```bash
git tag v3.1.8-beta.1
git push origin v3.1.8-beta.1
```

#### 4.4. Monitor workflow

Vào: https://github.com/vqh2602/lucide-flutter-main/actions

Expected:

- ✅ "Publish Beta to pub.dev" workflow runs
- ✅ Authenticates using OIDC
- ✅ Publishes to pub.dev

---

## 🔄 Hybrid Approach (KHUYẾN NGHỊ)

Kết hợp cả 2 phương pháp:

### Stable releases: Official Workflow

- File: `publish.yml`
- Trigger: Tag `v[0-9]+.[0-9]+.[0-9]+`
- Method: Reusable workflow (dart-lang)
- Manual: Tạo tag thủ công

### Beta releases: Custom Workflow + OIDC

- File: `auto_publish_beta_v2.yml`
- Trigger: Push to `develop`
- Method: Auto bump + OIDC
- Automatic: Tự động mọi thứ

**Benefits**: Best of both worlds!

---

## 📝 Workflow Comparison

| Feature                 | Manual Tokens  | OIDC Official | Current Auto   |
| ----------------------- | -------------- | ------------- | -------------- |
| **Secrets needed**      | Yes (2 tokens) | No            | Yes (2 tokens) |
| **Setup complexity**    | High           | Low           | High           |
| **Security**            | Medium         | High          | Medium         |
| **Auto version bump**   | No             | No            | Yes            |
| **Auto tags**           | No             | No            | Yes            |
| **Maintained by**       | You            | Dart team     | You            |
| **Recommended by Dart** | No             | **Yes**       | No             |

---

## ⚡ Quick Decision Guide

### Chọn Official Workflow (Option A) nếu:

- ✅ Bạn OK với manual version bump
- ✅ Muốn simple và official
- ✅ Trust Dart team maintain
- ✅ Ít customize

### Giữ Custom Workflow (Option B) nếu:

- ✅ Cần auto version bump
- ✅ Cần auto tags/CHANGELOG
- ✅ OK với maintain workflow
- ✅ Cần full control

### Hybrid (BEST) nếu:

- ✅ Muốn official cho stable
- ✅ Muốn auto cho beta
- ✅ Best security + convenience

---

## 🎯 Recommended Action Plan

### Phase 1: Enable OIDC on pub.dev

1. Vào https://pub.dev/packages/lucide_icons_flutter/admin
2. Enable automated publishing
3. Set tag pattern: `v{{version}}`

### Phase 2: Test với Official Workflow (stable)

1. Create `publish.yml` (official)
2. Test với tag `v3.1.8`
3. Verify hoạt động

### Phase 3: Migrate Beta Workflow

1. Update `auto_publish_beta.yml` để dùng OIDC
2. Remove manual token setup
3. Keep auto version bump logic

### Phase 4: Clean up

1. Remove old backup files
2. Update documentation
3. Remove unused GitHub Secrets

---

## 📖 Resources

- **Official docs**: https://dart.dev/tools/pub/automated-publishing
- **OIDC GitHub**: https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect
- **Reusable workflow**: https://github.com/dart-lang/setup-dart/blob/main/.github/workflows/publish.yml

---

**Bạn muốn migrate ngay bây giờ?** Tôi có thể giúp setup! 🚀
