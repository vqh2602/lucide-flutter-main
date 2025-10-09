
# lucide_icons
![Pub Version](https://img.shields.io/pub/v/lucide_icons_flutter)
![Pub Monthly Downloads](https://img.shields.io/pub/dm/lucide_icons_flutter)
![Pub Likes](https://img.shields.io/pub/likes/lucide_icons_flutter)
![Pub Points](https://img.shields.io/pub/points/lucide_icons_flutter)
![Pub Publisher](https://img.shields.io/pub/publisher/lucide_icons_flutter)

version: 0.545.0

Lucide Icons ([lucide.dev](https://lucide.dev)) for Flutter. Visit the website for the full list of icons.

## Example

Use regular version

```dart
import  'package:lucide_icons_flutter/lucide_icons.dart';

Icon(LucideIcons.activity);
```

If you need to change the thickness of each icon stroke, use the way under the wire

```dart
import  'package:lucide_icons_flutter/lucide_icons.dart';
Icon(LucideIcons.activity100);
Icon(LucideIcons.activity200);
Icon(LucideIcons.activity300);
Icon(LucideIcons.activity400);
Icon(LucideIcons.activity500);
Icon(LucideIcons.activity600);
```

For RTL (right-to-left) support, use the `dir()` extension to make icons automatically flip in RTL layouts:

```dart
import  'package:lucide_icons_flutter/lucide_icons.dart';

// Icon will automatically flip in RTL layouts
Icon(LucideIcons.arrowLeft.dir());

// You can also disable the RTL behavior if needed
Icon(LucideIcons.arrowLeft.dir(matchTextDirection: false));
```

![enter image description here](https://i.imgur.com/jg26Cqu.png)


## Contributors

<a href='https://github.com/vqh2602'><img src='https://avatars.githubusercontent.com/u/62917858?v=4' width='50' height='50' alt='vqh2602' style='border-radius:50%; margin-right:8px;'></a> <a href='https://github.com/github-actions[bot]'><img src='https://avatars.githubusercontent.com/in/15368?v=4' width='50' height='50' alt='github-actions[bot]' style='border-radius:50%; margin-right:8px;'></a> <a href='https://github.com/alessandro-amos'><img src='https://avatars.githubusercontent.com/u/130871434?v=4' width='50' height='50' alt='alessandro-amos' style='border-radius:50%; margin-right:8px;'></a> 
