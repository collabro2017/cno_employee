module CoreExtensions

  refine Fixnum do
    def pad(padding, filling='0')
      self.to_s.rjust((padding || 0), filling)
    end
  end

  refine Hash do
    def to_struct(deep: false)
      unless self.empty?
        struct = Struct.new(*self.keys.map(&:to_sym))
        deep ? struct.new(*structurize(self.values)) : struct.new(*self.values)
      end
    end

    private
      def structurize(object)
        if object.is_a?(Hash)
          object.to_struct(deep: true)
        elsif object.is_a?(Enumerable)
          object.map { |item| structurize(item) }
        else
          object
        end
      end
  end

end

