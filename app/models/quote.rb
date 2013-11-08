class Quote < ActiveRecord::Base
  belongs_to :category
  belongs_to :article, polymorphic: true
  attr_accessible :quote, :source_context, :source_name
end
