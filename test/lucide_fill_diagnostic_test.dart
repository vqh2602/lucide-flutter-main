import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('generated variable fonts do not contain newly filled icons', () async {
    final python = await _findPythonWithFontTools();
    final result = await Process.run(
      python,
      ['tool/lucide/check_filled_icons.py'],
      environment: {
        ...Platform.environment,
        'PYTHONDONTWRITEBYTECODE': '1',
      },
    );

    expect(
      result.exitCode,
      0,
      reason: [
        if ((result.stdout as String).trim().isNotEmpty) result.stdout,
        if ((result.stderr as String).trim().isNotEmpty) result.stderr,
      ].join('\n'),
    );
  });
}

Future<String> _findPythonWithFontTools() async {
  final candidates = <String>{
    if ((Platform.environment['PYTHON'] ?? '').isNotEmpty)
      Platform.environment['PYTHON']!,
    'python3',
    'python',
    '/opt/homebrew/bin/python3',
    if ((Platform.environment['HOME'] ?? '').isNotEmpty)
      '${Platform.environment['HOME']}/.pyenv/versions/3.12.5/bin/python3',
  };

  for (final candidate in candidates) {
    try {
      final result = await Process.run(
        candidate,
        ['-c', 'import fontTools.ttLib'],
        environment: {
          ...Platform.environment,
          'PYTHONDONTWRITEBYTECODE': '1',
        },
      );
      if (result.exitCode == 0) {
        return candidate;
      }
    } on ProcessException {
      // Try the next Python candidate.
    }
  }

  fail(
    'Missing Python with fontTools. Install fontTools or set PYTHON to the '
    'interpreter used by tool/lucide/build_font.sh.',
  );
}
