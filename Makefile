.PHONY: test analyze build-runner run clean

## Run all tests
test:
	flutter test

## Run tests with coverage
coverage:
	flutter test --coverage
	genhtml coverage/lcov.info -o coverage/html

## Run linter
analyze:
	flutter analyze

## Auto-fix lint issues
fix:
	dart fix --apply

## Run code generation (freezed, json_serializable)
build-runner:
	dart run build_runner build --delete-conflicting-outputs

## Watch mode code generation
watch:
	dart run build_runner watch --delete-conflicting-outputs

## Run app (web-server, open URL in your browser)
run:
	flutter run -d web-server --web-port 8080

## Install dependencies
deps:
	flutter pub get

## Clean build artifacts
clean:
	flutter clean
	flutter pub get
