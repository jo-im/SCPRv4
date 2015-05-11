require 'spec_helper'

describe ContentBase do
  all_content = []

  type_list = [:blog_entry,:content_shell,:news_story,:show_segment]

  before(:each) do
    all_content = []
    type_list.each do |ct|
      all_content << create(ct, :published)
    end
  end

  describe "::search", :indexing do
    it "searches across ContentBase classes" do
      # we indexed four different types of content above. an unspecific search
      # should return four article objects, one with each content type
      results = ContentBase.search()
      results.map { |c| c.obj_class.to_sym }.uniq.should eq type_list
    end

    it 'only gets published content by default' do
      unpublished = create :news_story, :draft

      results = ContentBase.search
      results.should_not be_empty
      results.map { |a| a.obj_key }.should_not include unpublished.obj_key
    end

    it "works with empty array conditions" do
      -> {
        ContentBase.search(with: { obj_key: [] }, without: { obj_key: [] })
      }.should_not raise_error
    end

    it 'can also get not-published content if requested' do
      unpublished = create :news_story, :draft
      results = ContentBase.search(with: { published: [true, false] })
      results.should_not be_empty
      results.map { |a| a.obj_key }.should include unpublished.obj_key
    end
  end

  #---------------

  describe '::generate_teaser' do
    it "return a blank string if text is empty" do
      ContentBase.generate_teaser(nil).should eq ''
    end

    it "returns the full first paragraph if it's short enough" do
      first = "This is just a short paragraph."
      teaser = ContentBase.generate_teaser("#{first}\n And some more!")
      teaser.should eq first
    end

    it "creates teaser from long paragraph if not defined" do
      long_body = load_fixture("long_text.txt")
      long_body.should match /\n/
      teaser = ContentBase.generate_teaser(long_body)
      teaser.should match /\ALorem ipsum (.+)\.\z/
      teaser.should_not match /\n/
    end
  end

  #---------------

  describe "::obj_by_url", :indexing do
    context "invalid URI" do
      it "returns nil" do
        ContentBase.obj_by_url("$$$$").should eq nil
      end
    end

    context "valid URI" do
      let(:article) { create :news_story }

      it "returns the matching article" do
        ContentBase.obj_by_url(article.public_url).should eq article.to_article
      end

      it "returns nil if the URI doesn't match" do
        ContentBase.obj_by_url("http://nope.com/wrong").should eq nil
      end

      it 'returns nil if the article is not published' do
        article.update_attribute(:status, article.class.status_id(:draft))
        ContentBase.obj_by_url(article.public_url).should eq nil
      end
    end
  end

  describe '::obj_by_url!', :indexing do
    it "returns the object if it's not nil" do
      ContentBase.stub(:obj_by_url) { "okedoke" }
      ContentBase.obj_by_url!("anything").should eq "okedoke"
    end

    it "raises if the return value is nil" do
      ContentBase.stub(:obj_by_url) { nil }
      -> {
        ContentBase.obj_by_url!("anything")
      }.should raise_error ActiveRecord::RecordNotFound
    end
  end


  describe '::safe_obj_by_key' do
    it "returns the object if it is allowed and published" do
      article = create :blog_entry, :published
      ContentBase.safe_obj_by_key(article.obj_key).should eq article
    end

    it "returns nil if the object is not published" do
      article = create :blog_entry, :draft
      ContentBase.safe_obj_by_key(article.obj_key).should be_nil
    end

    it "returns nil if the object isn't found" do
      ContentBase.safe_obj_by_key("nope-123").should be_nil
    end

    it "returns nil if the class isn't allowed" do
      admin_user = create :admin_user
      ContentBase.safe_obj_by_key(admin_user.obj_key).should be_nil
    end
  end

  describe '::safe_obj_by_key!' do
    it "returns the object if it's not nil" do
      ContentBase.stub(:safe_obj_by_key) { "okedoke" }
      ContentBase.safe_obj_by_key!("anything").should eq "okedoke"
    end

    it "raises if the return value is nil" do
      ContentBase.stub(:safe_obj_by_key) { nil }
      -> {
        ContentBase.safe_obj_by_key!("anything")
      }.should raise_error ActiveRecord::RecordNotFound
    end
  end
end
