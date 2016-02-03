require 'csv'
require 'zip'
module VersionTableArchiver

  # This is here because Secretary::Version has a bug
  # which we need to address later.
  class Version < ActiveRecord::Base
    self.table_name = "versions"
  end
  class << self
    def archive!
      csv_file_name = "versions_backup_#{Time.zone.now.strftime("%m-%d-%Y_%H-%M")}.csv"
      Tempfile.open(csv_file_name) do |f|
        populate_csv file: f
        if compress_and_upload(file: f, name: csv_file_name) == true
          Version.where("created_at < ?", 1.year.ago).delete_all
          true
        else
          false
        end
      end
    end

    private
    def populate_csv(file:)
      CSV.open(file, "wb", headers: true) do |csv|
        csv << Secretary::Version.attribute_names # add headers
        Version.where("created_at < ?", 1.year.ago).find_in_batches do |batch|
          batch.each do |version|
            csv << version.attributes.values
          end
        end
      end    
    end

    def compress_and_upload(file:, name:)
      zip_file_name = "#{name}.zip"
      Tempfile.open(zip_file_name) do |zip_file|
        Zip::File.open(zip_file.path, Zip::File::CREATE) do |zip|
          zip.add name, file.path
        end
        upload file: zip_file, name: zip_file_name
      end
    end

    def upload(file:, name:)
      s3 = Aws::S3::Resource.new
      obj = s3.bucket(Rails.application.secrets.api['aws']['s3']['buckets']['versions']).object(name)
      obj.upload_file(file.path)
    end
  end

end