# GitHub Workflows

## 🤖 Auto-Publish System

Hệ thống tự động publish package lên pub.dev:

- 🧪 **Beta releases**: Tự động từ nhánh `develop` → `3.1.7-beta.1`, `3.1.7-beta.2`, ...
- 🚀 **Stable releases**: Tự động từ nhánh `main` → `3.2.0`, `4.0.0`, ...

---

## 📚 Documentation

| File                                                 | Mục đích           | Khi nào đọc        |
| ---------------------------------------------------- | ------------------ | ------------------ |
| [`INDEX.md`](./INDEX.md)                             | Tổng quan hệ thống | **Bắt đầu từ đây** |
| [`QUICK_REFERENCE.md`](./QUICK_REFERENCE.md)         | Tham khảo nhanh    | Sử dụng hàng ngày  |
| [`README_AUTO_PUBLISH.md`](./README_AUTO_PUBLISH.md) | Hướng dẫn chi tiết | Setup lần đầu      |
| [`BRANCHING_STRATEGY.md`](./BRANCHING_STRATEGY.md)   | Visual diagrams    | Hiểu workflow      |

---

## ⚡ Quick Start

### 1. Cấu hình (chỉ làm 1 lần)

```bash
# Lấy pub.dev credentials
flutter pub publish --dry-run

# Thêm vào GitHub Secrets:
# - PUB_DEV_ACCESS_TOKEN
# - PUB_DEV_REFRESH_TOKEN
```

### 2. Sử dụng

```bash
# Push vào develop → Beta release
git checkout develop
git commit -m "feat: new feature"
git push
# ✅ Auto: 3.1.7-beta.1 published

# Merge vào main → Stable release
# ✅ Auto: 3.2.0 published
```

---

## 📖 Đọc tiếp

👉 **[INDEX.md](./INDEX.md)** - Bắt đầu từ đây để setup hệ thống

---

**Happy Publishing! 🚀**
