# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :collection_property do
    association :collection
    property "MyAttribute"
    value "MyValue"

    factory :property_dcterms_title do
      property "dcterms:title"
      value "Corpus of Oz Early English"
    end

    factory :property_dcterms_language do
      property "dcterms:language"
      value "eng"
    end

    factory :property_dcterms_created do
      property "dcterms:created"
      value "2004"
    end

    factory :property_dcterms_creator do
      property "dcterms:creator"
      value "Clemens Fritz"
    end

    factory :property_dcterms_licence do
      property "dcterms:licence"
      value "LLC Terms of Use"
    end

    factory :property_olac_anthropological_linguistics do
      property "olac:anthropological_linguistics"
      value "The SIL Ethnologue"
    end

    factory :property_olac_history_of_linguistics do
      property "olac:history_of_linguistics"
      value "A biography of Ferdinand de Saussure, or an analysis of Plato's discussions on language."
    end
  end
end
