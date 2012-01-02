require "digest/md5"
Mongoid::Document::ClassMethods.send(:include, ::CarrierWave::Backgrounder::ORM::Base)
module App
  Config = YAML.load_file(Rails.root.join("config/main.yml"))[Rails.env]
end