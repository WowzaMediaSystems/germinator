# Germinator
Rails allows incremental database migrations, but only provides a single seed file (non-incremental) that causes problems when you try to run it during each application deploy.  Germinate provides a process very similar to the Rails database migrations that allows you to ensure that a data seed only gets run once in each environment.  It also provides a way to limit which Rails environments are allowed to run particular seeds, which helps protect data in sensitive environments (e.g. Production)

# Installation

To install the Germinator database table and the db/germinate directory in your Rails application:

1. Add the gem to your gemfile:

    gem "germinator", github: "WowzaMediaSystems/germinator"

2. In the terminal, make sure you're in your application directory:

    $ cd /myapplication


3. Run bundle install:

    $ bundle install

4. Generate the germinator installer:

    $ rails generate install_germinator

You're done!!

