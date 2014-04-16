module CategoryHandler
  extend ActiveSupport::Concern

  PER_PAGE = 16

  # Simple category handler.
  def handle_category
    @content = @category.content(
      :page       => params[:page].to_i,
      :per_page   => PER_PAGE
    )

    respond_with @content, template: 'category/show'
  end
end
