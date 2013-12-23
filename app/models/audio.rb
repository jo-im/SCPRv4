require 'open-uri'

# Our audio process is confusing. There have always been three main
# ways to get audio attached to a story, and they all come from
# different directions:
#
# 1. ENCO audio. These are generally short features that get aired on
# the radio as part of a news break. The audio is recorded, given a
# unique number and date, placed into a special FTP server, and then sent
# automatically (via a Jeff Krinock script) to various outlets.
# One of those outlets is our media server.
# At some point, a news story/blog entry/whatever is created for this
# audio. The audio may or may not have already been uploaded to our
# media server, but the ENCO number and date will already be known.
# We give reporters the ability to input the number and date before
# the audio is available, and attach it to the story (based on the given
# number and date) as soon as it's been uploaded.
# The filenames for these audio files contain the ENCO number and date,
# so we can find it if we have that information.
#
# 2. Program audio. These are full-length episodes of each program that
# we record in-house: Airtalk, Off-Ramp, etc. These get uploaded a few
# hours after they air, and eventually placed on our media server.
# The filenames contain the name of the program and the air date, so we
# can find it based off of that information.
# Users can create an episode for a program before the audio exists, and
# once audio is uploaded which matches the episode's program and air date,
# we'll attach it automatically. We can also attach it to a Segment if the
# program only uses segments (Filmweek, for example).
#
# 3. Uploaded audio. This is audio that just gets uploaded and attached to
# a story manually by an Outpost user.
#
# We have also added the ability to give any arbitrary URL to an MP3,
# allowing us to attach audio from NPR or other sources.
#
# The one thing that all of these types of audio have in common: They will
# all have a predictable URL. ENCO and Program audio filenames are predictable
# given the correct information. Uploaded audio just uses the name of the
# audio file. If given a URL, we just use that verbatim.
#
# So, we store the URL to the audio file (whether it already exists or not)
# in the database.
# * For uploaded and direct-URL audio files, we assume right away that the
# audio is available.
#
# * For ENCO audio, we build the URL right away (since we know what it WILL
# be), and assume that it's not available yet, then check every few minutes
# (by pinging that URL) to see if it has become avalable.
#
# * For program audio, we scrape the filesystem to find new audio files
# and figure out which Outpost article to attach them to, based on the
# file's date and program slug. We treat this audio just as "direct" audio,
# by assigning its url directly.
class Audio < ActiveRecord::Base
  self.table_name = "media_audio"
  logs_as_task
  has_status


  # Public URL root - http://media.scpr.org/audio
  AUDIO_URL_ROOT = File.join(
    Rails.application.config.scpr.media_url, "audio")

  TIMEOUT = 60


  # The NONE Status is just so we can use Audio::STATUS_TEXT for
  # render the Audio columns in the CMS.
  status :none do
    s.id = nil
    s.text = "None"
    s.unpublished!
  end

  status :waiting do
    s.id = 1
    s.text = "Awaiting Audio"
    s.pending!
  end

  status :live do
    s.id = 2
    s.text = "Live"
    s.published!
  end


  belongs_to :content,
    :polymorphic    => true,
    :touch          => true


  validate :audio_source_is_provided
  validate :enco_info_is_present_together
  validates :url, url: { allow_blank: true }


  before_save :determine_source, if: :audio_source_changed?
  after_save :async_compute_file_info, if: -> {
    self.published? && (self.duration.blank? || self.size.blank?)
  }


  scope :available,      -> { where(status: Audio.status_id(:live)) }
  scope :awaiting_audio, -> { where(status: Audio.status_id(:waiting)) }


  # Different ways to get audio into the system.
  attr_accessor \
    :mp3,
    :enco_number,
    :enco_date


  class << self
    # Compile the full URL to an audio file.
    #
    # Arguments
    # * parts (Strings) - A variable number of strings to build the URL.
    #
    # Example
    #
    #   Audio.url("taketwo", "someaudio.mp3")
    #     #=> http://media.scpr.org/audio/taketwo/someaudio.mp3
    #
    # Returns String
    def url(*parts)
      File.join(AUDIO_URL_ROOT, *parts)
    end
  end


  # Temporary proxy
  def live?
    published?
  end


  # Publish the audio.
  #
  # Returns Audio.
  def publish
    self.update_attributes(status: Audio.status_id(:live))
  end


  # Queue the computation jobs for this audio.
  #
  # Returns nothing.
  def async_compute_file_info
    Resque.enqueue(Job::ComputeAudioFileInfo, self.id)
  end


  # Compute the duration and size of the audio file.
  #
  # Returns nothing.
  def compute_file_info
    compute_duration
    compute_size
    self
  end


  # Compute duration via Mp3Info.
  # Sets duration to 0 if something goes wrong
  # so it's not considered "blank".
  #
  # Returns nothing.
  def compute_duration
    return false if !file

    Mp3Info.open(file) do |file|
      self.duration = file.length
    end

    self.duration ||= 0
  end


  # Compute the size via Carrierwave
  # Sets the value to 0 if something goes wrong
  # so that size won't be "blank".
  #
  # Returns nothing.
  def compute_size
    return false if self.url.blank?
    self.size = file.size || 0
  end


  attr_writer :file

  # Get the actual file via open-uri.
  # We want to return right away if URL is blank so that
  # if the URL is cleared out, the object won't hold on
  # to the file. This also prevents an Errno::ENOENT error.
  #
  # Returns Tempfile or nil.
  def file
    return if self.url.blank?

    @file ||= begin
      open(self.url, read_timeout: TIMEOUT)
    rescue OpenURI::HTTPError, Timeout::Error
      nil
    end
  end


  # When the URL is set, we should clear out the memoized file *only*
  # if the URL is different.
  def url=(url)
    @file = nil if url != self.url
    super
  end


  private

  # Check if the source of the audio has changed
  def audio_source_changed?
    self.enco_number_changed? ||
    self.enco_date_changed? ||
    self.url_changed? ||
    self.mp3_changed?
  end


  def determine_source
    if self.enco_number.present? && self.enco_date.present?
      date = self.enco_date.strftime("%Y%m%d")
      filename = "#{date}_features#{self.enco_number}.mp3"

      # We *could* check the filesystem right now for the
      # existence of this audio, but even if it exists,
      # we wouldn't want to compute the file info right now.
      # So we'll leave it up to our hero, the background worker.
      self.url = Audio.url("features", filename)

      # Enco is Awaiting by default.
      # Once the audio file exists on the server,
      # it will be picked up by the background job
      # and the status will be updated.
      self.status = Audio.status_id(:waiting)

    elsif self.mp3.present?
      # Since we don't want or need to persist the mp3 information,
      # we just handle audio uploading manually (via Carrierwave),
      # instead of using Carrierwave's "mount" feature.
      uploder = AudioUploader.new(self)
      uploader.store!(self.mp3)

      # Even though we have the file in memory, we don't want to
      # compute the file info righ now, because we're still in
      # an HTTP transaction... computing duration, especially,
      # can take a while for big files. So we'll just set the
      # URL and let the background workers handle the file info
      # as normal.
      self.url = uploader.url

      # We can assume that if they just uploaded the file,
      # it is available and live.
      self.status = Audio.status_id(:live)

    elsif self.url.present?
      # Checking for URL should come last so that we can override
      # the existing URL by uploading an mp3 or inputting ENCO info.
      # Let's trust the user to input a correct URL.
      self.status = Audio.status_id(:live)
    end
  end


  # Make sure enco_number and enco_date are both filled in,
  # if one of them is.
  def enco_info_is_present_together
    if self.enco_number.blank? ^ self.enco_date.blank?
      errors.add(:base,
        "Enco number and Enco date must both be present for ENCO audio")
      # Just so the form is aware that enco_number and enco_date are involved
      errors.add(:enco_number, "")
      errors.add(:enco_date, "")
    end
  end


  # Check if an audio source was given.
  def audio_source_is_provided
    if self.url.blank? &&
    self.mp3.blank? &&
    self.enco_number.blank? &&
    self.enco_date.blank?
      self.errors.add(:base,
        "Audio must have a source (upload, enco, or URL)")
    end
  end
end
