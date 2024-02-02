clean:
	rm -rv output

install:
	mkdir -p output
	dart compile exe -o output/git-auto-commit bin/git_auto_commit.dart
	cp -v output/git-auto-commit ~/.local/bin
