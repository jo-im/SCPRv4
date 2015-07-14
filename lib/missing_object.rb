module MissingObject
  class << self
    def nil? 
      true
    end
    def none?
      true
    end
    def !
      true
    end
    def empty?
      true
    end
    def method_missing *args, &block
      if args[0][-1] == "?"
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