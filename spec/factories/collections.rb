FactoryGirl.define do
  factory :collection do
    sequence(:name) {|n| "family_#{n}"}
    association :owner
    private "false"
    text "NO ZUO NO DIE WHY YOU TRY"
    uri {"http://localhost:3000/catalog/#{name}"}

    # factory :collection_standard_properties do
    #   [:property_dcterms_title, :property_dcterms_language, :property_dcterms_created, :property_dcterms_creator, :property_dcterms_licence, :property_olac_anthropological_linguistics].each do |p|
    #     c.collection_properties << FactoryGirl.build(:collection_property, collection: c, property: p, value: p)
    #   end
    # end

    factory :collection_no_speaker do
      name "test_no_speaker"
    end

    after(:build) do |c|
      [:property_dcterms_title, :property_dcterms_language, :property_dcterms_created, :property_dcterms_creator, :property_dcterms_licence, :property_olac_anthropological_linguistics].each do |p|
        c.collection_properties << FactoryGirl.build(:collection_property, collection: c, property: p, value: p)
      end
    end

    after(:create) do |c|
      # [:property_dcterms_title, :property_dcterms_language, :property_dcterms_created, :property_dcterms_creator, :property_dcterms_licence, :property_olac_anthropological_linguistics].each do |p|
      #     FactoryGirl.create(:collection_property, collection: c, property: p, value: p)
      # end
      c.collection_properties.each do |cp|
        cp.save
      end
    end
  end
end
