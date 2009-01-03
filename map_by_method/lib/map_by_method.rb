module MapByMethod
  VERSION = "0.0.1"

  def self.included(base)
    super

    base.module_eval <<-EOS
      def method_missing(method, *arg, &block)
        super
      rescue NoMethodError
        error = $!
        begin
          re = /(map|collect|select|each|reject)_([\\w\\_]+\\??)/
          if (match = method.to_s.match(re))
            iterator, callmethod = match[1..2]
            return self.send(iterator){|item| item.send callmethod}
          end
          return self.map{|item| item.send method.to_s.singularize.to_sym}
        rescue NoMethodError
          nil
        end
      end
    EOS
  end
end

unless String.instance_methods.include? "singularize"
  class String
    def singularize
      self.gsub(/e?s\Z/, '')
    end
  end
end

Array.send :include, MapByMethod
