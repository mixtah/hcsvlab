def populate_data
  load_password
  create_test_users
end

def create_test_users
  create_user(:email => "jared@alveo.edu.au", :first_name => "Jared", :last_name => "Berghold")
  create_user(:email => "data_owner@alveo.edu.au", :first_name => "Data", :last_name => "Owner")
  create_user(:email => "matthew@alveo.edu.au", :first_name => "Matt", :last_name => "Hillman")
  create_user(:email => "sq@alveo.edu.au", :first_name => "Shuqian", :last_name => "Hon")
  create_user(:email => "nimda@alveo.edu.au", :first_name => "Karl", :last_name => "LI")
  create_unapproved_user(:email => "unapproved1@alveo.edu.au", :first_name => "Unapproved", :last_name => "One")
  create_unapproved_user(:email => "unapproved2@alveo.edu.au", :first_name => "Unapproved", :last_name => "Two")
  set_role("jared@alveo.edu.au", Role::SUPERUSER_ROLE)
  set_role("matthew@alveo.edu.au", Role::SUPERUSER_ROLE)
  set_role("data_owner@alveo.edu.au", Role::DATA_OWNER_ROLE)
  set_role("sq@alveo.edu.au", Role::RESEARCHER_ROLE)
  set_role("nimda@alveo.edu.au", Role::SUPERUSER_ROLE)
end

def set_role(email, role)
  user = User.where(:email => email).first
  role = Role.where(:name => role).first
  user.role = role
  user.save!
end

def create_user(attrs)
  unless User.where(:email => attrs[:email]).exists?
    u = User.new(attrs.merge(:password => @password))
    u.activate
    u.save!
  end
end

def create_unapproved_user(attrs)
  unless User.where(:email => attrs[:email]).exists?
    u = User.create!(attrs.merge(:password => @password))
    u.save!
  end
end

def load_password
  password_file = File.expand_path("#{Rails.root}/tmp/env_config/sample_password.yml", __FILE__)
  if File.exists? password_file
    puts "Using sample user password from #{password_file}"
    password = YAML::load_file(password_file)
    @password = password[:password]
    return
  end

  if Rails.env.development?
    puts "#{password_file} missing.\n" +
           "Set sample user password:"
    input = STDIN.gets.chomp
    buffer = Hash[:password => input]
    Dir.mkdir("#{Rails.root}/tmp", 0755) unless Dir.exists?("#{Rails.root}/tmp")
    Dir.mkdir("#{Rails.root}/tmp/env_config", 0755) unless Dir.exists?("#{Rails.root}/tmp/env_config")
    File.open(password_file, 'w') do |out|
      YAML::dump(buffer, out)
    end
    @password = input
  else
    raise "No sample password file provided, and it is required for any environment that isn't development\n" +
            "Use capistrano's deploy:populate task to generate one"
  end

end

