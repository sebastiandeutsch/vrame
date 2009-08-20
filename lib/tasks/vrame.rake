namespace :vrame do
  desc "Bootstrap VRAME by creating an admin user and German and English as languages"
  task :bootstrap => :environment do
    
    if Language.find_by_iso3_code('deu') == nil
      puts "Adding German language"
      german = Language.create!( :name => 'Deutsch', :iso3_code => 'deu', :published => true )
    end
  
    if Language.find_by_iso3_code('eng') == nil
      puts "Adding English language"
      english = Language.create!( :name => 'English', :iso3_code => 'eng', :published => true )
    end

    if User.find_by_email('vrame@9elements.com') == nil
      puts "Create admin user vrame"
      u = User.create!( :email => 'vrame@9elements.com', :password => 'vrame', :password_confirmation => 'vrame' )
    end

  end
  
  desc "Synchronize VRAME's assets with the root application's"
  task :sync => :environment do
    require 'fileutils'
    
    vrame_assets = File.join(RAILS_ROOT, 'vendor', 'plugins', 'vrame', 'public', 'vrame')
    sync_target  = File.join(RAILS_ROOT, 'public', 'vrame')

    # Delete the sync target if it already exists 
    if File.directory?(sync_target)
      puts "Removing existing public/vrame"
      FileUtils.rm_r(sync_target, :force => true)
    end
    
    # Copy vrame assets to sync target
    puts "Copying plugin assets to public/vrame"
    FileUtils.cp_r(vrame_assets, sync_target)
  end
end