# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.8.0] - 2022-01-27
### Added
- Changed the implementation of ArQueryMatchers::Queries::TableName to calculate distance of class name to table name to determine which class name is most likely. This changes how tables in `only_load_at_most_models` are calculated.

## [0.7.0] - 2022-01-27
### Added
- A new matcher, `only_load_at_most_models`, will do a less-than-or-equal-to (<=) check on model counts. This is a method that makes tests less noisy as performance gets better.

## [0.6.0] - 2022-01-05
### Changed
- Support Rails 7

## [0.5.3] - 2021-05-26
### Changed
- Re-release of previous version due to accidental premature release

## [0.5.2] - 2021-05-26
### Changed
- Update MODEL_SQL_PATTERN to allow for more accurate matches against SQL strings

## [0.5.1] - 2020-11-19
### Changed
- Removes zero count expectations from hash before comparing

## [0.5.0] - 2020-07-23
### Changed
- Add time information to query counter

## [0.4.0] - 2020-07-20
### Changed
- Upgrade the Rails dependency to allow for Rails 6.1

## [0.3.0] - 2020-03-13
### Changed
- Correct the Rails dependency to allow for Rails 6.0

## [0.2.0] - 2019-09-15
### Changed
- Package the CHANGELOG and README in the gem.
- Add additional gemspec metadata

## [0.1.0] - 2019-09-14
### Added
- First versions as a public ruby gem.

[Unreleased]: https://github.com/gusto/ar-query-matchers/compare/v0.5.1...HEAD
[0.5.1]: https://github.com/gusto/ar-query-matchers/releases/tag/v0.5.1
[0.5.0]: https://github.com/gusto/ar-query-matchers/releases/tag/v0.5.0
[0.4.0]: https://github.com/gusto/ar-query-matchers/releases/tag/v0.4.0
[0.3.0]: https://github.com/gusto/ar-query-matchers/releases/tag/v0.3.0
[0.2.0]: https://github.com/gusto/ar-query-matchers/releases/tag/v0.2.0
[0.1.0]: https://github.com/gusto/ar-query-matchers/releases/tag/v0.1.0
