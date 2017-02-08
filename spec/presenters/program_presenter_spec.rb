require "spec_helper"

describe ProgramPresenter do
  describe "#teaser" do
    it "returns html_safe teaser if it's present" do
      program = build :kpcc_program, teaser: "This is <b>cool</b> teaser, bro."
      p = presenter(program)
      p.teaser.should eq "This is <b>cool</b> teaser, bro."
      p.teaser.html_safe?.should eq true
    end

    it "returns nil if teaser not present" do
      program = build :kpcc_program, teaser: nil
      p = presenter(program)
      p.teaser.should eq nil
    end
  end

  #--------------------

  describe "#description" do
    it "returns html_safe description if it's present" do
      program = build :kpcc_program, description: "This is <b>cool</b> description, bro."
      p = presenter(program)
      p.description.should eq "This is <b>cool</b> description, bro."
      p.description.html_safe?.should eq true
    end

    it "returns nil if description not present" do
      program = build :kpcc_program, description: nil
      p = presenter(program)
      p.description.should eq nil
    end
  end

  #--------------------

  describe "#airtime" do
    it "returns html_safe airtime if it's present" do
      program = build :kpcc_program, airtime: "<em>all the time</em>. It's the only show we got."
      p = presenter(program)
      p.airtime.should eq "<h3>Airs <em>all the time</em>. It's the only show we got.</h3>"
      p.airtime.html_safe?.should eq true
    end

    it "returns nil if airtime not present" do
      program = build :kpcc_program, airtime: nil
      p = presenter(program)
      p.airtime.should eq nil
    end
  end

  #--------------------

  describe "#web_link" do
    it "returns program.web_url if specified" do
      program = build :external_program
      program.related_links.build(title: "Website", url: "scpr.org/airtalk", link_type: "website")
      p = presenter(program)
      # p.web_link.should match %r{scpr\.org/airtalk}
    end

    it "returns nil if not specified" do
      program = build :external_program
      p = presenter(program)
      p.web_link.should eq nil
    end
  end

  describe "#podcast_link" do
    context "for external programs" do
      it "returns program.podcast_url if specified" do
        program = build :external_program, podcast_url: "podcast.com/airtalk"
        p = presenter(program)
        # p.podcast_link.should match %r{podcast\.com/airtalk}
      end

      it "returns nil if no podcast_url present" do
        program = build :external_program, podcast_url: nil
        p = presenter(program)
        p.podcast_link.should eq nil
      end
    end

    context "for kpcc programs" do
      it "gets podcast related link for kpcc programs" do
        program = build :kpcc_program
        program.related_links.build(title: "Podcast", url: "http://podcast.com/airtalk", link_type: "podcast")
        p = presenter(program)
        # p.podcast_link.should match %r{podcast\.com/airtalk}
      end

      it "returns nil if no podcast link present" do
        program = build :kpcc_program
        p = presenter(program)
        p.podcast_link.should eq nil
      end
    end
  end

  describe "#rss_link" do
    it "returns program.rss_url if specified" do
      program = build :external_program
      program.related_links.build(title: "RSS", url: "show.com/airtalk", link_type: "rss")
      p = presenter(program)
      # p.rss_link.should match %r{show\.com/airtalk}
    end

    it "returns nil if not specified" do
      program = build :external_program
      p = presenter(program)
      p.rss_link.should eq nil
    end
  end


  describe "#facebook_link" do
    it "returns the facebook link if specified" do
      program = build :kpcc_program
      program.related_links.build(title: "Facebook", url: "facebook.com/airtalk", link_type: "facebook")
      p = presenter(program)
      # p.facebook_link.should match %r{facebook\.com/airtalk}
    end

    it "returns nil if not specified" do
      program = build :kpcc_program
      p = presenter(program)
      p.facebook_link.should eq nil
    end
  end

  describe "#twitter_link" do
    it "returns the twitter url if twitter related link is present" do
      program = build :kpcc_program
      program.related_links.build(title: "Twitter", url: "airtalk", link_type: "twitter")
      p = presenter(program)
      # p.twitter_link.should match %r{twitter\.com/airtalk}
    end

    it "returns nil if not specified" do
      program = build :kpcc_program
      p = presenter(program)
      p.twitter_link.should eq nil
    end
  end

  describe "#email_link" do
    it "returns the email link if specified" do
      program = build :kpcc_program
      program.related_links.build(title: "Email", url: "mailto:bricker@scpr.org", link_type: "email")
      p = presenter(program)
      # p.email_link.should match %r{mailto:bricker@scpr\.org}
    end

    it "returns nil if not specified" do
      program = build :kpcc_program
      p = presenter(program)
      p.email_link.should eq nil
    end
  end
end
