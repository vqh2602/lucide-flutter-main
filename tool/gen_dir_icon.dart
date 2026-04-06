import 'dart:io';

void main(List<String> args) {
  final repoRoot = findRepoRoot();
  final targetFile = resolveTargetFile(
    args.isEmpty ? 'lib/remixicon_ids.dart' : args.first,
    repoRoot,
  );

  if (!targetFile.existsSync()) {
    stderr.writeln('Target file not found: ${targetFile.path}');
    exit(66);
  }

  final originalLines = targetFile.readAsLinesSync();
  final outputLines = <String>[];
  var foundDeclaration = false;

  for (var index = 0; index < originalLines.length;) {
    final block = tryParseDeclarationBlock(originalLines, index);

    if (block == null) {
      outputLines.add(originalLines[index]);
      index++;
      continue;
    }

    foundDeclaration = true;

    if (!block.declaration.isDirectionalVariant) {
      outputLines.addAll(block.lines);
      outputLines.addAll(buildDirectionalBlock(block.declaration));
    }

    index = block.endIndex;
  }

  if (!foundDeclaration) {
    stderr.writeln('Khong tim thay khai bao IconData trong ${targetFile.path}');
    exit(65);
  }

  targetFile.writeAsStringSync('${outputLines.join('\n')}\n');
}

DeclarationBlock? tryParseDeclarationBlock(List<String> lines, int startIndex) {
  if (!lines[startIndex].contains('static const IconData ')) {
    return null;
  }

  final blockLines = <String>[];
  var endIndex = startIndex;

  while (endIndex < lines.length) {
    final line = lines[endIndex];
    blockLines.add(line);

    if (line.trimRight().endsWith(');')) {
      break;
    }

    endIndex++;
  }

  final declaration = parseIconDeclaration(blockLines.join('\n'));
  if (declaration == null) {
    return null;
  }

  return DeclarationBlock(
    declaration: declaration,
    lines: blockLines,
    endIndex: endIndex + 1,
  );
}

IconDeclaration? parseIconDeclaration(String block) {
  final match = RegExp(
    r'^(\s*)static const IconData (\w+)\s*=\s*(const\s+)?([A-Za-z_]\w*)\(([\s\S]*?)\);\s*$',
  ).firstMatch(block);

  if (match == null) {
    return null;
  }

  final indent = match.group(1)!;
  final name = match.group(2)!;
  final constructorPrefix = match.group(3) ?? '';
  final constructorName = match.group(4)!;
  final arguments = match.group(5)!.trim();

  return IconDeclaration(
    indent: indent,
    name: name,
    constructorPrefix: constructorPrefix,
    constructorName: constructorName,
    arguments: arguments,
  );
}

List<String> buildDirectionalBlock(IconDeclaration declaration) {
  final directionalArguments = declaration.directionalArguments;
  final block = '${declaration.indent}static const IconData '
      '${declaration.name}Dir =\n'
      '${declaration.indent}    ${declaration.constructorPrefix}'
      '${declaration.constructorName}($directionalArguments);';

  return block.split('\n');
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

class DeclarationBlock {
  const DeclarationBlock({
    required this.declaration,
    required this.lines,
    required this.endIndex,
  });

  final IconDeclaration declaration;
  final List<String> lines;
  final int endIndex;
}

class IconDeclaration {
  const IconDeclaration({
    required this.indent,
    required this.name,
    required this.constructorPrefix,
    required this.constructorName,
    required this.arguments,
  });

  final String indent;
  final String name;
  final String constructorPrefix;
  final String constructorName;
  final String arguments;

  bool get isDirectionalVariant =>
      name.endsWith('Dir') &&
      RegExp(r'\bmatchTextDirection\s*:\s*true\b').hasMatch(arguments);

  String get directionalArguments {
    final matchTextDirectionPattern =
        RegExp(r'\bmatchTextDirection\s*:\s*(true|false)\b');

    if (matchTextDirectionPattern.hasMatch(arguments)) {
      return arguments.replaceFirst(
        matchTextDirectionPattern,
        'matchTextDirection: true',
      );
    }

    return '$arguments, matchTextDirection: true';
  }
}
