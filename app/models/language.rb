class Language < ActiveRecord::Base
  attr_accessible :code, :name

  def self.reset_pk_seq
    ActiveRecord::Base.connection.reset_pk_sequence!(Language.table_name)
  end
end
