.PHONY: build-runner

build-runner:
	fvm flutter pub run build_runner build --delete-conflicting-outputs

publish-test:
	fvm dart format . && \
	fvm dart analyze && \
	fvm flutter pub publish --dry-run

publish:	
	fvm flutter pub publish
