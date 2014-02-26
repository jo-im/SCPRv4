require "spec_helper"

describe Blog do
  describe '#entries' do
    it 'orders by published_at desc' do
      blog = build :blog
      blog.entries.to_sql.should match /order by published_at desc/i
    end
  end

  describe "scopes" do
    describe "::active" do
      it "returns only active blogs" do
        active_blogs   = create_list :blog, 1, is_active: true
        inactive_blogs = create_list :blog, 2, is_active: false
        Blog.active.should eq active_blogs
      end
    end
  end
end
