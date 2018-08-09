module CNO
  module Common
    # Inspired on https://github.com/masover/blankslate
    class BlankSlate

      BASIC_METHODS = [
        :!, :!=, :==,
        :__id__, :__send__,
        :class, :singleton_class,
        :equal?,
        :instance_eval, :instance_exec,
        :method_missing, :object_id,
        :singleton_method_added, :singleton_method_removed,
        :singleton_method_undefined
      ]

      def initialize
        @do_not_hide = BASIC_METHODS + self.class.instance_methods(false)
        @hidden_methods = {}
        self.singleton_class.instance_methods.each { |m| hide_method(m) }
      end

      def method_missing(method_name, *args, &block)
        try_hidden_method(method_name, *args, &block) || super
      end

      def respond_to_missing?(method_name, include_private = false)
        true
      end

      private
        def hide_method(name)
          name = name.to_sym
          klass = self.singleton_class
          methods = klass.instance_methods.map(&:to_sym)
          if methods.include?(name) && !@do_not_hide.include?(name)
            @hidden_methods[name] = klass.instance_method(name)
            klass.send(:undef_method, name)
          end
        end

        def try_hidden_method(method_name, *args, &block)
          if (method = @hidden_methods[method_name.to_sym])
            ret = if args.any? && block_given?
                    method.bind(self).call(*args, &block)
                  elsif args.any?
                    method.bind(self).call(*args)
                  elsif block_given?
                    method.bind(self).call(&block)
                  else
                    method.bind(self).call
                  end
            hide_method(method_name)
          end
          ret
        end

    end
  end
end
