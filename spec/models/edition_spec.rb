require 'spec_helper'

describe Edition do
  describe "scopes" do
    describe "::recently" do
      it "returns only recently published editions" do
        recent_edition   = create_list :edition, 1, published_at: Time.zone.now
        stale_edition    = create_list :edition, 2, published_at: Time.zone.now.yesterday
        Edition.recently.should eq recent_edition
      end
    end
  end

  describe '#slots' do
    it 'orders by position' do
      edition = build :edition
      edition.slots.to_sql.should match /order by position/i
    end
  end

  describe '::titles_collection' do
    it "is an array of all the published titles" do
      create :edition, :published, title: "Abracadabra"
      create :edition, :unpublished, title: "Marmalade"
      create :edition, :published, title: "Zealot"

      Edition.titles_collection.should eq ["Abracadabra", "Zealot"]
    end
  end

  describe '::slug_select_collection' do
    it "maps and titleizes" do
      Edition.slug_select_collection.should include ["A.M. Edition", "am-edition"]
    end
  end

  describe '#short_list_type' do
    it "is the short list type" do
      edition = build :edition, slug: 'am-edition'
      edition.short_list_type.should eq 'A.M. Edition'
    end
  end

  describe '#title' do
    it "validates title when the edition is pending" do
      edition = build :edition, :pending, title: nil
      edition.should_not be_valid
      edition.errors.keys.should eq [:title]
    end

    it "validates title when the edition is published" do
      edition = build :edition, :published, title: nil
      edition.should_not be_valid
      edition.errors.keys.should eq [:title]
    end

    it "doesn't validate title when the edition is draft" do
      edition = build :edition, :unpublished, title: nil
      edition.should be_valid
    end
  end

  describe '#abstracts' do
    it 'turns all of the items into abstracts' do
      edition   = create :edition, :published
      story     = create :news_story
      slot      = create :edition_slot, edition: edition, item: story

      edition.abstracts.map(&:class).uniq.should eq [Abstract]
    end
  end

  describe '#articles' do
    it 'turns all of the items into articles' do
      edition   = create :edition, :published
      story     = create :news_story
      slot      = create :edition_slot, edition: edition, item: story

      edition.articles.map(&:class).uniq.should eq [Article]
    end
  end

  describe '#publish' do
    it 'sets the status to published' do
      edition = create :edition, :pending
      edition.published?.should eq false
      edition.publish

      edition.reload.published?.should eq true
    end
  end

  describe '#sister_editions' do
    it 'finds 4 other editions' do
      edition = create :edition, :published
      other_editions = create_list :edition, 4, :published
      edition.sister_editions.should_not include(edition)
    end
  end

  describe "sending the e-mail" do
    describe "eloqua emails" do
      
        it "creates eloqua emails when the edition is published" do
          Timecop.freeze(Date.parse('2015-08-13')) do
            edition = build :edition, :published
            edition.eloqua_emails.length.should eq 0
            edition.save!
            edition.eloqua_emails.length.should eq 1
          end
        end

        it "doesn't create a new email if one was already sent" do
          Timecop.freeze(Date.parse('2015-08-13')) do
            edition = build :edition, :published
            edition.save!
            edition.eloqua_emails.length.should eq 1
            edition.update shortlist_email_sent: true
            edition.save!
            edition.eloqua_emails.length.should eq 1
          end
        end

        it "doesn't create a new monday email if one was already sent" do
          Timecop.freeze(Date.parse('2015-08-10')) do
            edition = build :edition, :published
            edition.save!
            edition.eloqua_emails.length.should eq 2
            edition.update shortlist_email_sent: true, monday_shortlist_email_sent: true
            edition.save!
            edition.eloqua_emails.length.should eq 2
          end
        end

        it "doesn't queue the job if the edition isn't published" do
          Timecop.freeze(Date.parse('2015-08-13')) do
            edition = build :edition, :draft
            edition.save!
            edition.eloqua_emails.length.should eq 0
          end
        end

    end
  end

  describe "emails" do
    context "tuesday through sunday" do
      it "creates one email" do
        Timecop.freeze(Date.parse('2015-08-13')) do
          edition = build :edition, :with_abstract
          edition.save
          edition.eloqua_emails.count.should eq 1
        end
      end
    end
    context "monday" do
      it "creates two emails" do
        Timecop.freeze(Date.parse('2015-08-10')) do
          edition = build :edition, :with_abstract
          edition.save
          edition.eloqua_emails.count.should eq 2
        end
      end
    end
  end

end
