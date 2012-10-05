require "spec_helper"

describe Audio do
  describe "associations" do
    it { should belong_to(:content) }
  end


  #----------------
  #----------------
  
  describe "validations" do
    context "enco" do
      it "fails if enco_number present but not enco_date" do
        audio = build :audio, enco_date: nil, enco_number: 999
        audio.should_not be_valid
        audio.errors.keys.should eq [:base]
      end
    
      it "fails if enco_date present but not enco_number" do
        audio = build :audio, enco_date: Date.today, enco_number: nil
        audio.should_not be_valid
        audio.errors.keys.should eq [:base]
      end
    
      it "passes if enco_date and enco_number are present" do
        audio = build :audio, enco_date: Date.today, enco_number: 999
        audio.should be_valid
      end
    
      it "passes if neither enco_date nor enco_number were provided" do
        audio = build :audio, :direct, enco_date: nil, enco_number: nil
        audio.should be_valid
      end
    end
    
    it "validates audio source is provided" do
      audio = build :audio, enco_date: nil, enco_number: nil, mp3_path: nil, mp3: ""
      audio.should_not be_valid
      audio.errors.keys.should eq [:base]
    end
  end
  
  
  #----------------
  #----------------
  
  describe "scopes" do
    describe "::available" do
      it "selects only audio objects with mp3 present" do
        available   = create :audio, :uploaded
        unavailable = create :audio, :enco # mp3 is blank
        Audio.available.should eq [available.becomes(Audio::UploadedAudio)]
      end
      
      it "treats null and blank mp3 the same" do
        available = create :audio, :uploaded
        blank     = create :audio, :enco, mp3: nil
        empty     = create :audio, :enco, mp3: ""
        
        blank.mp3.should be_blank
        empty.mp3.should be_blank
        
        Audio.available.should eq [available.becomes(Audio::UploadedAudio)]
      end
    end

    #----------------
    
    describe "::awaiting_audio" do
      it "selects audio where mp3 is null" do
        null_mp3 = create :audio, :enco
        live     = create :audio, :uploaded
        
        null_mp3.mp3.should be_blank
        
        Audio.awaiting_audio.should eq [null_mp3.becomes(Audio::EncoAudio)]
      end
      
      it "selects audio with blank mp3" do
        blank_mp3 = create :audio, :enco, mp3: ""
        live      = create :audio, :uploaded
        
        blank_mp3.mp3.should be_blank
        
        Audio.awaiting_audio.should eq [blank_mp3.becomes(Audio::EncoAudio)]
      end
    end
  end
  
  
  #----------------
  #----------------
  
  describe "callbacks" do
    it "receives set_file_info before create" do
      audio = create :audio, :uploaded
      audio.filename.should_not be_blank
      audio.store_dir.should_not be_blank
      Audio.any_instance.should_not_receive(:set_file_info)
      audio.save
    end
    
    it "gets set_type before create only if type is blank" do
      audio = create :audio, :direct, type: nil
      audio.type.should_not be_blank
      Audio.any_instance.should_not_receive(:set_type)
      audio.save!
    end
    
    it "receives async_compute_file_info if mp3 is present and size and duration are blank" do
      Audio.any_instance.should_receive(:async_compute_file_info).once
      create :audio, :uploaded, duration: nil, size: nil
    end
    
    it "receives async_compute_file_fields if duration is present but not size" do
      Audio.any_instance.should_receive(:async_compute_file_info)
      create :audio, :uploaded, duration: 999, size: nil
    end

    it "receives async_compute_file_fields if size is present but not duration" do
      Audio.any_instance.should_receive(:async_compute_file_info)
      create :audio, :uploaded, duration: 999, size: nil
    end
    
    it "doesn't receive async_compute_file_fields if duration and size are present" do
      Audio.any_instance.should_not_receive(:async_compute_file_info)
      create :audio, :uploaded, duration: 999, size: 8000
    end
    
    it "doesn't receive async_compute_file_fields if mp3 is not present" do
      Audio.any_instance.should_not_receive(:async_compute_file_info)
      create :audio, :enco
    end
  end
  

  #----------------
  #----------------

  describe "::sync!" do
    it "enqueues SyncAudioJob for each class that should be automagically synced" do
      Resque.should_receive(:enqueue).with(Audio::SyncAudioJob, Audio::EncoAudio).once
      Resque.should_receive(:enqueue).with(Audio::SyncAudioJob, Audio::ProgramAudio).once
      Resque.should_receive(:enqueue).with(Audio::SyncAudioJob, Audio::DirectAudio).once
      Audio.sync!
    end
  end
  
  
  #----------------
  #----------------
  
  describe "#status_text" do
    it "uses the STATUS_TEXT hash to return some descriptive text" do
      audio = build :audio, :uploaded
      audio.status_text.should eq Audio::STATUS_TEXT[audio.status]
    end
  end

  #----------------
  
  describe "#status" do
    it "returns STATUS_LIVE if mp3 is present" do
      audio = build :audio, :uploaded
      audio.status.should eq Audio::STATUS_LIVE
    end
    
    it "returns STATUS_WAIT if mp3 blank but enco information present" do
      audio = build :audio, :enco
      audio.status.should eq Audio::STATUS_WAIT
    end
    
    it "returns STATUS_NONE if mp3 and enco information blank" do
      audio = build :audio
      audio.status.should eq Audio::STATUS_NONE
    end
  end
  
  #----------------
  
  describe "#live?" do
    it "is true if status is live" do
      audio = build :audio
      audio.stub(:status) { Audio::STATUS_LIVE }
      audio.live?.should be_true
    end
    
    it "is false is status is waiting" do
      audio = build :audio
      audio.stub(:status) { Audio::STATUS_WAIT }
      audio.live?.should be_false
    end
  end
  
  #----------------

  describe "#awaiting?" do
    it "is true if status is waiting" do
      audio = build :audio
      audio.stub(:status) { Audio::STATUS_WAIT }
      audio.awaiting?.should be_true
    end
    
    it "is false is status is live" do
      audio = build :audio
      audio.stub(:status) { Audio::STATUS_LIVE }
      audio.awaiting?.should be_false
    end
  end
  
  
  #----------------
  #----------------

  describe "#path" do
    it "returns the store_dir and the filename" do
      audio = create :audio, :direct
      audio.stub(:store_dir) { "somedir" }
      audio.stub(:filename)  { "something.mp3" }
      audio.path.should eq "somedir/something.mp3"
    end
  end
  
  #----------------
  
  describe "#full_path" do
    it "returns the server path to the mp3 if mp3 is present" do
      Rails.application.config.scpr.stub(:media_root) { "/some/path" }
      audio = create :audio, :uploaded
      audio.full_path.should eq "/some/path/audio/#{audio.path}"
    end    
  end
  
  #----------------
  
  describe "#url" do
    it "returns the full URL to the mp3 if it's live" do
      audio = create :audio, :uploaded
      audio.url.should eq "#{Audio::AUDIO_URL_ROOT}/#{audio.path}"      
    end
    
    it "returns nil if not live" do
      audio = create :audio, :enco
      audio.url.should be_nil
    end
  end

  #----------------
  
  describe "#podcast_url" do
    it "returns the full podcast URL to the mp3 if it's live" do
      audio = create :audio, :uploaded
      audio.podcast_url.should eq "#{Audio::PODCAST_URL_ROOT}/#{audio.path}"
    end
    
    it "returns nil if mp3 not live" do
      audio = create :audio, :enco
      audio.podcast_url.should be_nil
    end
  end


  #----------------
  #----------------

  describe "#set_type" do
    it "sets to UploadedAudio if audio is live" do
      audio = create :audio, :uploaded
      audio.type.should eq "Audio::UploadedAudio"
    end
    
    it "sets to EncoAudio if enco number and date present" do
      audio = create :audio, :enco
      audio.type.should eq "Audio::EncoAudio"
    end
    
    it "sets to DirectAudio if mp3_path is present" do
      audio = create :audio, :direct
      audio.type.should eq "Audio::DirectAudio"
    end    
  end

  #----------------
  
  describe "#set_file_info" do
    it "doesn't happen if type is blank" do
      audio = build :audio, :enco
      audio.set_file_info
      audio.filename.should be_blank
    end
    
    context "for episode audio" do
      it "sends it off to ProgramAudio class methods" do
        audio = build :audio, :program, :for_episode, type: "Audio::ProgramAudio"
        Audio::ProgramAudio.should_receive(:filename).with(audio)
        Audio::ProgramAudio.should_receive(:store_dir).with(audio)

        audio.set_file_info
      end
    end
    
    context "for segment audio" do
      it "sets file info" do
        audio = build :audio, :program, :for_segment
        audio.content.show.update_attribute(:audio_dir, "coolshow")
        audio.save!
        audio.type.should eq "Audio::ProgramAudio"
        audio.store_dir.should eq "coolshow"
        audio.filename.should eq "20121002_mbrand.mp3"
      end
    end
    
    context "for uploaded audio" do
      it "sets file info" do
        time = freeze_time_at "October 21 1988"
        audio = build :audio, :uploaded
        audio.save!
        audio.type.should eq "Audio::UploadedAudio"
        audio.store_dir.should eq "upload/1988/10/21"
        audio.filename.should eq "point1sec.mp3"
      end
    end
    
    context "for enco audio" do
      it "sets file info" do
        audio = build :audio, :enco, enco_number: "99", enco_date: "October 21, 1988"
        audio.save!
        audio.type.should eq "Audio::EncoAudio"
        audio.store_dir.should eq "features"
        audio.filename.should eq "19881021_features99.mp3"
      end
    end
    
    context "for direct audio" do
      it "sets file info" do
        audio = build :audio, :direct, mp3_path: "some/cool/thing/audio.mp3"
        audio.save!
        audio.type.should eq "Audio::DirectAudio"
        audio.store_dir.should eq "some/cool/thing"
        audio.filename.should eq "audio.mp3"
      end
    end
  end
  
  
  #----------------
  #----------------

  describe "#compute_duration" do
    it "returns false if mp3 is blank" do
      audio = create :audio, :enco
      audio.compute_duration.should be_false
    end
    
    it "asks Mp3Info to open the file" do
      audio = create :audio, :uploaded
      Mp3Info.should_receive(:open).with(audio.mp3.path)
      audio.compute_duration
    end
    
    it "sets and returns the duration" do
      # Use the bigger file here because the `point1sec` file duration gets rounded down
      audio = create :audio, :uploaded, mp3: File.open(Rails.application.config.scpr.media_root.join("audio/2sec.mp3"))
      audio.compute_duration.should eq 2
      audio.duration.should eq 2
    end
    
    it "sets and returns 0 if Mp3Info can't set the duration" do
      audio = create :audio, :uploaded
      audio.duration.should be_nil
      Mp3Info.should_receive(:open)
      audio.compute_duration.should eq 0
      audio.duration.should eq 0
    end
  end

  #----------------
  
  describe "#compute_size" do
    it "returns false if mp3 is blank" do
      audio = create :audio, :enco
      audio.compute_size.should be_false
    end
    
    it "sets and returns the size" do
      audio = create :audio, :uploaded, mp3: File.open(Rails.application.config.scpr.media_root.join("audio/2sec.mp3"))
      audio.size.should be_nil
      audio.mp3.file.size.should > 0
      audio.compute_size.should eq audio.mp3.file.size
      audio.size.should eq audio.mp3.file.size
    end
  end
  
  #----------------
  
  describe "#async_compute_file_info" do
    it "sends off to Resque" do
      audio = build :audio, :uploaded
      Resque.should_receive(:enqueue).with(Audio::ComputeFileInfoJob, audio)
      audio.async_compute_file_info
    end
  end
  
  #----------------
  
  describe "::enqueue_sync" do
    it "sends off to Resque" do
      Resque.should_receive(:enqueue).with(Audio::SyncAudioJob, Audio)
      Audio.enqueue_sync
    end
    
    it "does it for subclasses" do
      Resque.should_receive(:enqueue).with(Audio::SyncAudioJob, Audio::EncoAudio)
      Audio::EncoAudio.enqueue_sync
    end
  end
  
  #----------------

  describe Audio::ComputeFileInfoJob do
    describe "::perform" do
      it "computes duration and size, and saves" do
        audio = build :audio, :uploaded
        audio.should_receive(:compute_duration)
        audio.should_receive(:compute_size)
        audio.should_receive(:save)
        Audio::ComputeFileInfoJob.perform(audio)
      end
    end
  end

  #----------------
  
  describe Audio::SyncAudioJob do
    describe "::perform" do
      it "sends to klass.sync!" do
        Audio.should_receive(:sync!)
        Audio::SyncAudioJob.perform(Audio)
      end
    end
  end


  #----------------
  #----------------
  
  describe Audio::EncoAudio do
    describe "::filename" do
      it "is makes the filename based on enco number and date" do
        audio = build :enco_audio, enco_number: "1234", enco_date: freeze_time_at("October 21, 1988")
        Audio::EncoAudio.filename(audio).should eq "19881021_features1234.mp3"
      end
    end
    
    #----------------
    
    describe "::store_dir" do
      it "is the predetermined enco folder" do
        stub_const("Audio::STORE_DIRS", { enco: "features" })
        audio = build :enco_audio
        Audio::EncoAudio.store_dir(audio).should eq "features"
      end
    end
    
    #----------------
    
    describe "::sync!" do
      it "sets the audio's mp3 to the file if the file exists" do
        audio = create :enco_audio, enco_number: "1234", enco_date: freeze_time_at("October 02, 2012")
        audio.filename.should eq "20121002_features1234.mp3"
        Audio::EncoAudio.sync!
        audio.reload.mp3.file.filename.should eq audio.filename
      end
      
      it "doesn't doesn't do anything if the file doesn't exist" do
        audio = create :enco_audio, enco_number: "9999", enco_date: freeze_time_at("October 10, 2012")
        audio.filename.should eq "20121010_features9999.mp3"
        Audio::EncoAudio.sync!
        audio.reload.mp3.file.should be_blank
      end
    end
  end


  #----------------
  #----------------
  
  describe Audio::ProgramAudio do
    describe "callbacks" do
      describe "set_description_to_episode_headline" do
        let(:content) { create :show_episode, headline: "Cool Episode, Bro", show: create(:kpcc_program, audio_dir: "coolshow") }
      
        it "sets description to content's headline before create if description is blank" do
          audio = create :program_audio, description: nil, content: content
          audio.description.should eq "Cool Episode, Bro"
        
          # Make sure it doesn't happen on subsequent saves
          content.update_attribute(:headline, "Cooler Story")
          audio.save
          audio.reload.description.should eq "Cool Episode, Bro"
        end
      
        it "doesn't run if the description was given" do
          audio = create :program_audio, description: "Cool Audio, Bro", content: content
          audio.description.should eq "Cool Audio, Bro"
        end
      end
    end

    #----------------
    
    describe "::filename" do
      it "is the mp3's actual filename" do
        audio = build :audio, :program, :for_episode
        Audio::ProgramAudio.filename(audio).should eq "20121002_mbrand.mp3"
      end
    end
    
    #----------------
    
    describe "::store_dir" do
      it "is the show's audio_dir" do
        audio = build :audio, :program, :for_segment
        audio.content.show.update_attribute(:audio_dir, "coolshowbro")
        Audio::ProgramAudio.store_dir(audio).should eq "coolshowbro"
      end
    end
    
    #----------------
    
    describe "::sync!" do
      pending
    end
  end


  #----------------
  #----------------

  describe Audio::DirectAudio do
    describe "::filename" do
      it "is the supplied mp3's filename" do
        audio = build :audio, :direct, mp3_path: "/some/cool/audio_bro.mp3"
        Audio::DirectAudio.filename(audio).should eq "audio_bro.mp3"
      end
    end
    
    #----------------
    
    describe "::store_dir" do
      it "is the supplied mp3's base path" do
        audio = build :audio, :direct, mp3_path: "/some/cool/audio_bro.mp3"
        Audio::DirectAudio.store_dir(audio).should eq "/some/cool"
      end
    end
    
    #----------------
    
    describe "::sync!" do
      pending
    end
  end
  
  
  #----------------
  #----------------
  
  describe Audio::UploadedAudio do
    describe "::filename" do
      it "is the mp3's actual filename" do
        audio = build :audio, :uploaded
        Audio::ProgramAudio.filename(audio).should eq "point1sec.mp3"
      end
    end
    
    #----------------
    
    describe "::store_dir" do
      it "is the root upload dir with date paths" do
        stub_const("Audio::STORE_DIRS", { upload: "upload"} )
        time  = freeze_time_at("October 21, 1988")
        audio = build :audio, :uploaded
        Audio::UploadedAudio.store_dir(audio).should eq "upload/1988/10/21"
      end
    end
  end
end
