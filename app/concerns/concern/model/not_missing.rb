module Concern::Model::NotMissing
	extend ActiveSupport::Concern

	def if_missing block, elseblock=Proc.new{}
		elseblock.call
	end

	def if_not_missing block, elseblock=Proc.new{}
		block.call
	end

	def missing?
		false
	end

	def not_missing?
		true
	end

end