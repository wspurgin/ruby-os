require 'ruby-os/array'

class RubyOS::Queue
  include Enumerable

  def initialize(arg=nil)
    @internal = Array.wrap(arg)
  end

  def push(process, pos=nil)
    if pos.nil?
      internal << process
    else
      internal.insert(pos, process)
    end
  end

  def pop(pid=nil)
    if pid.nil?
      internal.shift
    else
      internal.delete(pid)
    end
  end

  def each(&block)
    @internal.each(&block)
  end

  def last
    @internal[-1]
  end

  def <=>(obj)
    @internal <=> obj
  end

  def ==(obj)
    @internal == obj
  end

  def !=(obj)
    @internal != obj
  end

  def to_s
    "<Queue: #{@internal.inspect}>"
  end

  def inspect
    self.to_s
  end

  private

  def internal
    @internal
  end
end
