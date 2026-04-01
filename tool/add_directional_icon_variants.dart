import 'dart:io';

void main(List<String> args) {
  final repoRoot = findRepoRoot();
  final targetFile = resolveTargetFile(
    args.isEmpty ? 'lib/lucide_icons.dart' : args.first,
    repoRoot,
  );

  if (!targetFile.existsSync()) {
    stderr.writeln('Target file not found: ${targetFile.path}');
    exit(66);
  }

  final originalLines = targetFile.readAsLinesSync();
  final outputLines = <String>[];

  for (final line in originalLines) {
    final declaration = parseIconDeclaration(line);

    if (declaration == null) {
      outputLines.add(line);
      continue;
    }

    if (declaration.isDirectionalVariant) {
      continue;
    }

    outputLines.add(line);
    outputLines.add(buildDirectionalLine(declaration));
  }

  targetFile.writeAsStringSync('${outputLines.join('\n')}\n');
}

IconDeclaration? parseIconDeclaration(String line) {
  final match = RegExp(
    r"^(\s*)static const IconData (\w+) = const LucideIconData\((.+)\);\s*$",
  ).firstMatch(line);

  if (match == null) {
    return null;
  }

  final indent = match.group(1)!;
  final name = match.group(2)!;
  final arguments = match.group(3)!.trim();

  return IconDeclaration(
    indent: indent,
    name: name,
    arguments: arguments,
  );
}

String buildDirectionalLine(IconDeclaration declaration) {
  final directionalArguments =
      declaration.arguments.contains(RegExp(r'\bmatchTextDirection\s*:'))
          ? declaration.arguments
          : '${declaration.arguments}, matchTextDirection: true';

  return '${declaration.indent}static const IconData '
      '${declaration.name}Dir = const LucideIconData($directionalArguments);';
}

Directory findRepoRoot() {
  var current = Directory.current.absolute;

  while (true) {
    if (File('${current.path}/pubspec.yaml').existsSync()) {
      return current;
    }

    final parent = current.parent;
    if (parent.path == current.path) {
      throw StateError('Khong tim thay pubspec.yaml de xac dinh repo root.');
    }

    current = parent;
  }
}

File resolveTargetFile(String inputPath, Directory repoRoot) {
  final file = File(inputPath);
  if (file.isAbsolute) {
    return file;
  }

  final fromCwd = File('${Directory.current.path}/$inputPath');
  if (fromCwd.existsSync()) {
    return fromCwd;
  }

  return File('${repoRoot.path}/$inputPath');
}

class IconDeclaration {
  const IconDeclaration({
    required this.indent,
    required this.name,
    required this.arguments,
  });

  final String indent;
  final String name;
  final String arguments;

  bool get isDirectionalVariant =>
      name.endsWith('Dir') && arguments.contains('matchTextDirection: true');
}
