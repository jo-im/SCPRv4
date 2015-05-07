module Concern::Model::Missing
  extend ActiveSupport::Concern

  def if_missing block, elseblock=Proc.new{}
    block.call
  end

  def if_not_missing block, elseblock=Proc.new{}
    elseblock.call
  end

  def missing?
    true
  end

  def not_missing?
    false
  end

end