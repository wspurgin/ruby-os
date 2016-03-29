class RubyOS::QueueManager

  def initialize(mapped_queues = {})
    raise NotAHashError.new if !mapped_queues.is_a?(Hash)
    if !mapped_queues.empty?
      mapped_queues.values.each do |q|
        raise NotAQueueError.new "Values of input hash" if !q.is_a?(RubyOS::Queue)
      end
    end
  end

  def add_queue(queue_state, queue = RubyOS::Queue.new)
    mapped_queues[queue_state] = queue
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
