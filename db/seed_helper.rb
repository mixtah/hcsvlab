require 'csv'

def create_roles_and_permissions
  Role.delete_all
  Role.reset_pk_seq
  Role.create!(:name => Role::SUPERUSER_ROLE)
  Role.create!(:name => Role::RESEARCHER_ROLE)
  Role.create!(:name => Role::DATA_OWNER_ROLE)
end

# Populates the languages table with the language names and codes from the languages CSV file
def seed_languages
  logger.info "running import from CSV to populate languages table"
  csv_file = File.join('lib', 'resources', 'languages-2015-11-09.csv')
  CSV.foreach(csv_file, :headers => true) do |csv_obj|
    unless Language.exists?(code: csv_obj['Code'], name: csv_obj['Name'])
      Language.create!(:code => csv_obj['Code'], :name => csv_obj['Name'])
    end
  end
end

# Populates the licences table with the licences info from the languages CSV file
def seed_licences
  logger.info "running import from CSV to populate licences table"
  csv_file = File.join('lib', 'resources', 'licence-seed.csv')
  CSV.foreach(csv_file, :headers => true) do |csv_obj|
    unless Licence.exists?(id: csv_obj['Id'], name: csv_obj['Name'])
      Licence.create!(
          :id => csv_obj['Id'],
          :name => csv_obj['Name'],
          :text => csv_obj['Text'],
          :private => csv_obj['Private'])
    end
  end
end
