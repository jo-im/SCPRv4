class ContentEmailController < ApplicationController
  layout "minimal"
  before_filter :get_content

  def new
    @message = ContentEmail.new
  end


  def create
    @message = ContentEmail.new(form_params)
    @message.content_key = @content.obj_key

    if @message.save
      render :success
    else
      render :new
    end
  end

  #---------------------

  private

  def get_content
    @content = ContentBase.safe_obj_by_key!(params[:obj_key])
  end

  def form_params
    params.require(:content_email).permit(
      :to_email, :from_name, :from_email, :body, :lname)
  end
end
