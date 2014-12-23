task :asset_sync => [:environment] do
  AssetSync.new().work()
end