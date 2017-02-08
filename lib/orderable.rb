module Orderable
  # Just a nifty little method for cells
  # that enables flex ordering
  def order
    if @options[:order]
      "style=\"order: #{@options[:order]};\""
    end
  end
end