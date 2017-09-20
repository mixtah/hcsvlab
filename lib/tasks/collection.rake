
namespace :collection do

  #
  # Change the owner of a single collection
  #
  desc "Change the owner of a collection"
  task :change_owner, [:collection_name, :owner_email] => :environment do |task, args|

    collection_name = args.collection_name
    owner_email     = args.owner_email

    if (collection_name.nil? || owner_email.nil?)
      puts "Usage: rake collection:change_owner[collection_name,owner_email]"
      exit 1
    end

    unless collection = Collection.where(:name => collection_name).first
      puts "Collection not found (by name)"
      exit 1
    end

    unless owner = User.where(:email => owner_email).first
      puts "Owner not found (by email)"
      exit 1
    end

    collection.owner = owner
    if collection.save
      puts "Owner changed to #{owner.email} (User ##{owner.id})"
      exit 0
    else
      puts "Error saving"
      exit 1
    end
  end
end
