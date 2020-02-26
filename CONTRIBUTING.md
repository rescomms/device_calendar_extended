# Contributing to device_device_calendar_extended

## Tools

Install the necessary tools

```sh
# Export your Dart packages into PATH
export PATH="$PATH":"$HOME/.pub-cache/bin"

# Install build etc. tooling
pub global activate pubspec_version
pub global activate changelog

```

## Developing New Features (Defintion of Done)

When contributing a new feature, please follow these guidelines:
* Follows the conventions set in https://flutter.dev/docs/development/packages-and-plugins/developing-packages)
* Example application has been updated to demonstrate the API use and runs on Android and iOS
* Each feature has at least a single test that us runnable as per (Flutter Cookbook instructions)[https://flutter.dev/docs/cookbook/testing/unit/introduction
* API documentation is documented and generated with [dartdoc](https://dart.dev/tools/dartdoc)
* The commits follow [Conventional Commits convention](https://www.conventionalcommits.org/en/v1.0.0-beta.2/)

```sh
# Update documentation
dartdoc

# Add the changes to commit
git add .

# Commit the changes
git commit -m "feat(API): Added RRULE support to the model classes"
```

## Release Process
* Update package version by (SemVer convention)[https://semver.org/] using [pubspec_version](https://pub.dev/packages/pubspec_version)
* Changelog is updated using [changelog](https://pub.dev/packages/changelog) tool:

```sh
# Bump package version (switch between build/minor/major/breaking as needed).
# Commit the change, so that `cl` can do its job
pubver bump minor

# Create a stub tag so that 'cl' can do its job
git tag -a v$(pubver get) -m "Release $(pubver get)"

# Test before you publish
pub publish --dry-run

# Update CHANGELOG.md
cl -c

# Commit the changed files and create the real tag
git commit -am "Release $(pubver get)"
git tag -f -a v$(pubver get) -m "Release $(pubver get)"

# Push the changes and tags
git push origin master
git push --tags

# Publish to pub.dartlang.org
pub publish
```

## Development Topics

### Writing Tests

Each new feature should have a corresponding unit tests that demonstrates
what works and what should fail. These tests should be run with `flutter test``
as plugins may fail to initialise with plain Dart test runner.

```sh
# Execute the tests
flutter test
```

### Extending and Building the Data Models

The application uses immutable model classes, created with [built_value]()
package. These models support serialisation from JSON and other goodies.
package. When extending for new attributes, the models need to be re-generated.

```sh
# Generate code for built_value classes
flutter packages pub run build_runner build 

# When you have API breaking changes for the models, use this
flutter packages pub run build_runner build --delete-conflicting-outputs
```