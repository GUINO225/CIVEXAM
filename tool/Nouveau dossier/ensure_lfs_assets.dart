import 'dart:io';

Future<void> main(List<String> arguments) async {
  stdout.writeln(
      '[ensure_lfs_assets] Checking Git LFS assets in ${Directory.current.path}');

  await _runCommand(
    'git',
    ['lfs', 'install'],
    'Failed to run "git lfs install". Install Git LFS from https://git-lfs.com/.',
  );

  await _runCommand(
    'git',
    ['lfs', 'pull'],
    'Failed to download LFS assets. Check your Git credentials or network access.',
  );

  final criticalFiles = <String>[
    'assets/images/logo_splash.png',
  ];

  final missingAssets = <String>[];

  for (final relativePath in criticalFiles) {
    final file = File(relativePath);
    if (!file.existsSync()) {
      missingAssets.add('$relativePath (missing)');
      continue;
    }

    final length = file.lengthSync();
    if (length <= 1024) {
      missingAssets.add(
        '$relativePath (size: $length bytes — looks like an LFS pointer file)',
      );
    }
  }

  if (missingAssets.isNotEmpty) {
    stderr.writeln('[ensure_lfs_assets] Some required assets were not downloaded:');
    for (final asset in missingAssets) {
      stderr.writeln('  • $asset');
    }
    stderr.writeln(
      '[ensure_lfs_assets] Run `git lfs pull` manually and ensure you can access the remote LFS store.',
    );
    exit(1);
  }

  stdout.writeln('[ensure_lfs_assets] Git LFS assets are present.');
}

Future<void> _runCommand(
  String executable,
  List<String> arguments,
  String errorMessage,
) async {
  stdout.writeln('[ensure_lfs_assets] Running: $executable ${arguments.join(' ')}');

  ProcessResult result;
  try {
    result = await Process.run(executable, arguments, runInShell: true);
  } on ProcessException catch (error) {
    stderr.writeln('[ensure_lfs_assets] $errorMessage');
    stderr.writeln('  $error');
    exit(1);
  }

  final stdoutContent = result.stdout?.toString() ?? '';
  if (stdoutContent.isNotEmpty) {
    stdout.write(stdoutContent);
  }

  final stderrContent = result.stderr?.toString() ?? '';
  if (stderrContent.isNotEmpty) {
    stderr.write(stderrContent);
  }

  if (result.exitCode != 0) {
    stderr.writeln('[ensure_lfs_assets] $errorMessage');
    stderr.writeln('Command exited with status ${result.exitCode}.');
    exit(result.exitCode);
  }
}
