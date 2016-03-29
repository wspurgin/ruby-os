class RubyOS::Scheduler
  attr_reader :queue_manager

  def initialize(queue_manager)
    raise NotAQueueManagerError.new if !queue_manager.is_a?(RubyOS::QueueManager)
    @queue_manager = queue_manager
  end

  def next_proc(queue_identifier, current_proc=nil)
    raise NoQueueFoundError.new queue_identifier if !queue_manager.has_queue? queue_identifier
  end

  private

  class NotAQueueManagerError < ArgumentError
    def initialize
      super "Expected RubyOS::QueueManager"
    end
  end

  class NoQueueFoundError < ArgumentError
    def initialize(identifier)
      super "No RubyOS::Queue found identified by '#{identifier}'"
    end
  end
end
