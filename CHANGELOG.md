# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased] [diff](https://github.com/procore-oss/handcuffs/compare/v2.1.0..main)

## 2.1.0 : 2025-01-24 [diff](https://github.com/procore-oss/handcuffs/compare/v2.0.0..v2.1.0)

### Added

- Ability to specify prerequisite phases in a non-linear order

### Changed

- (internal) bumped rspec-rails gem version in development dependencies
- (internal) bumped minimum gem versions in test Rails app
- (internal) update github workflow


## 2.0.0 : 2024-02-20 [diff](https://github.com/procore-oss/handcuffs/compare/v1.4.1..v2.0.0)

### Removed

- **BREAKING CHANGE**: Removed support for Ruby < 2.7, Rails < 6.1, PostgreSQL < 12.

### Added

- CHANGELOG.md
- Code coverage for specs

### Changed

- Switched to new `cimg` docker imaged for CircleCI testing.
- Switched to matrix testing for
  - PostgreSQL 12, 13, 14, 15, 16;
  - Ruby 2.7, 3.0, 3.1, 3.2, 3.3;
  - Rails 6.1, 7.0, 7.1 (via Appraisal).
- Updated Bundler to 2.4.22.
- Added Appraisal for dummy app testing.
- Moved repo to procore-oss
