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

  describe "select_collection" do
    it "orders by active status and title" do
      blog1 = create :blog, is_active: true, name: "BBB"
      blog2 = create :blog, is_active: true, name: "CCC"
      blog3 = create :blog, is_active: false, name: "AAA"

      Blog.select_collection.should eq [
        ["BBB", blog1.id],
        ["CCC", blog2.id],
        ["AAA", blog3.id]
      ]
    end
  end
end
