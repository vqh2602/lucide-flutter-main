# ✅ Updated to OIDC Authentication!

## 🎉 What Changed

Workflows đã được cập nhật để sử dụng **OIDC (OpenID Connect)** authentication - phương pháp CHÍNH THỨC được Dart khuyến nghị!

### ❌ Trước (Manual Tokens):

```yaml
- Setup Pub Credentials:
    - Create credentials file
    - Use PUB_DEV_ACCESS_TOKEN
    - Use PUB_DEV_REFRESH_TOKEN
```

### ✅ Bây giờ (OIDC):

```yaml
- Setup Dart for OIDC:
    uses: dart-lang/setup-dart@v1
    # GitHub tự động tạo temporary token!
```

---

## 🔐 Bây giờ cần làm gì?

### Bước 1: Enable Automated Publishing trên pub.dev (BẮT BUỘC)

**QUAN TRỌNG**: OIDC chỉ hoạt động sau khi bạn enable automated publishing trên pub.dev!

#### 1.1. Đăng nhập pub.dev

Vào: https://pub.dev/

#### 1.2. Navigate to Admin page

```
https://pub.dev/packages/lucide_icons_flutter/admin
```

Bạn phải là:

- **Uploader** của package, HOẶC
- **Admin** của publisher (nếu package thuộc publisher)

#### 1.3. Enable Automated Publishing

Scroll xuống section **"Automated publishing"**

Click **"Enable publishing from GitHub Actions"**

Nhập:

```
Repository: vqh2602/lucide-flutter-main
Tag pattern: v{{version}}
```

> [!IMPORTANT] > **Tag Pattern**:
>
> - Use `v{{version}}` để match cả stable VÀ beta versions
> - Pattern này sẽ match: v3.2.0, v3.1.7-beta.1, v4.0.0-beta.2, etc.
> - Dart sẽ extract version number từ tag

Click **Save**

---

### Bước 2: Xóa GitHub Secrets (không cần nữa!)

Vào: https://github.com/vqh2602/lucide-flutter-main/settings/secrets/actions

**Xóa** 2 secrets (nếu có):

- ❌ `PUB_DEV_ACCESS_TOKEN` ← Không cần nữa!
- ❌ `PUB_DEV_REFRESH_TOKEN` ← Không cần nữa!

**Lý do**: OIDC không cần secrets! GitHub tự động authenticate.

---

### Bước 3: Test Workflow

#### Test Beta Workflow (develop branch)

```bash
# Đã tạo test commit rồi, chờ workflow chạy
# Hoặc tạo commit mới:

echo "test OIDC" >> README.md
git add README.md
git commit -m "test: verify OIDC authentication"
git push origin develop

# Expected:
# → Workflow runs with OIDC
# → Version: 3.1.7-beta.3
# → NO credentials error!
```

#### Test Stable Workflow (main branch)

```bash
# Merge develop → main khi ready
# Workflow sẽ tự động chạy với OIDC
```

---

## 📊 Workflow Changes Summary

### auto_publish.yml (Stable)

**Added**:

- ✅ `dart-lang/setup-dart@v1` - Configures OIDC
- ✅ Comments explaining permissions

**Removed**:

- ❌ Manual credentials setup
- ❌ PUB_CACHE environment variable
- ❌ Dependency on GitHub Secrets

**Kept** (giữ nguyên):

- ✅ Auto version bump
- ✅ Auto CHANGELOG update
- ✅ Auto git tags
- ✅ Auto GitHub releases
- ✅ Tests and analyze

### auto_publish_beta.yml (Beta)

**Same changes as above**, plus:

- ✅ Kept auto patch version bump (3.1.6 → 3.1.7-beta.1)
- ✅ Kept beta number increment

---

## 🎯 Benefits of OIDC

### ✅ Security

- No long-lived tokens in secrets
- Temporary tokens per workflow run
- Automatic token rotation
- No manual token management

### ✅ Simplicity

- No manual setup needed
- No token expiration issues
- One less thing to maintain

### ✅ Official

- Recommended by Dart team
- Maintained by Dart team
- Future-proof

---

## 🐛 Troubleshooting

### Error: "Pub authorization failed"

**Cause**: Chưa enable automated publishing trên pub.dev

**Solution**:

1. Vào https://pub.dev/packages/lucide_icons_flutter/admin
2. Enable automated publishing
3. Set tag pattern: `v{{version}}`

### Error: "id-token permission missing"

**Cause**: Thiếu permission trong workflow

**Solution**: Đã fixed! Workflow có:

```yaml
permissions:
  id-token: write # Required for OIDC
```

### Workflow chạy nhưng không publish

**Check**:

1. ✅ Enabled automated publishing on pub.dev?
2. ✅ Tag pattern matches? (v{{version}})
3. ✅ Repository correct? (vqh2602/lucide-flutter-main)
4. ✅ Workflow logs có error gì không?

---

## 📝 Next Steps

### 1. Enable on pub.dev (NOW!)

Vào admin page và enable automated publishing.

### 2. Remove unnecessary secrets (OPTIONAL)

Delete old tokens from GitHub Secrets.

### 3. Test workflow

Push a commit to develop and verify OIDC works.

### 4. Update team documentation

Let team know about the change.

---

## 🔗 Resources

- **Dart Official Docs**: https://dart.dev/tools/pub/automated-publishing
- **OIDC on GitHub**: https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect
- **setup-dart action**: https://github.com/dart-lang/setup-dart

---

## ✅ Checklist

- [ ] Enabled automated publishing on pub.dev
- [ ] Set tag pattern to `v{{version}}`
- [ ] Set repository to `vqh2602/lucide-flutter-main`
- [ ] (Optional) Removed old GitHub Secrets
- [ ] Tested beta workflow on develop branch
- [ ] Verified OIDC authentication works
- [ ] Checked published package on pub.dev

---

**Tất cả tính năng auto-bump đã được giữ nguyên, chỉ thay đổi cách authenticate!** 🎉

Ready to enable on pub.dev? 🚀
