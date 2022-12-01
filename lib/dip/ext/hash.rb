# frozen_string_literal: true

# active_support helpers
module ActiveSupportHashHelpers
  refine Hash do
    def deep_symbolize_keys!
      deep_transform_keys! { |key| key.respond_to?(:to_sym) ? key.to_sym : key }
    end

    def deep_transform_keys!(&block)
      keys.each do |key|
        value = delete(key)
        self[yield(key)] = value.is_a?(Hash) ? value.deep_transform_keys!(&block) : value
      end

      self
    end
    
    def transform_keys
      return enum_for(:transform_keys) { size } unless block_given?
      result = {}
      each_key do |key|
        result[yield(key)] = self[key]
      end
      result
    end
    
    def transform_keys!
      return enum_for(:transform_keys!) { size } unless block_given?
      keys.each do |key|
        self[yield(key)] = delete(key)
      end
      self
    end

    def deep_merge(other_hash, &block)
      dup.deep_merge!(other_hash, &block)
    end

    def deep_merge!(other_hash, &block)
      merge!(other_hash) do |key, this_val, other_val|
        if this_val.is_a?(Hash) && other_val.is_a?(Hash)
          this_val.deep_merge(other_val, &block)
        elsif block
          block.call(key, this_val, other_val)
        else
          other_val
        end
      end
    end
  end
end
