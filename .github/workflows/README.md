# GitHub Workflows - Auto-Publish System

## 🤖 Tự động publish package lên pub.dev với OIDC

- 🧪 **Beta releases**: Tự động từ nhánh `develop` → `3.1.7-beta.1`, `3.1.7-beta.2`, ...
- 🚀 **Stable releases**: Tự động từ nhánh `main` → `3.2.0`, `4.0.0`, ...
- 🔐 **Authentication**: OIDC (OpenID Connect) - Không cần lưu tokens!

---

## ⚡ Quick Start

### 1. Enable trên pub.dev (BẮT BUỘC)

Vào: https://pub.dev/packages/lucide_icons_flutter/admin

Click **"Enable publishing from GitHub Actions"**

```
Repository: vqh2602/lucide-flutter-main
Tag pattern: v{{version}}
```

### 2. Test workflow

```bash
# Push vào develop → Beta release
git checkout develop
git commit -m "feat: new feature"
git push
# ✅ Auto: 3.1.7-beta.X published

# Merge vào main → Stable release
# ✅ Auto: 3.2.0 published
```

---

## 📚 Documentation

| File                                                   | Khi nào đọc                         |
| ------------------------------------------------------ | ----------------------------------- |
| **[OIDC_SETUP.md](./OIDC_SETUP.md)**                   | ⭐ **Bắt đầu từ đây** - Setup guide |
| **[INDEX.md](./INDEX.md)**                             | 📑 Tổng quan hệ thống               |
| **[QUICK_REFERENCE.md](./QUICK_REFERENCE.md)**         | ⚡ Sử dụng hàng ngày                |
| **[README_AUTO_PUBLISH.md](./README_AUTO_PUBLISH.md)** | 📚 Hướng dẫn chi tiết               |
| **[FAQ.md](./FAQ.md)**                                 | ❓ Câu hỏi thường gặp               |
| **[BRANCHING_STRATEGY.md](./BRANCHING_STRATEGY.md)**   | 📊 Visual diagrams                  |

---

## 🎯 Workflow Files

- **[auto_publish.yml](./auto_publish.yml)** - Production releases (main branch)
- **[auto_publish_beta.yml](./auto_publish_beta.yml)** - Beta releases (develop branch)

---

## ✅ Features

- ✅ Auto version bump
- ✅ Auto CHANGELOG update
- ✅ Auto git tags
- ✅ Auto GitHub releases
- ✅ Auto publish to pub.dev
- ✅ OIDC authentication (no secrets!)
- ✅ Tests before publish

---

**👉 Đọc tiếp**: [OIDC_SETUP.md](./OIDC_SETUP.md) để setup! 🚀
