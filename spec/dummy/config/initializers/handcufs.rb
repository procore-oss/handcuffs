# frozen_string_literal: true

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
