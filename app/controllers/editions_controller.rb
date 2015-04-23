class EditionsController < ApplicationController
  layout 'new/ronin'
  respond_to :html

  def latest
    # Temporary patch to prevent Short List from loading Chartbeat until 
    # https://github.com/SCPR/KPCC-iPhone/commit/d3ec7a12911d2ca0d0e6c52caa1167fd2aa40760
    # from the iPhone app is deployed to the App Store in v.3.2.0.
    @disable_chartbeat = true

    @latest_editions = Edition.published.includes(:slots).first(5)
    @edition = @latest_editions.first
    @other_editions = @latest_editions - [@edition]
    render template: "editions/short_list"
  end

  def short_list
    @edition = Edition.published.includes(:slots).find(params[:id])
    @other_editions = @edition.sister_editions
  end

  def email
    @edition = Edition.published.includes(:slots).first
    render template: "editions/email/template", :locals => { edition: @edition }, :layout => false
  end

end
