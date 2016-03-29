class RubyOS::Scheduler
  attr_reader :queue_manager

  def initialize(queue_manager)
    raise NotAQueueManagerError.new if !queue_manager.is_a?(RubyOS::QueueManager)
    @queue_manager = queue_manager
  end

  def next_proc(queue_identifier)
    raise NotImpleplementedError.new
  end

  private

  class NotAQueueManagerError < ArgumentError
    def initialize
      super "Expected RubyOS::QueueManager"
    end
  end
end
