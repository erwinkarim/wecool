
namespace :persona do
  desc 'Check storage usage'
  task :check_storage_use => :environment do
    #look for users that exceed storage allocation
    #set those photos that are overallocated to system_visible = false
    # this will need more optimization as the photo/persona count will get bigger and bigger
    Persona.all.each{ |x| x.check_storage }
  end
end
