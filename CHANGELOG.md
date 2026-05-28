# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased] [diff](https://github.com/procore-oss/handcuffs/compare/v2.1.0..main)

### Removed

- **BREAKING CHANGE**: Dropped support for Ruby < 3.2.
- **BREAKING CHANGE**: Dropped support for Rails 6.1 and Rails 7.0 (both EOL October 2024).
- **BREAKING CHANGE**: Removed unused `Handcuffs::MigrationMissingPhaseError` class.
- Removed top-level `HandcuffsNotConfiguredError`, `HandcuffsPhaseUndefinedError`, `HandcuffsPhasesOutOfOrderError`, `HandcuffsRequiresPhaseArgumentError`, `HandcuffsUnknownPhaseError`, `HandcuffsPhaseUndeclaredError` constants. Use the namespaced equivalents under `Handcuffs::` instead.

### Added

- Rails 7.2 and Rails 8.0 to the supported matrix.
- Ruby 3.4 to the CI matrix.
- `Handcuffs.configuration`, `Handcuffs.configured?`, and `Handcuffs.reset_configuration!` accessors.

### Changed

- **BREAKING CHANGE**: Error classes are now namespaced under `Handcuffs::` (e.g. `Handcuffs::NotConfiguredError`, `Handcuffs::PhaseUndefinedError`, `Handcuffs::UnknownPhaseError`, `Handcuffs::UndeclaredPhaseError`, `Handcuffs::PhasesOutOfOrderError`, `Handcuffs::RequiresPhaseArgumentError`).
- **BREAKING CHANGE**: `Handcuffs::PhasesOutOfOrderError#initialize` keyword `not_run_phase:` renamed to `prerequisite_phase:`; corresponding reader renamed.
- **BREAKING CHANGE**: `Handcuffs::Extensions` renamed to `Handcuffs::Dsl`.
- **BREAKING CHANGE**: `Handcuffs.configure` without a block now raises `ArgumentError`.
- `Handcuffs::Dsl#phase` now coerces its argument with `to_sym` so string phase declarations work as expected.
- Bumped gemspec floor to `activerecord`/`activesupport`/`railties` `>= 7.1`.
- Replaced implicit monkey-patch of `ActiveRecord::Migrator` with `Handcuffs::PhaseTracker`, extended onto the migrator by the rake task.
- Migration DSL is now extended via the Railtie's `:active_record` hook instead of at top-level `require` time.
- Replaced `spec/dummy/` with a Combustion-based `spec/internal/` test harness; rewrote `.github/workflows/test.yaml` to drive the new harness.

### Fixed

- `Handcuffs::PhaseFilter#check_for_undeclared_phases!` now raises `Handcuffs::UndeclaredPhaseError` correctly. Previously both the constant lookup (`HandcuffsPhaseUndeclaredError`) and the constructor signature were wrong, so a migration declaring an unknown phase raised `NameError`/`ArgumentError` instead.

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
