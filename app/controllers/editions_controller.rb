class EditionsController < ApplicationController
  layout 'new/ronin'
  respond_to :html

  def latest
    @scoped_editions = Edition.published.includes(:slots)
    @edition = @scoped_editions.first
    @other_editions = @scoped_editions.where.not(id: @edition).first(4)
    render template: "editions/short_list"
  end

  def short_list
    @scoped_editions = Edition.published.includes(:slots)
    @edition = @scoped_editions.find(params[:id])
    @other_editions = @scoped_editions.where.not(id: @edition).first(4)
  end

end
