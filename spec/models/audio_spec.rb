require "spec_helper"

describe Audio do
  describe "scopes" do
    describe "::available" do
      it "selects only live status" do
        available   = create :audio, :direct
        unavailable = create :audio, :enco # waiting
        Audio.available.should eq [available]
      end
    end

    describe "::awaiting" do
      it "selects audio where mp3 is null" do
        unavailable   = create :audio, :enco # waiting
        available     = create :audio, :direct

        Audio.awaiting.should eq [unavailable]
      end
    end
  end


  describe '::url' do
    it "compiles a URL to the audio" do
      url = Audio.url("path", "to", "audio.mp3")

      url.should eq File.join(
        Rails.configuration.x.scpr.media_url, "audio",
        "path", "to", "audio.mp3")
    end
  end


  describe '#podcast_url' do
    it "returns the podcast URL" do
      audio = build :audio,
        url: "http://media.scpr.org/audio/airtalk/cool.mp3"

      audio.podcast_url.should eq(
        "http://media.scpr.org/podcasts/airtalk/cool.mp3")
    end
  end


  describe '#publish' do
    it "updates the status to live" do
      audio = create :audio, :enco
      audio.published?.should eq false
      audio.publish
      audio.published?.should eq true
    end
  end


  describe '#async_compute_file_info' do
    it "doesn't run if not published" do
      Resque.should_not_receive(:enqueue)
      .with(Job::ComputeAudioFileInfo, kind_of(Integer))

      audio = create :audio, :enco
    end

    it "runs on save if published and some info is missing" do
      Resque.should_receive(:enqueue)
      .with(Job::ComputeAudioFileInfo, kind_of(Integer))

      audio = create :audio, :direct
    end

    it "doesn't run if the info is filled in" do
      Resque.should_not_receive(:enqueue)
      .with(Job::ComputeAudioFileInfo, kind_of(Integer))

      audio = create :audio, :direct, duration: 0, size: 0
    end

    it "enqueues the job if persisted" do
      Resque.should_receive(:enqueue)
      .with(Job::ComputeAudioFileInfo, kind_of(Integer)).twice

      audio = create :audio, :direct
      audio.async_compute_file_info
    end

    it "doesn't enqueue the job if not persisted" do
      Resque.should_not_receive(:enqueue)
      .with(Job::ComputeAudioFileInfo, kind_of(Integer))

      audio = build :audio, :direct
      audio.async_compute_file_info.should eq false
    end
  end


  describe '#compute_file_info' do
    it "computes duration and size" do
      audio = build :audio, :direct
      audio.compute_file_info
      audio.duration.should be_present
      audio.size.should be_present
    end
  end


  describe "#compute_duration" do
    it "returns false if file is blank" do
      audio = build :audio, :direct
      audio.stub(:file)
      audio.compute_duration.should eq false
    end

    it "sets and returns the duration" do
      audio = build :audio, :direct
      audio.compute_duration
      # mp3 files are stubbed to use the 2sec file by default
      audio.duration.should eq 2
    end

    it "sets to 0 if Mp3Info can't set the duration" do
      audio = build :audio, :direct
      audio.duration.should eq nil
      Mp3Info.should_receive(:open)
      audio.compute_duration
      audio.duration.should eq 0
    end
  end


  describe "#compute_size" do
    it "returns false if file is blank" do
      audio = build :audio, :direct
      audio.stub(:file)
      audio.compute_size.should eq false
    end

    it "sets the size" do
      audio = build :audio, :direct
      audio.file.size.should > 0
      audio.compute_size
      audio.size.should eq audio.file.size
    end
  end


  describe '#file' do
    it "is nil if url is blank" do
      audio = build :audio
      audio.file.should be_nil
    end

    it "opens the file if url is present" do
      audio = build :audio, :direct
      audio.file.should be_present
      audio.file.should respond_to :read # IO enough for government work
    end
  end


  describe '#url=' do
    it "clears the file if the url is different" do
      audio = build :audio, :direct
      file = audio.file

      audio.url = "http://media.scpr.org/audio/wat.mp3"
      audio.file.should_not equal file
    end

    it "does not clear the file if the url is samesies" do
      audio = build :audio, :direct, url: "http://media.scpr.org/lol.mp3"
      file = audio.file

      audio.url = "http://media.scpr.org/lol.mp3"
      audio.file.should equal file
    end
  end


  describe 'enco_date' do
    it "parses the string date when settings enco date" do
      audio = build :audio
      audio.enco_date = "2014-02-07"
      audio.enco_date.should eq Time.zone.parse!("2014-02-07")
    end

    it "ignores the date if it can't be parsed" do
      audio = build :audio
      audio.enco_date = ""
      audio.enco_date.should eq nil
    end
  end

  describe 'validations' do
    it "validates that an audio source is provided" do
      audio = build :audio,
        :description    => "Test Audio",
        :enco_number    => nil,
        :enco_date      => nil,
        :mp3            => nil,
        :url            => nil

      audio.valid?.should eq false
      audio.errors.keys.should include :base
      audio.errors[:base].first.should match /must have a source/
    end

    it "validates enco_date isn't missing if enco_number is present" do
      audio = build :audio,
        :enco_number    => 999,
        :enco_date      => nil

      audio.valid?.should eq false
      audio.errors.keys.should include :enco_number
      audio.errors.keys.should include :enco_date
      audio.errors[:base].first.should match /must both be present/
    end

    it "validates enco_number isn't missing if enco_date is present" do
      audio = build :audio,
        :enco_number    => nil,
        :enco_date      => Date.today

      audio.valid?.should eq false
      audio.errors.keys.should include :enco_number
      audio.errors.keys.should include :enco_date
      audio.errors[:base].first.should match /must both be present/
    end

    describe "enco_number format" do
      context "trailing whitespace" do
        it "returns an error" do
          audio = build :audio,
            :enco_number    => "12345 ",
            :enco_date      => Date.today

          audio.valid?.should eq false
          audio.errors.keys.should include :enco_number
          audio.errors[:enco_number].should include "must be an integer"
        end
      end
      context "exclusively numerical characters" do
        it "is valid" do
          audio = build :audio,
            :enco_number    => "12345",
            :enco_date      => Date.today

          audio.valid?.should eq true
          audio.errors.keys.should_not include :enco_number
        end
      end
    end

  end


  describe "determining the source" do
    it "doesn't change if the source information hasn't changed" do
      audio = build :audio, :direct
      audio.save!

      url = audio.url
      audio.description = "New Description"
      audio.save!

      audio.url.should eq url
    end

    context "enco" do
      it "sets the URL and sets status to waiting" do
        audio = build :audio, :enco
        audio.url.should be_nil
        audio.status.should be_nil

        audio.save!

        audio.url.should match /\/features\/.+?\.mp3\z/
        audio.status.should eq Audio.status_id(:waiting)
      end

      it "sets the filename based on the enco date and number" do
        date = Date.new(2013, 12, 25)

        audio = build :audio, :enco, enco_number: 1234, enco_date: date
        audio.save!

        audio.url.should match /\/features\/20131225_features1234\.mp3\z/
      end
    end

    context "url" do
      it "sets the status to live" do
        audio = build :audio, :direct, url: "http://scpr.org"
        audio.status.should be_nil

        audio.save!

        audio.url.should eq "http://scpr.org"
        audio.status.should eq Audio.status_id(:live)
      end
    end

    context "mp3" do
      it "sets the URL and sets the status to live" do
        audio = build :audio, :uploaded
        audio.url.should be_nil
        audio.status.should be_nil

        audio.save!

        audio.url.should match Rails.configuration.x.scpr.audio_url
        audio.url.should match /point1sec-.+?\.mp3/
        audio.status.should eq Audio.status_id(:live)
      end

      it "updates the podcast episode cms record if one exists" do
        podcast = build :podcast, title: "The Coolest Podcast", external_podcast_id: "EXTERNAL_PODCAST_ID_STUB"
        program = build :kpcc_program, title: "The Coolest Show", podcast: podcast
        audio2 = build :audio, :uploaded, mp3: load_audio_fixture("point1sec.mp3")
        episode2 = create :show_episode, show: program, audio: [audio2]

        expect(WebMock).to have_requested(:put, %r|cms\.megaphone\.fm\/api\/|).once
      end
    end
  end

  context "validating file extension" do
    it "doesn't allow wav files" do
      audio = build :audio, :uploaded, mp3: load_audio_fixture("reallybig.wav")
      audio.should_not be_valid
      audio.errors.keys.should include :mp3
    end

    it "allows mp3 files" do
      audio = build :audio, :uploaded, mp3: load_audio_fixture("point1sec.mp3")
      audio.should be_valid
    end
  end
end
