class EditionsController < ApplicationController
  layout 'new/ronin'
  respond_to :html

  def index
    @edition = Edition.published.includes(:slots).first
  end

  def short_list
    @scoped_editions = Edition.published.includes(:slots)
    @edition = @scoped_editions.find(params[:id])
    @other_editions = @scoped_editions.where.not(id: @edition).first(4)
  end

end
