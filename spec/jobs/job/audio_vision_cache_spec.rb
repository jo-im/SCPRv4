require 'spec_helper'

describe Job::AudioVisionCache do
  describe '::perform' do
    before :each do
      stub_request(:get, %r{billboards/current}).to_return({
        :content_type => 'application/json',
        :body => load_fixture('api/audiovision/billboard1_v1.json')
      })
    end

    it 'caches the first post if the billboard has not been cached yet' do
      Job::AudioVisionCache.perform
      Rails.cache.read("scprv4:homepage:av-featured-post").should eq AudioVision::Billboard.current.posts.first
    end


    it "caches the first post if the billboard's updated_timestamp has changed" do
      # Sanity Check
      Job::AudioVisionCache.perform
      Rails.cache.read("scprv4:homepage:av-featured-post").title.should match /Night Watch/

      # Now test that it will change
      stub_request(:get, %r{billboards/current}).to_return({
        :content_type => 'application/json',
        :body => load_fixture('api/audiovision/billboard1_updated_v1.json')
      })

      Job::AudioVisionCache.perform
      Rails.cache.read("scprv4:homepage:av-featured-post").title.should match /Thankful For/
    end

    it "caches the only post if there is only one post" do
      stub_request(:get, %r{billboards/current}).to_return({
        :content_type => 'application/json',
        :body => load_fixture('api/audiovision/billboard1_one-post_v1.json')
      })

      # Run it 5 times to be reasonably sure that it keeps choosing the same one.
      10.times do
        Job::AudioVisionCache.perform
        Rails.cache.read("scprv4:homepage:av-featured-post").title.should match /Bristlecones/
      end
    end

    it "caches a different post if the updated timestamp has not changed" do
      Job::AudioVisionCache.perform
      # Sanity Check
      featured = Rails.cache.read("scprv4:homepage:av-featured-post")
      featured.title.should match /Night Watch/ # First post

      last_title = featured.title

      # Test that it will change.
      # Do it 10 times so we can be reasonably sure
      # that it never chooses the same post twice in
      # a row.
      10.times do
        Job::AudioVisionCache.perform
        featured = Rails.cache.read("scprv4:homepage:av-featured-post")
        featured.title.should_not eq last_title
        last_title = featured.title
      end
    end

    it "writes the view cache" do
      Rails.cache.read("views/home/audiovision").should eq nil

      Job::AudioVisionCache.perform
      Rails.cache.read("views/home/audiovision").should match /Night Watch/
    end
  end
end
