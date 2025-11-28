# 📦 Auto-Publish System Documentation

## Tổng quan

Hệ thống tự động publish package Flutter lên pub.dev với 2 workflows:

- **Beta releases** từ nhánh `develop`
- **Stable releases** từ nhánh `main`

---

## 📁 Danh sách files đã tạo

### 1. Workflow Files

#### [`auto_publish.yml`](./auto_publish.yml)

**Mục đích**: Production release workflow cho nhánh `main`

**Triggers**:

- Push/Merge vào `main`
- Manual dispatch

**Chức năng**:

- ✅ Run tests và analyze
- ✅ Auto version bump (major/minor/patch)
- ✅ Update CHANGELOG.md
- ✅ Create Git tag
- ✅ Create GitHub Release
- ✅ Publish to pub.dev (stable)

**Version format**: `3.2.0`, `4.0.0`, `3.1.7`

---

#### [`auto_publish_beta.yml`](./auto_publish_beta.yml)

**Mục đích**: Beta release workflow cho nhánh `develop`

**Triggers**:

- Push vào `develop`
- Manual dispatch

**Chức năng**:

- ✅ Run tests và analyze
- ✅ Auto increment beta number
- ✅ Update CHANGELOG.md
- ✅ Create Git tag
- ✅ Create GitHub Pre-release
- ✅ Publish to pub.dev (pre-release)

**Version format**: `3.1.7-beta.1`, `3.1.7-beta.2`, ...

---

### 2. Documentation Files

#### [`README_AUTO_PUBLISH.md`](./README_AUTO_PUBLISH.md) ⭐ MAIN DOC

**Nội dung chính**:

- ✅ Hướng dẫn cấu hình chi tiết
- ✅ Cách lấy pub.dev credentials
- ✅ Setup GitHub Secrets
- ✅ Branch protection rules
- ✅ Branching strategy & best practices
- ✅ Version numbering strategy
- ✅ Workflow diagrams (Mermaid)
- ✅ Troubleshooting guide
- ✅ Customization options
- ✅ Example workflows

**Đọc file này trước** để hiểu toàn bộ hệ thống!

---

#### [`QUICK_REFERENCE.md`](./QUICK_REFERENCE.md) ⚡ QUICK START

**Nội dung chính**:

- ✅ Setup checklist
- ✅ Daily workflow commands
- ✅ Version bump rules (table)
- ✅ Troubleshooting quick fixes
- ✅ Useful commands

**Dùng file này** khi cần tham khảo nhanh trong quá trình làm việc hàng ngày!

---

#### [`BRANCHING_STRATEGY.md`](./BRANCHING_STRATEGY.md) 📊 VISUAL GUIDE

**Nội dung chính**:

- ✅ Git flow diagram (Mermaid)
- ✅ Workflow trigger flow
- ✅ Version progression timeline
- ✅ State diagrams
- ✅ Beta vs Stable comparison
- ✅ Decision tree

**Dùng file này** để hiểu visual flow của hệ thống!

---

## 🚀 Quick Start (3 bước)

### Bước 1: Cấu hình GitHub Secrets

```bash
# 1. Chạy lệnh này để lấy credentials
flutter pub publish --dry-run

# 2. Mở file credentials
# Mac/Linux: ~/.pub-cache/credentials.json
# Windows: %APPDATA%\Pub\Cache\credentials.json

# 3. Copy accessToken và refreshToken
# 4. Vào GitHub repo → Settings → Secrets → Add:
#    - PUB_DEV_ACCESS_TOKEN
#    - PUB_DEV_REFRESH_TOKEN
```

### Bước 2: Tạo nhánh develop (nếu chưa có)

```bash
git checkout -b develop
git push -u origin develop
```

### Bước 3: Test workflow

```bash
# Push một commit vào develop
git checkout develop
echo "test" >> test.txt
git add test.txt
git commit -m "chore: test beta workflow"
git push

# Kiểm tra: GitHub → Actions → Auto Publish Beta Version
# Expect: Version 3.1.7-beta.1 được publish
```

---

## 📖 Hướng dẫn đọc docs

Tùy theo mục đích, đọc theo thứ tự:

### Lần đầu setup:

1. [`README_AUTO_PUBLISH.md`](./README_AUTO_PUBLISH.md) - Đọc phần "Cấu hình cần thiết"
2. [`QUICK_REFERENCE.md`](./QUICK_REFERENCE.md) - Làm theo checklist
3. Test workflow
4. [`BRANCHING_STRATEGY.md`](./BRANCHING_STRATEGY.md) - Hiểu workflow

### Sử dụng hàng ngày:

1. [`QUICK_REFERENCE.md`](./QUICK_REFERENCE.md) - Commands & troubleshooting
2. [`README_AUTO_PUBLISH.md`](./README_AUTO_PUBLISH.md) - Chi tiết khi cần

### Khi gặp vấn đề:

1. [`QUICK_REFERENCE.md`](./QUICK_REFERENCE.md) - Troubleshooting nhanh
2. [`README_AUTO_PUBLISH.md`](./README_AUTO_PUBLISH.md) - Troubleshooting chi tiết
3. GitHub Actions logs - Debug workflow

---

## 🎯 Use Cases

### Case 1: Phát triển feature mới

```bash
git checkout develop
git checkout -b feature/new-icons
# Code...
git commit -m "feat: add new icons"
git push
# Tạo PR → develop
# Merge → auto beta.1 published
```

### Case 2: Fix bug trong beta

```bash
git checkout develop
# Fix...
git commit -m "fix: icon size"
git push
# → auto beta.2 published
```

### Case 3: Release stable

```bash
# Tạo PR: develop → main
# Merge → auto 3.2.0 published
```

### Case 4: Hotfix production

```bash
git checkout main
git checkout -b hotfix/critical-bug
# Fix...
git commit -m "fix: critical bug"
# Tạo PR → main
# Merge → auto 3.2.1 published
# Nhớ merge lại vào develop!
```

---

## 📊 File Structure

```
.github/
└── workflows/
    ├── auto_publish.yml              # Main workflow
    ├── auto_publish_beta.yml         # Beta workflow
    ├── README_AUTO_PUBLISH.md        # 📖 Main documentation
    ├── QUICK_REFERENCE.md            # ⚡ Quick reference
    ├── BRANCHING_STRATEGY.md         # 📊 Visual guide
    └── INDEX.md                      # 📑 This file
```

---

## 🔗 External Links

- **Package**: https://pub.dev/packages/lucide_icons_flutter
- **Repository**: https://github.com/vqh2602/lucide-flutter-main
- **GitHub Actions**: https://github.com/vqh2602/lucide-flutter-main/actions
- **Releases**: https://github.com/vqh2602/lucide-flutter-main/releases

---

## ✅ Checklist sau khi setup

- [ ] Đã add GitHub Secrets (`PUB_DEV_ACCESS_TOKEN`, `PUB_DEV_REFRESH_TOKEN`)
- [ ] Đã tạo nhánh `develop`
- [ ] Đã test beta workflow (push vào develop → check Actions)
- [ ] Đã test stable workflow (merge develop → main → check Actions)
- [ ] Đã verify package xuất hiện trên pub.dev
- [ ] Đã setup branch protection (optional)
- [ ] Team đã đọc docs và hiểu workflow

---

## 🆘 Support

Nếu gặp vấn đề:

1. **Check workflow logs**: GitHub → Actions → Click vào workflow run
2. **Review troubleshooting**: [`README_AUTO_PUBLISH.md`](./README_AUTO_PUBLISH.md#troubleshooting)
3. **Quick fixes**: [`QUICK_REFERENCE.md`](./QUICK_REFERENCE.md#-troubleshooting-nhanh)

---

**Happy Publishing! 🚀**
