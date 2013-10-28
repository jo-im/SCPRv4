module CategoryHandler
  PER_PAGE = 15

  def handle_category
    page      = params[:page].to_i
    per_page  = PER_PAGE

    @content = @category.content(
      :page       => page,
      :per_page   => per_page
    )

    respond_with @content, template: "category/show"
  end
end
