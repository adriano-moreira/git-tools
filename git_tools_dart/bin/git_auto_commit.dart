import 'dart:io';

import 'package:git_tools_dart/git_auto_commit.dart';

///TODO add interactive mode, question to [y/n] for each commit
void main(List<String> arguments) {
  if (arguments.contains("-h") || arguments.contains("--help")) {
    printHelp();
    return;
  }

  execGitAutoCommit(
    GitAutoCommitParams(
      directory: Directory.current,
      dryRun: arguments.contains("-d") || arguments.contains("--dry-run"),
      verbose: arguments.contains("-v") || arguments.contains("--verboso"),
    ),
  );
}

void printHelp() {
  print("Git Auto Commit");
  print("Usage: git-auto-commit [OPTION]...");
  print("");
  print("-v,--verbose   verbose mode true, default is false");
  print("-d,--dry-run   dry-run mode true, default is false");
  print("-h,--help      print this help");
}
