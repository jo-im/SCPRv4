module FlatpageHandler
  FLATPAGE_TEMPLATE_MAP = {
    "full"    => "application",
    "kpcc_in_person"   => "kpcc_in_person",
    "none"    => false
  }

  def handle_flatpage
    # Is this a redirect? Send them on their way.
    if @flatpage.is_redirect?
      redirect_to @flatpage.redirect_to and return true
    end

    render layout: flatpage_layout_template, template: 'flatpages/show'
  end


  private

  def flatpage_layout_template
    template = FLATPAGE_TEMPLATE_MAP[@flatpage.template]
    template.nil? ? "application" : template
  end
end
