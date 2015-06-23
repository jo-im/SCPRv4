require 'spec_helper'

describe SafeFilename do
  describe 'sanitizing strings' do
    it "substitutes non-ascii characters and spaces from strings" do
      fake_app = lambda{|e| e}
      env_hash = {"rack.request.form_hash" => {
        "file_name" => "ŠšÐŽžÀÁÂÃÄAÆAÇÈÉÊËÌÎÑNÒOÓOÔOÕOÖOØOUÚUUÜUÝYÞBßSàaáaâäaaæaçcèéêëìîðñòóôõöùûýýþÿƒ"
      }}
      safe_filename = SafeFilename.new fake_app
      expect(safe_filename.call(env_hash)["rack.request.form_hash"]["file_name"]).to eq("SsDjZzAAAAAAAACEEEEIINNOOOOOOOOOOOOUUUUUUYYBBSsSaaaaaaaaaacceeeeiionooooouuyybyf")
    end
  end
end
