module AudioCleanup
  def purge_uploaded_audio
    FileUtils.rm_rf Rails.configuration.x.scpr.media_root.join("audio/upload")
    FileUtils.rm_rf Rails.root.join("public", "uploads", "tmp")
  end
end
