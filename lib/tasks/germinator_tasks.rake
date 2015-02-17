# desc "Explaining what the task does"
# task :germinator do
#   # Task goes here
# end

namespace :db do

  # desc "Executes all available germination files since the last germinate call."
  task :germinate, [:step] => [:environment] do |t,args|
    args.with_defaults(:step => nil)
    seeder = Germinator::Seeder.new
    seeder.germinate step: args.step
  end


  # desc "Rollback the germination files one step at a time, unless otherwise specified with STEP= parameter."
  task :shrivel, [:step] => [:environment] do |t,args|
    args.with_defaults(:step => 1)
    seeder = Germinator::Seeder.new
    seeder.shrivel step: args.step
  end


  # desc "Rolls back the database "
  task :reseed, [:step] => [:environment] do |t,args|
    args.with_defaults(:step => nil, :force => false)
    if Rails.env.production? and not args.force
      puts "This is the production environment.  Reseeding can be very dangerous.  Are you sure you want to reseed? (Yes/No)"
      input = STDIN.gets.chomp
      return unless input.downcase === 'yes'
    end

    seeder = Germinator::Seeder.new
    seeder.reseed step: args.step
  end


  # desc "Execute the plant method of a specific germination file, regardless of whether it's been run previously."
  task :plant, [:seed_name] => [:environment] do |t,args|
    args.with_defaults(:seed_name => nil)

    if args.seed_name.nil?
      puts "A seed name must be specified.  Only the name, time stamp is not required."
      puts ""
      puts "Example: rake db:plant[some_seed_name]"
      puts ""
    else
      seeder = Germinator::Seeder.new
      seeder.plant args.seed_name
    end
  end

end
