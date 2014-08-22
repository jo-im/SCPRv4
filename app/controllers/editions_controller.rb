class EditionsController < ApplicationController
  layout 'new/ronin'
  respond_to :html

  def short_list
    @edition = Edition.published.includes(:slots).find(params[:id])
    @other_editions = Edition.published.includes(:slots).where.not(id: @edition).first(4)
  end

end
