# Monkey patch of standard Ruby Array class

class Array
  # File activesupport/lib/active_support/core_ext/array/wrap.rb, line 36
  # source http://devdocs.io/rails/array#method-c-wrap
  def self.wrap(object)
    if object.nil?
      []
    elsif object.respond_to?(:to_ary)
      object.to_ary || [object]
    else
      [object]
    end
  end
end
