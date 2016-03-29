class RubyOS::QueueManager

  attr_reader :mapped_queues

  def initialize(mapped_queues = {})
    raise NotAHashError.new if !mapped_queues.is_a?(Hash)
    if !mapped_queues.empty?
      mapped_queues.values.each do |q|
        raise NotAQueueError.new "Values of input hash" if !q.is_a?(RubyOS::Queue)
      end
    end
    @mapped_queues = mapped_queues
  end

  def add_queue(identifier, queue = RubyOS::Queue.new)
    raise NotAQueueError.new if !queue.is_a?(RubyOS::Queue)
    mapped_queues[identifier] = queue
  end

  def [](key)
    mapped_queues[key]
  end

  private

  class NotAHashError < ArgumentError
    def initialize
      super "First argument must be a Hash"
    end
  end

  class NotAQueueError < ArgumentError
    def initialize(where = "Argument")
      super where + " expected to be RubyOS::Queue"
    end
  end
end
