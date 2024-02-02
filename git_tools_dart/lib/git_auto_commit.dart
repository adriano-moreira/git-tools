import 'dart:io';

class GitAutoCommitParams {
  final Directory directory;
  final bool dryRun;
  final bool verbose;

  GitAutoCommitParams({
    required this.directory,
    required this.dryRun,
    required this.verbose,
  });
}

void execGitAutoCommit(GitAutoCommitParams params) {
  var rootPath = params.directory.absolute.path;
  final filesFromGit = _getFilesFromGit(rootPath);
  final itemsToCommit = _prepareToCommit(rootPath, filesFromGit);
  if (params.verbose || params.dryRun) {
    print('auto commit');
    print('verbose: ${params.verbose}');
    print('dryRun: ${params.dryRun}');
  }
  print('auto commit');
  for (var toCommit in itemsToCommit) {
    if (params.verbose || params.dryRun) {
      print('to commit: ${toCommit.relativeName}  ${toCommit.lastChange}');
    }
    if (!params.dryRun) {
      gitAdd(
        rootPath,
        toCommit.relativeName,
      );
      gitCommit(
        rootPath,
        'auto commit: ${toCommit.lastChange.toIso8601String()}',
        toCommit.lastChange,
      );
    }
  }
}

List<ToCommit> _prepareToCommit(String rootPath, List<String> filesFromGit) {
  final list = <ToCommit>[];
  for (var relativeName in filesFromGit) {
    if (relativeName.endsWith('/')) {
      final dir = Directory('$rootPath/$relativeName');
      final exists = dir.existsSync();
      list.add(
        ToCommit(
          relativeName: relativeName,
          lastChange: exists ? dir.statSync().modified : DateTime.now(),
        ),
      );
    } else {
      final file = File('$rootPath/$relativeName');
      final exists = file.existsSync();
      list.add(
        ToCommit(
          relativeName: relativeName,
          lastChange: exists ? file.lastModifiedSync() : DateTime.now(),
        ),
      );
    }
  }
  list.sort((o1, o2) => o1.lastChange.compareTo(o2.lastChange));
  return list;
}

class ToCommit {
  final String relativeName;
  final DateTime lastChange;

  ToCommit({
    required this.relativeName,
    required this.lastChange,
  });
}

void gitAdd(String rootPath, String relativeFile) {
  final executable = 'git';
  final arguments = ['add', relativeFile];
  final p = Process.runSync(
    executable,
    arguments,
    workingDirectory: rootPath,
  );
  print(p.stdout);
  if (p.exitCode != 0) {
    print('[ERROR] "git add $relativeFile" returned ${p.exitCode}');
    print(p.stderr);
    throw Error.safeToString('...');
  }
}

void gitCommit(String rootPath, String msg, DateTime date) {
  final executable = 'git';
  final arguments = ['commit', '-m', msg];
  var p = Process.runSync(
    executable,
    arguments,
    workingDirectory: rootPath,
    environment: {
      'GIT_AUTHOR_DATE': date.toIso8601String(),
      'GIT_COMMITTER_DATE': date.toIso8601String(),
    },
  );
  print(p.stdout);
  if (p.exitCode != 0) {
    print('[ERROR] "git commit ..." returned ${p.exitCode}');
    print(p.stderr);
    throw Error.safeToString('error on');
  }
}

List<String> _getFilesFromGit(String rootPath) {
  final list = <String>[];

  final executable = 'git';
  final arguments = ['status', '--short'];
  var p = Process.runSync(executable, arguments, workingDirectory: rootPath);

  if (p.exitCode != 0) {
    print('[ERROR] "git status --short" returned ${p.exitCode}');
    print(p.stderr);
  }

  for (var line in p.stdout.toString().split('\n')) {
    if (line.isEmpty) continue;
    final file = line.substring(3);
    list.add(file);
  }

  return list;
}
