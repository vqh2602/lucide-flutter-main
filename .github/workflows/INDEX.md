# 📦 Auto-Publish System Documentation

## Tổng quan

Hệ thống tự động publish package Flutter lên pub.dev với 2 workflows:

- **Beta releases** từ nhánh `develop`
- **Stable releases** từ nhánh `main`
- **Authentication**: OIDC (OpenID Connect) - Phương pháp chính thức của Dart

---

## 📁 Files trong hệ thống

### Workflow Files

#### [`auto_publish.yml`](./auto_publish.yml)

**Mục đích**: Production release workflow cho nhánh `main`

**Triggers**:

- Push/Merge vào `main`
- Manual dispatch

**Chức năng**:

- ✅ Auto version bump (major/minor/patch)
- ✅ Run tests và analyze
- ✅ Update CHANGELOG.md
- ✅ Create Git tag
- ✅ Create GitHub Release
- ✅ Publish to pub.dev (stable) với OIDC

**Version format**: `3.2.0`, `4.0.0`, `3.1.7`

---

#### [`auto_publish_beta.yml`](./auto_publish_beta.yml)

**Mục đích**: Beta release workflow cho nhánh `develop`

**Triggers**:

- Push vào `develop`
- Manual dispatch

**Chức năng**:

- ✅ Auto increment patch version + beta number
- ✅ Run tests và analyze
- ✅ Update CHANGELOG.md
- ✅ Create Git tag
- ✅ Create GitHub Pre-release
- ✅ Publish to pub.dev (pre-release) với OIDC

**Version format**: `3.1.7-beta.1`, `3.1.7-beta.2`, ...

---

### Documentation Files

#### [`OIDC_SETUP.md`](./OIDC_SETUP.md) ⭐ START HERE

**Nội dung chính**:

- ✅ Hướng dẫn enable automated publishing trên pub.dev
- ✅ OIDC là gì và tại sao dùng
- ✅ Setup guide từng bước
- ✅ Troubleshooting

**Đọc file này TRƯỚC** để setup hệ thống!

---

#### [`README.md`](./README.md) 📖 QUICK START

**Nội dung chính**:

- ✅ Overview workflows
- ✅ Quick setup steps
- ✅ Links to detailed docs

**Dùng file này** làm entry point!

---

#### [`README_AUTO_PUBLISH.md`](./README_AUTO_PUBLISH.md) 📚 FULL GUIDE

**Nội dung chính**:

- ✅ Hướng dẫn chi tiết đầy đủ
- ✅ Cách sử dụng workflows
- ✅ Branch protection rules
- ✅ Branching strategy & best practices
- ✅ Version numbering strategy
- ✅ Troubleshooting guide
- ✅ Customization options

**Đọc file này** để hiểu sâu toàn bộ hệ thống!

---

#### [`QUICK_REFERENCE.md`](./QUICK_REFERENCE.md) ⚡ CHEAT SHEET

**Nội dung chính**:

- ✅ Daily workflow commands
- ✅ Version bump rules (table)
- ✅ Troubleshooting quick fixes
- ✅ Useful commands

**Dùng file này** khi cần tham khảo nhanh!

---

#### [`FAQ.md`](./FAQ.md) ❓ Q&A

**Nội dung chính**:

- ✅ Common questions
- ✅ Token & authentication FAQs
- ✅ Beta version explanation
- ✅ Workflow troubleshooting
- ✅ Best practices tips

**Đọc file này** khi có thắc mắc!

---

#### [`BRANCHING_STRATEGY.md`](./BRANCHING_STRATEGY.md) 📊 VISUAL GUIDE

**Nội dung chính**:

- ✅ Git flow diagrams (Mermaid)
- ✅ Workflow trigger flow
- ✅ Version progression timeline
- ✅ State diagrams
- ✅ Decision tree

**Dùng file này** để hiểu visual flow!

---

## 🚀 Quick Start (3 bước)

### Bước 1: Enable Automated Publishing trên pub.dev

Vào: https://pub.dev/packages/lucide_icons_flutter/admin

Enable automated publishing:

- Repository: `vqh2602/lucide-flutter-main`
- Tag pattern: `v{{version}}`

> [!IMPORTANT] > **OIDC chỉ hoạt động sau khi enable trên pub.dev!**

### Bước 2: Tạo nhánh develop (nếu chưa có)

```bash
git checkout -b develop
git push -u origin develop
```

### Bước 3: Test workflow

```bash
# Push commit vào develop
git checkout develop
echo "test" >> README.md
git add README.md
git commit -m "test: verify OIDC workflow"
git push

# Kiểm tra: GitHub → Actions → Auto Publish Beta Version
# Expected: Version 3.1.7-beta.X published với OIDC
```

---

## 📖 Hướng dẫn đọc docs

### Lần đầu setup:

1. [`OIDC_SETUP.md`](./OIDC_SETUP.md) - Enable trên pub.dev
2. [`README.md`](./README.md) - Quick start guide
3. Test workflow
4. [`BRANCHING_STRATEGY.md`](./BRANCHING_STRATEGY.md) - Hiểu workflow

### Sử dụng hàng ngày:

1. [`QUICK_REFERENCE.md`](./QUICK_REFERENCE.md) - Commands & troubleshooting
2. [`README_AUTO_PUBLISH.md`](./README_AUTO_PUBLISH.md) - Chi tiết khi cần

### Khi gặp vấn đề:

1. [`QUICK_REFERENCE.md`](./QUICK_REFERENCE.md) - Troubleshooting nhanh
2. [`FAQ.md`](./FAQ.md) - Common questions
3. [`README_AUTO_PUBLISH.md`](./README_AUTO_PUBLISH.md) - Troubleshooting chi tiết
4. GitHub Actions logs - Debug workflow

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
# Merge → auto beta.X published với OIDC
```

### Case 2: Fix bug trong beta

```bash
git checkout develop
# Fix...
git commit -m "fix: icon size"
git push
# → auto beta.Y published
```

### Case 3: Release stable

```bash
# Tạo PR: develop → main
# Merge → auto stable version published
```

---

## 📊 File Structure

```
.github/
└── workflows/
    ├── auto_publish.yml              # Main workflow (OIDC)
    ├── auto_publish_beta.yml         # Beta workflow (OIDC)
    ├── OIDC_SETUP.md                 # ⭐ Setup guide
    ├── README.md                     # 📖 Entry point
    ├── README_AUTO_PUBLISH.md        # 📚 Full docs
    ├── QUICK_REFERENCE.md            # ⚡ Cheat sheet
    ├── FAQ.md                        # ❓ Q&A
    ├── BRANCHING_STRATEGY.md         # 📊 Visual guide
    ├── INDEX.md                      # 📑 This file
    └── update_contributors.yml       # Contributors workflow
```

---

## 🔗 External Links

- **Package**: https://pub.dev/packages/lucide_icons_flutter
- **Repository**: https://github.com/vqh2602/lucide-flutter-main
- **GitHub Actions**: https://github.com/vqh2602/lucide-flutter-main/actions
- **Releases**: https://github.com/vqh2602/lucide-flutter-main/releases
- **Dart OIDC Docs**: https://dart.dev/tools/pub/automated-publishing

---

## ✅ Checklist sau khi setup

- [ ] Đã enable automated publishing trên pub.dev
- [ ] Đã set tag pattern: `v{{version}}`
- [ ] Đã set repository: `vqh2602/lucide-flutter-main`
- [ ] Đã tạo nhánh `develop`
- [ ] Đã test workflow (push vào develop → check Actions)
- [ ] Đã verify package xuất hiện trên pub.dev
- [ ] (Optional) Đã setup branch protection
- [ ] Team đã đọc docs và hiểu workflow

---

## 🔐 OIDC vs Manual Tokens

| Feature         | OIDC (Current) | Manual Tokens (Old)  |
| --------------- | -------------- | -------------------- |
| **Secrets**     | ❌ None needed | ✅ 2 tokens required |
| **Setup**       | ✅ Simple      | ❌ Complex           |
| **Security**    | ✅ High        | ⚠️ Medium            |
| **Maintenance** | ✅ Zero        | ❌ Token renewal     |
| **Official**    | ✅ Yes         | ❌ No                |

---

## 🆘 Support

Nếu gặp vấn đề:

1. **Check workflow logs**: GitHub → Actions → Click vào workflow run
2. **Review OIDC setup**: [`OIDC_SETUP.md`](./OIDC_SETUP.md)
3. **Quick fixes**: [`QUICK_REFERENCE.md`](./QUICK_REFERENCE.md#-troubleshooting-nhanh)
4. **FAQ**: [`FAQ.md`](./FAQ.md)

---

**Happy Auto-Publishing with OIDC! 🚀**
