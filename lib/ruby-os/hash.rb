# Monkey patch of standard Ruby Hash class

class Hash
  # File activesupport/lib/active_support/core_ext/hash/keys.rb, line 52
  def symbolize_keys
    transform_keys{ |key| key.to_sym rescue key }
  end

  # File activesupport/lib/active_support/core_ext/hash/keys.rb, line 57
  def symbolize_keys!
    transform_keys!{ |key| key.to_sym rescue key }
  end

  # File activesupport/lib/active_support/core_ext/hash/keys.rb, line 8
  def transform_keys
    return enum_for(:transform_keys) unless block_given?
    result = self.class.new
    each_key do |key|
      result[yield(key)] = self[key]
    end
    result
  end

  # File activesupport/lib/active_support/core_ext/hash/keys.rb, line 19
  def transform_keys!
    return enum_for(:transform_keys!) unless block_given?
    keys.each do |key|
      self[yield(key)] = delete(key)
    end
    self
  end
end
