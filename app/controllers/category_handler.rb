module CategoryHandler
  extend ActiveSupport::Concern

  # Simple category handler.
  def handle_category
    @content = @category.content(
      :page       => params[:page].to_i,
      :per_page   => PER_PAGE
    )

    respond_with @content
  end
end
