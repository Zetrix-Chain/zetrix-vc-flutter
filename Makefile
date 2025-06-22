.PHONY: build-runner

build-runner:
	fvm flutter pub run build_runner build --delete-conflicting-outputs
