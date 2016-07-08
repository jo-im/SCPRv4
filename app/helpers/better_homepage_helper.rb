module BetterHomepageHelper
  # This just allow us to look up cached partial material
  # assuming the key and the partial file path are the 
  # same, and it also allows us to force a rendering in
  # instances where we want a preview, like in Outpost.
  def precached key, options={}
    unless options[:preview]
      raw Cache.read(key)
    else
      options.reverse_merge!(local: :content)
      render(partial: key, object: options[:preview], as: options[:local])
    end
  end

end