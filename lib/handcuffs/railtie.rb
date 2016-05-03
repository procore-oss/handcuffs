module Handcuffs
  class Railtie < Rails::Railtie
    rake_tasks do
      load "tasks/handcuffs.rake"
    end
  end
end
