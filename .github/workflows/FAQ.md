# ❓ FAQ - Câu hỏi thường gặp

## 🔐 Về Tokens

### Q: Access token hết hạn sau vài giờ, có phải cập nhật thường xuyên không?

**A: KHÔNG!** Đây là hiểu lầm phổ biến.

- **Access Token** hết hạn sau 1-2 giờ - điều này là **BÌNH THƯỜNG**
- **Refresh Token** tồn tại rất lâu (nhiều tháng/năm)
- Workflow tự động dùng `refreshToken` để **renew** `accessToken` mỗi khi chạy
- Bạn **KHÔNG cần** cập nhật GitHub Secrets thường xuyên

**Khi nào cần update?**

- Chỉ khi workflow báo lỗi authentication (rất hiếm xảy ra)
- Khi bạn `dart pub logout` và login lại với account khác

### Q: File credentials ở đâu?

**A:** Tùy hệ điều hành:

```bash
# Mac/Linux - Option 1:
~/.pub-cache/credentials.json

# Mac/Linux - Option 2:
~/Library/Application Support/dart/pub-credentials.json

# Windows:
%APPDATA%\dart\pub-credentials.json
```

Xem nội dung:

```bash
# Mac/Linux:
cat ~/Library/Application\ Support/dart/pub-credentials.json

# Windows:
type %APPDATA%\dart\pub-credentials.json
```

---

## 📦 Về Beta Versions

### Q: Tại sao beta version là 3.1.7-beta.1 trong khi stable mới 3.1.6?

**A:** Đây là **BY DESIGN** - beta luôn target version tiếp theo!

**Logic:**

```
Current stable: 3.1.6

Beta workflow:
1. Đọc version hiện tại: 3.1.6
2. Auto bump patch: 3.1.6 + 1 = 3.1.7
3. Thêm beta suffix: 3.1.7-beta.1

Tại sao?
→ Beta đang test code cho release 3.1.7 (hoặc 3.2.0)
→ Beta KHÔNG BAO GIỜ thấp hơn stable
```

**Ví dụ đầy đủ:**

```
Stable: 3.1.6

develop:
  push #1 → 3.1.7-beta.1
  push #2 → 3.1.7-beta.2
  push #3 → 3.1.7-beta.3

Merge develop → main (with "feat:" in commit):
  → auto_publish.yml decides: MINOR bump
  → 3.2.0 (stable)

Next develop push:
  → Auto bump: 3.2.0 + 1 = 3.2.1
  → 3.2.1-beta.1
```

### Q: Beta version không xuất hiện trên pub.dev?

**A:** Pre-release versions bị ẩn mặc định.

**Cách xem:**

1. Vào https://pub.dev/packages/lucide_icons_flutter/versions
2. Click "**Show versions**" (dưới Changelog)
3. Bật "**Include pre-releases**"

**Cách cài đặt:**

```yaml
dependencies:
  # Cách 1: Exact version
  lucide_icons_flutter: 3.1.7-beta.1

  # Cách 2: Bất kỳ beta nào của 3.1.7
  lucide_icons_flutter: ^3.1.7-beta.1
```

---

## 🔄 Về Workflows

### Q: Khi nào workflow chạy?

**A:**

| Workflow                | Trigger               | Khi nào chạy                 |
| ----------------------- | --------------------- | ---------------------------- |
| `auto_publish.yml`      | Push/Merge vào `main` | Khi merge PR: develop → main |
| `auto_publish_beta.yml` | Push vào `develop`    | Mỗi khi merge PR vào develop |

**Không chạy khi:**

- Commit message có `[skip ci]`
- Push vào feature branches
- Tạo PR (chỉ chạy khi merge)

### Q: Làm sao biết workflow đã chạy xong?

**A:**

1. Vào GitHub → **Actions** tab
2. Xem workflow run mới nhất
3. Kiểm tra status:

   - ✅ Green checkmark = Success
   - ❌ Red X = Failed
   - 🟡 Yellow dot = Running

4. Click vào run để xem logs chi tiết

### Q: Version bump sai, làm sao rollback?

**A:** Phụ thuộc vào stage:

**Nếu chưa publish:**

1. Cancel workflow trong Actions tab
2. Fix version trong pubspec.yaml
3. Push lại

**Nếu đã publish lên pub.dev:**

- ⚠️ **KHÔNG THỂ** xóa version đã publish
- Chỉ có thể publish version mới cao hơn
- Nếu sai nghiêm trọng: retract version (xem pub.dev docs)

---

## 🐛 Troubleshooting

### Q: Workflow fail với "Tests failed"

**A:**

```bash
# Test locally trước:
flutter test
flutter analyze

# Nếu pass local nhưng fail CI:
# → Check Flutter version khác nhau
# → Check dependencies trong pubspec.lock
```

### Q: Workflow fail với "Permission denied"

**A:** Kiểm tra workflow permissions:

```yaml
permissions:
  contents: write
  id-token: write
```

Hoặc check repo Settings → Actions → General → Workflow permissions

### Q: Git tag conflict

**A:**

```bash
# Xóa tag local
git tag -d v3.1.7-beta.1

# Xóa tag remote (⚠️ cẩn thận!)
git push origin --delete v3.1.7-beta.1

# Sync lại tags
git fetch --tags --force
```

---

## 📝 Best Practices

### Q: Nên merge bao nhiêu beta versions trước khi release stable?

**A:** Tùy project, nhưng thông thường:

- Minimum: 1 beta version, test 1-2 ngày
- Recommended: 2-3 beta versions
- Complex changes: 5+ beta versions

### Q: Có nên merge feature branches trực tiếp vào main không?

**A:** **KHÔNG!** Luôn đi qua develop:

```
feature → develop (beta testing) → main (stable)
```

**Exception:** Hotfix urgent cho production bug

### Q: Khi nào dùng manual workflow dispatch?

**A:**

- Emergency release
- Skip auto version detection
- Testing workflow
- Re-run failed publish

---

## 💡 Tips & Tricks

### Tip 1: Xem version sẽ được publish

```bash
# Xem current version
grep '^version:' pubspec.yaml

# Predict beta version
CURRENT=$(grep '^version:' pubspec.yaml | sed 's/version: //' | sed 's/-beta.*//')
IFS='.' read -r MAJ MIN PAT <<< "$CURRENT"
echo "Next beta: $MAJ.$MIN.$((PAT + 1))-beta.1"
```

### Tip 2: Test workflow locally (dry-run)

```bash
# Test publish (không publish thật)
flutter pub publish --dry-run

# Test build
flutter test
flutter analyze
```

### Tip 3: Semantic commit messages

Dùng conventional commits để auto version bump:

```bash
git commit -m "feat: add new icons"     # → MINOR bump
git commit -m "fix: icon alignment"     # → PATCH bump
git commit -m "feat!: redesign API"     # → MAJOR bump
git commit -m "feat: [major] new API"   # → MAJOR bump
```

---

**Có câu hỏi khác?** Xem [README_AUTO_PUBLISH.md](./README_AUTO_PUBLISH.md) để biết thêm chi tiết!
