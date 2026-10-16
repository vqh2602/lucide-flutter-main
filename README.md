# lucide_icons

![Pub Version](https://img.shields.io/pub/v/lucide_icons_flutter)
![Pub Monthly Downloads](https://img.shields.io/pub/dm/lucide_icons_flutter)
![Pub Likes](https://img.shields.io/pub/likes/lucide_icons_flutter)
![Pub Points](https://img.shields.io/pub/points/lucide_icons_flutter)
![Pub Publisher](https://img.shields.io/pub/publisher/lucide_icons_flutter)
[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-vqh2602-FFDD00?logo=buy-me-a-coffee&logoColor=black)](https://buymeacoffee.com/vqh2602)

Lucide version: 1.58.0

Lucide Icons ([lucide.dev](https://lucide.dev)) for Flutter. Visit the website for the full list of icons.

## Example

### Regular Icons (Default)

```dart
import 'package:lucide_icons_flutter/lucide_icons.dart';

Icon(LucideIcons.activity);
```

### RTL (Right-to-Left) Support
For RTL support, use the `Dir` variant:

```dart
import 'package:lucide_icons_flutter/lucide_icons.dart';

const Directionality(
  textDirection: TextDirection.rtl,
  child: Icon(LucideIcons.aArrowDownDir),
);
```

### Stroke Weights (100 to 600)

Stroke weights are organized into modular libraries for faster compilation and optimal IDE autocomplete.

#### Option 1: Import a specific weight (Recommended)

```dart
import 'package:lucide_icons_flutter/lucide_icons_300.dart';

Icon(LucideIcons300.activity);
Icon(LucideIcons300.activityDir); // RTL support
```

#### Option 2: Import all weights at once

```dart
import 'package:lucide_icons_flutter/lucide_icons_weights.dart';

Icon(LucideIcons100.activity);
Icon(LucideIcons200.activity);
Icon(LucideIcons300.activity);
Icon(LucideIcons400.activity);
Icon(LucideIcons500.activity);
Icon(LucideIcons600.activity);
```

### Web Debug Mode (DDC) Optimization

In older versions (v3.x), bundling ~30,000 icon variants into a single class could trigger a `StackOverflowError` in DDC during Web debug mode ([dart-lang/sdk#64590](https://github.com/dart-lang/sdk/issues/64590)).

By modularizing the weights into separate libraries, `lib/lucide_icons.dart` is reduced by **~85%** (from 14 MB to ~1.8 MB), completely eliminating the DDC stack overflow issue while keeping full backwards compatibility for standard icons!

![enter image description here](https://i.imgur.com/jg26Cqu.png)

---

## 🔄 Migration Guide (v3.x ➔ v4.0.0)

Version 4.0.0 separates font weights into modular libraries for faster compilation, better tree-shaking, and instant IDE autocomplete.

### 1. Standard Icons (Zero changes needed)
If you only use regular weight icons, **you don't need to change anything**:
```dart
import 'package:lucide_icons_flutter/lucide_icons.dart';

Icon(LucideIcons.home); // Works exactly the same as before!
```

### 2. Stroke Weight Icons (100 to 600)
Weight variants are now organized into dedicated classes:

| Old (v3.x) | New (v4.0.0) | Library to Import |
| :--- | :--- | :--- |
| `LucideIcons.activity` | `LucideIcons.activity` | `package:lucide_icons_flutter/lucide_icons.dart` *(Unchanged)* |
| `LucideIcons.activityDir` | `LucideIcons.activityDir` | `package:lucide_icons_flutter/lucide_icons.dart` *(Unchanged)* |
| `LucideIcons.activity100` | `LucideIcons100.activity` | `package:lucide_icons_flutter/lucide_icons_100.dart` |
| `LucideIcons.activity200` | `LucideIcons200.activity` | `package:lucide_icons_flutter/lucide_icons_200.dart` |
| `LucideIcons.activity300` | `LucideIcons300.activity` | `package:lucide_icons_flutter/lucide_icons_300.dart` |
| `LucideIcons.activity400` | `LucideIcons400.activity` | `package:lucide_icons_flutter/lucide_icons_400.dart` |
| `LucideIcons.activity500` | `LucideIcons500.activity` | `package:lucide_icons_flutter/lucide_icons_500.dart` |
| `LucideIcons.activity600` | `LucideIcons600.activity` | `package:lucide_icons_flutter/lucide_icons_600.dart` |
| `LucideIcons.activity300Dir` | `LucideIcons300.activityDir` | `package:lucide_icons_flutter/lucide_icons_300.dart` |

> **Tip:** If your project uses multiple stroke weights, import `package:lucide_icons_flutter/lucide_icons_weights.dart` to access all weights (`LucideIcons100` – `LucideIcons600`) in one import!

---




## Related Package

### remix_icons_flutter

![Pub Version](https://img.shields.io/pub/v/remix_icons_flutter)
![Pub Monthly Downloads](https://img.shields.io/pub/dm/remix_icons_flutter)
![Pub Likes](https://img.shields.io/pub/likes/remix_icons_flutter)
![Pub Points](https://img.shields.io/pub/points/remix_icons_flutter)

A Remix Icon library package for Flutter applications. Remix Icon ([remixicon.com](https://remixicon.com)) is an open-source neutral style icon system with 2800+ icons.

📦 **Package**: [remix_icons_flutter on pub.dev](https://pub.dev/packages/remix_icons_flutter)

```dart
import 'package:remix_icons_flutter/remix_icons.dart';

Icon(RemixIcons.home_line);
Icon(RemixIcons.home_fill);
```

## Support

If you find this project useful, you can support further development by buying me a coffee:

<a href="https://buymeacoffee.com/vqh2602" target="_blank">
  <img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" height="50">
</a>




## Contributors

<a href='https://github.com/vqh2602'><img src='https://avatars.githubusercontent.com/u/62917858?v=4' width='50' height='50' alt='vqh2602' style='border-radius:50%; margin-right:8px;'></a> <a href='https://github.com/github-actions[bot]'><img src='https://avatars.githubusercontent.com/in/15368?v=4' width='50' height='50' alt='github-actions[bot]' style='border-radius:50%; margin-right:8px;'></a> <a href='https://github.com/vqh2601'><img src='https://avatars.githubusercontent.com/u/209100580?v=4' width='50' height='50' alt='vqh2601' style='border-radius:50%; margin-right:8px;'></a> <a href='https://github.com/huyvq-bachkhoa'><img src='https://avatars.githubusercontent.com/u/315601221?v=4' width='50' height='50' alt='huyvq-bachkhoa' style='border-radius:50%; margin-right:8px;'></a> <a href='https://github.com/alessandro-amos'><img src='https://avatars.githubusercontent.com/u/130871434?v=4' width='50' height='50' alt='alessandro-amos' style='border-radius:50%; margin-right:8px;'></a> <a href='https://github.com/cdeil'><img src='https://avatars.githubusercontent.com/u/852409?v=4' width='50' height='50' alt='cdeil' style='border-radius:50%; margin-right:8px;'></a> 
