import 'dart:io';

import 'package:git_tools_dart/git_auto_commit.dart';
import 'package:test/test.dart';

void main() {
  test('run', () {
    final params = GitAutoCommitParams(
      //TODO crate a tmp repo for tests
      directory: Directory(
        '${Platform.environment['HOME']}/github/adriano-moreira/3504273',
      ),
      dryRun: true,
      verbose: true,
    );
    execGitAutoCommit(params);
  });
}
