all: apk

flutter:
	flutter run

apk:
	flutter build apk

format:
	dartfmt -w ./**/*.dart

release-patch: format apk
	release-it -n -i patch

release-minor: format apk
	release-it -n -i minor

release-major: format apk
	release-it -n -i major
