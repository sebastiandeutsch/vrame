task "db:migrate" => ["vrame:sync", "nine_auth_engine:sync"]

namespace :vrame do
  desc "Bootstrap VRAME by creating an admin user and German and English as languages"
  task :bootstrap => [:environment, "vrame:sync", "nine_auth_engine:sync", "db:migrate" ] do
    
    if Language.find_by_iso2_code('de') == nil
      puts "Adding German language"
      german = Language.create!( :name => 'Deutsch', :iso2_code => 'de', :published => true )
    end
  
    if Language.find_by_iso2_code('en') == nil
      puts "Adding English language"
      english = Language.create!( :name => 'English', :iso2_code => 'en', :published => true )
    end

    if User.find_by_email('vrame@9elements.com') == nil
      puts "Create admin user vrame"
      u = User.create!( :email => 'vrame@9elements.com', :password => 'vrame', :password_confirmation => 'vrame', :admin => true )
    end
    
    puts
    puts "Open http://localhost:3000/vrame and login with vrame@9elements.com/vrame"
    puts

  end
  
  desc "Synchronize VRAME's assets and migrations with the root application's"
  task :sync => :environment do
    require 'fileutils'
    
    # Assets
    vrame_assets = File.join(RAILS_ROOT, 'vendor', 'plugins', 'vrame', 'public', 'vrame')
    public_sync_target = File.join(RAILS_ROOT, 'public', 'vrame')
    
    # Migrations
    vrame_migrations = File.join(RAILS_ROOT, 'vendor', 'plugins', 'vrame', 'db', 'migrate', '.')
    migrations_sync_target = File.join(RAILS_ROOT, 'db', 'migrate')

    # Delete the public sync target if it already exists 
    if File.directory?(public_sync_target)
      puts "Removing existing public/vrame"
      FileUtils.rm_r(public_sync_target, :force => true)
    end
    
    # Copy vrame assets to public sync target
    puts "Copying plugin assets to public/vrame"
    FileUtils.cp_r(vrame_assets, public_sync_target)
    
    # Create empty vrame_specific.css if necessary
    vrame_specific_css = File.join(RAILS_ROOT, 'public', 'stylesheets', 'vrame_specific.css')
    File.new(vrame_specific_css, 'w').close unless File.exists?(vrame_specific_css)
    
    # Copy DB migrations
    puts "Copying migrations to db/migrate"
    FileUtils.cp_r(vrame_migrations, migrations_sync_target)
  end
end