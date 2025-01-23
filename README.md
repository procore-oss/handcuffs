# Handcuffs

[![Test](https://github.com/procore-oss/handcuffs/actions/workflows/test.yaml/badge.svg?branch=main)](https://github.com/procore-oss/handcuffs/actions/workflows/test.yaml)
[![Gem Version](https://badge.fury.io/rb/handcuffs.svg)](https://badge.fury.io/rb/handcuffs)
[![Discord](https://img.shields.io/badge/Chat-EDEDED?logo=discord)](https://discord.gg/PbntEMmWws)

Handcuffs provides an easy way to run [Ruby on Rails](https://rubyonrails.org/) migrations in phases using a simple process:

1. Define a set of named phases in the order in which they should be run
2. Tag migrations with one of the defined phase names
3. Run migrations by phase at start, end or outside of application deployment

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'handcuffs'
```

And then execute:

```bash
bundle
```

Or install it directly on the current system using:

```bash
gem install handcuffs
```

## Usage

### Configuration

Create a handcuffs initializer and define the migration phases in the order in which they should be run. You should also define a default phase for pre-existing "untagged" migrations, or if you want the option to tag only custom phases.

The most basic configuration is an array of phase names, and using the first one as the default:

```ruby
# config/initializers/handcuffs.rb

Handcuffs.configure do |config|
  # pre_restart migrations will/must run before post_restart migrations
  config.phases = [:pre_restart, :post_restart]
  config.default_phase = :pre_restart
end
```

If you have more complex or asynchrous workflows, you can use an alternate hash notation that allows prerequisite stages to be specified explicitly:

```ruby
# config/initializers/handcuffs.rb

Handcuffs.configure do |config|
  config.phases = {
    # Prevent running post_restart migrations if there are outstanding
    # pre_restart migrations
    post_restart: [:pre_restart],
    # Require pre_restarts before data_migrations, but do not enforce ordering
    # between data_migrations and post_restarts
    data_migrations: [:pre_restart],
    # pre_restarts have no prerequisite phases
    pre_restart: []
  }
end
```
The default phase order in this case is determined by [Tsort](https://github.com/ruby/tsort) (topological sort). In order to validate the configuration and expected phase order it is recommended that you check the phase configuration after any changes using the rake task:

```ruby
rake handcuffs:phase_order
```

This will display the default order in which phases will be run and list the prerequisites of each phase. It will raise an error if there are any circular dependencies or if any prerequisite is not a valid phase name.

### Tagging Migrations

Once configured, you can assign each migration to one of the defined phases using the `phase` setter method:

```ruby
# db/migrate/20240318230933_add_on_sale_column.rb

class AddOnSaleColumn < ActiveRecord::Migration[7.0]

  phase :pre_restart

  def change
    add_column :products, :on_sale, :boolean
  end
end
```

```ruby
# db/migrate/20240318230988_add_on_sale_index

class AddOnSaleIndex < ActiveRecord::Migration[7.0]

  phase :post_restart

  def change
    add_index :products, :on_sale, algorithm: :concurrently
  end
end
```
### Running Migrations In Phases

After Handcuffs is configured and migrations are properly tagged, you can then run migrations in phases using the `handcuffs:migrate` rake task with the specific phase to be run:

```bash
rake 'handcuffs:migrate[pre_restart]'
```

or

```bash
rake 'handcuffs:migrate[post_restart]'
```

*Note:* If you run phases out of order, or attempt to run a phase before outstanding migrations with a prerequisite phase have been run, a `HandcuffsPhaseOutOfOrderError` will be raised.

### Running All Migrations

In CI and local developement you may want to run all phases at one time.

Handcuffs offers a single command that will run all migrations in phases and in the configured order:

```bash
rake 'handcuffs:migrate[all]'
```

This differs from running `rake db:migrate` in that migrations will be run in batches corresponding to the _order that the phases are defined in the handcuffs config_. Again, you can use `rake handcuffs:phase_order` to preview the order ahead of time.

Of course, you can always run `rake db:migrate` at any time to run all migrations using the Rails default ordering and without regard to Handcuffs phase if you wish.

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/procore-oss/handcuffs>. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Running Tests Locally

The specs for handcuffs are in the dummy application at `/spec/dummy/spec`. The spec suite requires PostgreSQL. To run it you will have to set the environment variables `POSTGRES_DB_USERNAME` and `POSTGRES_DB_PASSWORD`.

We use [appraisal](https://github.com/thoughtbot/appraisal) to run our test suite against all Rails versions that we support, as a means of quickly identifying potential regressions. To do this locally, first run `bundle exec appraisal install` to ensure all required dependencies are setup, and then run `bundle exec appraisal rspec`.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## About Procore

<img
  src="https://raw.githubusercontent.com/procore-oss/.github/main/procorelightlogo.png"
  alt="Procore Open Source"
  width="250px"
/>

Handcuffs is maintained by Procore Technologies.

Procore - building the software that builds the world.

Learn more about the #1 most widely used construction management software at [procore.com](https://www.procore.com/)
