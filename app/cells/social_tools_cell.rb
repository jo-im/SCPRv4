class SocialToolsCell < Cell::ViewModel
  include ERB::Util
  include Orderable

  cache :show, expires_in: 10.minutes do
    [model.try(:cache_key), "o-social-tools--#{@options[:display]}", @options[:class]]
  end

  property :id
  property :obj_key
  property :title
  property :short_title
  property :public_url
  property :public_path

  def show
    render
  end

  def obj_key
    if @options[:email] == false
      return
    end
    model.try(:obj_key)
  end

  def public_url
    model.try(:public_url) || request.original_url
  end

  def title
    model.try(:short_title) || model.try(:short_headline) || @options[:title]
  end

end
