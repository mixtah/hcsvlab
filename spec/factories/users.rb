FactoryGirl.define do
  factory :user do |f|
    f.first_name "Fred"
    f.last_name "Bloggs"
    f.password "Pas$w0rd"
    f.sequence(:email) { |n| "#{n}@alveo.edu.au" }
  end

  factory :admin do |a|
    a.first_name "admin"
    a.last_name "alveo"
    a.password "Pass.123"
    a.email "admin.alveo@mq.edu.au"

    # a.role_id Role::superuser_roles[0].id
    a.role_id 1

  end

  factory :researcher do |r|
    r.first_name "researcher"
    r.last_name "alveo"
    r.password "Pass.123"
    r.email "researcher.alveo@mq.edu.au"

    # r.role_id Role::researcher_roles[0].id
    r.role_id 2
  end

  factory :data_owner do |d|
    d.first_name "dataowner"
    d.last_name "alveo"
    d.password "Pass.123"
    d.email "dataowner.alveo@mq.edu.au"

    # d.role_id Role::data_owner_roles[0].id
    d.role_id 3
  end


end
