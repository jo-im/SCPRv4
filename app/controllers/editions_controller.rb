class EditionsController < ApplicationController
  layout 'new/ronin'
  respond_to :html

  def latest
    @latest_editions = Edition.published.includes(:slots).first(5)
    @edition = @latest_editions.first
    @other_editions = @latest_editions - [@edition]
    render template: "editions/short_list"
  end

  def short_list
    @edition = Edition.published.includes(:slots).find(params[:id])
    @other_editions = @edition.sister_editions
  end

end
