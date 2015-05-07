class ActiveRecord::Base
	def if_missing block, elseblock=Proc.new({})
		elseblock.call
	end
	def if_not_missing block, elseblock=Proc.new({})
		block.call
	end
end