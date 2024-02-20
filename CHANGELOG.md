# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## 2.0.0

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

### Removed

- BREAKING CHANGE: Removed support for Ruby < 2.7, Rails < 6.1, PostgreSQL < 12.
