# Fix json_escape to properly escape
# https://github.com/rails/rails/pull/6094
# This monkey patch can be removed for Rails 4.1
class ActionView::Base
  def json_escape(s)
    result = s.to_s.gsub('/', '\/')
    s.html_safe? ? result.html_safe : result
  end

  alias j json_escape
end