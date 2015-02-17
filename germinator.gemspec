$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "germinator/version"


# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "germinator"
  s.version     = Germinator::VERSION
  s.authors     = ["Jocko MacGregor"]
  s.email       = ["jocko.macgregor@wowza.com"]
  s.homepage    = "http://www.wowza.com"
  s.summary     = "Adds the ability to generate and execute sequential/incremental seed files."
  s.description = "Germinator attempts to solve the problems associated with only having one Seed file that is shared beteween environments, by creating sequential/incremental seed files, much the same way migration files work.  The seed files can also be focused to execute only in specific environments, creating a much more dependable seeding pattern for automated deployments."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  # s.add_dependency "rails", "~> 4.1.0"

  # s.add_development_dependency "activerecord-jdbcsqlite3-adapter"
end
