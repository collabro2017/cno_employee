module CNO
  module Configuration
    # DSL definition for using in initializer code
    #
    #  Example:
    #    CNO::Configuration::Default.set do
    #      app_name 'My app'
    #      nodes 5
    #      time_out 30
    #    end
    class Default < BasicObject

      def self.load
        config_files =
          ::Dir[::Rails.root.join('config', 'default', '{*.config}')]

        config = self.new
        config_files.each do |file_name|
          config.instance_eval(::File.read(file_name))
        end
        config.to_h
      end

      def initialize
        @config = {}.with_indifferent_access
        @target = @config
      end

      def to_h
        @config
      end

      def method_missing(method, *args, &block)
        # When inheriting from BasicObject, Kernel methods are not available.
        # So, it's necessary to call them this way:
        if ::Kernel.block_given?
          parent = @target

          is_array = !singular?(method.to_s)
          is_array = args.first.fetch(:is_array, is_array)  unless args.empty?

          @target = is_array ? [] : {}
          self.instance_eval(&block)

          if parent.is_a?(::Hash)
            parent[method] = @target
          else
            parent << {method => @target}
          end

          @target = parent
        elsif args.size < 1
          ::Kernel.raise ArgumentError, "wrong number of arguments (0 for 1)"
        elsif args.size == 1
          @target[method] = args.first
        else
          @target[method] = args
        end
      end

      def respond_to_missing?(method_name, include_private = false)
        true
      end

      private

        def singular?(str)
          str.pluralize != str && str.singularize == str
        end

    end #sub class
    
  end
end
