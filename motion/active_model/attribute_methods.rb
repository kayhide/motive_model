require __ORIGINAL__

module ActiveModel
  module AttributeMethods
    module ClassMethods
      # def undefine_attribute_methods
      #   generated_attribute_methods.module_eval do
      #     instance_methods.each { |m| undef_method(m) }
      #   end
      #   attribute_method_matchers_cache.clear
      # end
      def undefine_attribute_methods
        generated_attribute_methods.module_eval do
          instance_methods(false).each { |m| undef_method(m) }
        end

        attribute_method_matchers_cache.clear
      end

      # def generated_attribute_methods #:nodoc:
      #   @generated_attribute_methods ||= Module.new {
      #     extend Mutex_m
      #   }.tap { |mod| include mod }
      # end
      def generated_attribute_methods
        @generated_attribute_methods ||= Module.new.tap do |mod|
          mod.extend Mutex_m
          include mod
        end
      end

      # def define_proxy_call(include_private, mod, name, send, *extra) #:nodoc:
      #   defn = if name =~ NAME_COMPILABLE_REGEXP
      #     "def #{name}(*args)"
      #   else
      #     "define_method(:'#{name}') do |*args|"
      #   end
 
      #   extra = (extra.map!(&:inspect) << "*args").join(", ")
 
      #   target = if send =~ CALL_COMPILABLE_REGEXP
      #     "#{"self." unless include_private}#{send}(#{extra})"
      #   else
      #     "send(:'#{send}', #{extra})"
      #   end
 
      #   mod.module_eval <<-RUBY, __FILE__, __LINE__ + 1
      #     #{defn}
      #       #{target}
      #     end
      #   RUBY
      # end
      def define_proxy_call(include_private, mod, name, send, *extra) #:nodoc:
        mod.module_eval do
          define_method(name) do |*args|
            send(send, *[*extra, *args])
          end
        end
      end
    end
  end
end
