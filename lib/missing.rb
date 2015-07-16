module Missing
  ## This is a placeholder object to use instead of nil
  ## in cases where relying on nil would require
  ## logic branching, extensive use of #try, etc.
  ## It will return itself for most method calls as well
  ## as attempt to return appropriate booleans for 
  ## question-mark and operator methods.
  class << self
    def none?
      true
    end
    def !
      true
    end
    def !=(arg)
      if arg.name == self.name
        false
      else
        true
      end
    end
    def empty?
      true
    end
    def method_missing *args, &block
      if args[0][-1] == "?"
        false
      elsif [:<, :>, :<=, :>=, :==, :===].include?(args[0])
        false 
      else
        self
      end
    end
    def to_s
      ""
    end
  end
end