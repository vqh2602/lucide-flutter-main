# Quick Reference - Auto Publish Workflows

## 🚀 Hai workflows tự động

| Workflow       | Branch    | Trigger     | Version Format | File                    |
| -------------- | --------- | ----------- | -------------- | ----------------------- |
| **Production** | `main`    | Merge PR    | `3.2.0`        | `auto_publish.yml`      |
| **Beta**       | `develop` | Push commit | `3.1.7-beta.1` | `auto_publish_beta.yml` |

## 📋 Checklist cấu hình lần đầu

- [ ] Chạy `flutter pub publish --dry-run` để lấy credentials
- [ ] Thêm `PUB_DEV_ACCESS_TOKEN` vào GitHub Secrets
- [ ] Thêm `PUB_DEV_REFRESH_TOKEN` vào GitHub Secrets
- [ ] (Optional) Setup branch protection cho `main` và `develop`
- [ ] Tạo nhánh `develop` nếu chưa có: `git checkout -b develop && git push -u origin develop`

## 🔄 Quy trình làm việc hàng ngày

### 1️⃣ Tạo feature mới

```bash
git checkout develop
git pull origin develop
git checkout -b feature/icon-name
# Code...
git commit -m "feat: add new icons"
git push origin feature/icon-name
# Tạo PR: feature/icon-name → develop
```

### 2️⃣ Merge vào develop → Beta release

```bash
# Merge PR vào develop
# ✅ Auto: 3.1.7-beta.1 published to pub.dev
```

### 3️⃣ Test beta version

```yaml
# pubspec.yaml của project khác
dependencies:
  lucide_icons_flutter: 3.1.7-beta.1
```

### 4️⃣ Fix bugs trên develop

```bash
git checkout develop
# Fix bug...
git commit -m "fix: correct icon size"
git push
# ✅ Auto: 3.1.7-beta.2 published
```

### 5️⃣ Release stable version

```bash
# Tạo PR: develop → main
# Merge PR
# ✅ Auto: 3.2.0 published to pub.dev (stable)
```

## 🏷️ Version bump rules

### Main branch (auto_publish.yml)

| Commit Message                   | Version Change    | Example                      |
| -------------------------------- | ----------------- | ---------------------------- |
| `[major]` hoặc `breaking change` | 3.1.6 → **4.0.0** | `feat: [major] redesign API` |
| `[minor]`, `feat`, `feature`     | 3.1.6 → **3.2.0** | `feat: add calendar icons`   |
| Other                            | 3.1.6 → **3.1.7** | `fix: icon alignment`        |

### Develop branch (auto_publish_beta.yml)

Mỗi push tự động tăng beta number:

```
3.1.7-beta.1 → 3.1.7-beta.2 → 3.1.7-beta.3 → ... → 3.2.0 (stable)
```

## ⚡ Commands nhanh

```bash
# Xem version hiện tại
grep '^version:' pubspec.yaml

# Xem tất cả tags
git tag -l

# Xem beta tags của version hiện tại
git tag -l "v3.1.7-beta.*"

# Xóa tag local (nếu cần)
git tag -d v3.1.7-beta.1

# Xóa tag remote (⚠️ cẩn thận!)
git push origin --delete v3.1.7-beta.1

# Sync tất cả tags
git fetch --tags --force

# Xem workflow runs
# → Vào GitHub → Actions tab
```

## 🐛 Troubleshooting nhanh

### Workflow không chạy?

- Kiểm tra file workflow có syntax error: Vào Actions tab → xem error
- Đảm bảo push vào đúng branch (`main` hoặc `develop`)

### Tests fail?

```bash
flutter test
flutter analyze
```

### Credentials expired?

- Run lại: `flutter pub publish --dry-run`
- Update GitHub Secrets với tokens mới

### Beta number không đúng?

```bash
git fetch --tags --force
```

### Version conflict khi merge?

- Chọn base version (loại bỏ `-beta` suffix)
- Workflow sẽ tự bump version sau khi merge

## 📊 Xem published versions

- **Stable versions**: https://pub.dev/packages/lucide_icons_flutter/versions
- **Beta versions**: Bật "Include pre-releases" trên pub.dev
- **GitHub Releases**: https://github.com/vqh2602/lucide-flutter-main/releases

## ⚙️ Workflow files location

```
.github/
└── workflows/
    ├── auto_publish.yml          # Production release (main)
    ├── auto_publish_beta.yml     # Beta release (develop)
    └── README_AUTO_PUBLISH.md    # Full documentation
```

## 📞 Cần trợ giúp?

1. Xem full docs: [README_AUTO_PUBLISH.md](./README_AUTO_PUBLISH.md)
2. Check workflow runs: GitHub → Actions tab
3. Review workflow logs để debug

---

**Tip**: Bookmark file này để tham khảo nhanh! 🔖
