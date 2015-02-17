require 'germinator'
require 'rails'
module Germinator
  class Railtie < Rails::Railtie
    railtie_name :germinator

    rake_tasks do
      load "tasks/germinator_tasks.rake"
    end
  end
end