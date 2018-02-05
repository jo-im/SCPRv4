require "spec_helper"

describe SitemapsController do
  render_views

  ["episodes", "segments", "queries", "blogs", "programs", "bios"].each do |sitemap|
    describe sitemap do
      it "sets @content" do
        get sitemap.to_sym
        assigns(:content).should_not be_nil
      end

      it "renders sitemap.xml" do
        get sitemap.to_sym
        response.should render_template 'sitemap'
        response.header['Content-Type'].should match /xml/
      end
    end
  end

  ["stories", "blog_entries"].each do |sitemap|
    describe sitemap do
      it "sets @content" do
        get sitemap.to_sym
        assigns(:content).should_not be_nil
      end

      it "renders sitemap.xml" do
        get sitemap.to_sym
        response.should render_template 'news'
        response.header['Content-Type'].should match /xml/
      end
    end
  end

end
