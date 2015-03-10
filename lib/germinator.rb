module Germinator
  require 'germinator/railtie' if defined?(Rails)

  require 'germinator/base'
  require 'germinator/seeder'
  require 'germinator/seed_config'
  require 'germinator/seed'
  require 'germinator/seed_file'

  # Default table name in the database.
  VERSION_TABLE_NAME = "germinator_migrations"

  # Default seed path for the germinate files.
  SEED_PATH = "db/germinate"

  def Germinator.germinate name
    seeder = Germinator::Seeder.new
    seeder.germinate_by_name name
  end

  def Germinator.shrivel name
    seeder = Germinator::Seeder.new
    seeder.shrivel_by_name name
  end

end
