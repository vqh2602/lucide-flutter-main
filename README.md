# Remix Icons Flutter

![Pub Version](https://img.shields.io/pub/v/remix_icons_flutter)
![Pub Monthly Downloads](https://img.shields.io/pub/dm/remix_icons_flutter)
![Pub Likes](https://img.shields.io/pub/likes/remix_icons_flutter)
![Pub Points](https://img.shields.io/pub/points/remix_icons_flutter)
![Pub Publisher](https://img.shields.io/pub/publisher/remix_icons_flutter)

Remix Icon ([remixicon.com](https://remixicon.com)) for Flutter. Map to Remix Icon v4.7.0.

## Looking for Lucide Icons?

Check out [lucide_icons_flutter](https://pub.dev/packages/lucide_icons_flutter).

## Example

```dart
import 'package:remix_icons_flutter/remixicon_ids.dart';

// Use underscore for hyphenated names (e.g. 24-hours-fill -> i24HoursFill)
// Hover over the icon name in IDE to see the preview
Icon(RemixIcon.heartFill);
Icon(RemixIcon.searchLine);
```

For RTL (right-to-left) support, use the `dir()` extension to make icons automatically flip in RTL layouts:

```dart
extension IconDataX on IconData {
  /// Create Icon with matchTextDirection = true (automatically flip in RTL)
  IconData dir({
    bool matchTextDirection = true,
  }) {
    return IconData(
      codePoint,
      fontFamily: fontFamily,
      fontPackage: fontPackage,
      matchTextDirection: matchTextDirection,
    );
  }
}
```

```dart
import 'package:remix_icons_flutter/remixicon_ids.dart';

// Icon will automatically flip in RTL layouts
Icon(RemixIcon.arrowLeftLine.dir());

// You can also disable the RTL behavior if needed
Icon(RemixIcon.arrowLeftLine.dir(matchTextDirection: false));
```

## Contributors

<a href='https://github.com/vqh2602'><img src='https://avatars.githubusercontent.com/u/62917858?v=4' width='50' height='50' alt='vqh2602' style='border-radius:50%; margin-right:8px;'></a> <a href='https://github.com/github-actions[bot]'><img src='https://avatars.githubusercontent.com/in/15368?v=4' width='50' height='50' alt='github-actions[bot]' style='border-radius:50%; margin-right:8px;'></a> <a href='https://github.com/alessandro-amos'><img src='https://avatars.githubusercontent.com/u/130871434?v=4' width='50' height='50' alt='alessandro-amos' style='border-radius:50%; margin-right:8px;'></a>
