require "spec_helper"

describe AdminUser do
  describe "associations" do
    it { should have_many(:activities).class_name("Secretary::Version") }
    it { should have_one(:bio) }
  end

  describe '#generate_username' do
    it "uses first initial + last name if it doesn't already exist" do
      user = create :user, name: "Jackie Brown"
      user.username.should eq "jbrown"
    end

    it "increments the number until the username is available" do
      user1 = create :user, name: "Jackie Brown"
      user2 = create :user, name: "Jackson Brown"
      user3 = create :user, name: "James Brown"
      user4 = create :user, name: "Joe Brown"

      user1.username.should eq "jbrown"
      user2.username.should eq "jbrown1"
      user3.username.should eq "jbrown2"
      user4.username.should eq "jbrown3"
    end

    it "strips out non-word characters" do
      user = create :user, name: "Leslie Berestein-Rojas"
      user.username.should eq "lberesteinrojas"
    end

    it "Only uses first and last name for 3 names" do
      user = create :user, name: "Leslie Berestein Rojas"
      user.username.should eq "lrojas"
    end
  end
end
