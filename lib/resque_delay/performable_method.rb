module ResqueDelay
  class PerformableMethod < Struct.new(:object, :method, :args)
    CLASS_STRING_FORMAT = /^CLASS\:([A-Z][\w\:]+)$/
    AR_STRING_FORMAT    = /^AR\:([A-Z][\w\:]+)\:(\d+)$/

    def self.create(object, method, args)
      raise NoMethodError, "undefined method `#{method}' for #{object.inspect}" unless object.respond_to?(method)
      self.new(object, method, args)
    end

    def initialize(object, method, args)
      self.object = dump(object)
      self.args   = args.map { |a| dump(a) }
      self.method = method.to_sym
    end

    def display_name
      case self.object
      when CLASS_STRING_FORMAT then "#{$1}.#{method}"
      when AR_STRING_FORMAT    then "#{$1}##{method}"
      else "Unknown##{method}"
      end
    end

    def perform
      load(object).send(method, *args.map{|a| load(a)})
    end

    private

    def load(arg)
      case arg
      when CLASS_STRING_FORMAT then $1.constantize
      when AR_STRING_FORMAT    then $1.constantize.find($2)
      else arg
      end
    end

    def dump(arg)
      case arg
      when Class              then class_to_string(arg)
      else arg
      end
    end

    def ar_to_string(obj)
      "AR:#{obj.class}:#{obj.id}"
    end

    def class_to_string(obj)
      "CLASS:#{obj.name}"
    end
  end
end