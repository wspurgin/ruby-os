require 'ruby-os/scheduler'

class RubyOS::RobinScheduler < RubyOS::Scheduler
  # This scheduler maintains it own "clock" so to say, to manage the share each
  # process has in the CPU. It does not sorting. It's basic FIFO but with a
  # round robin sharing based on the `q` parameter.

  attr_reader :q, :timer

  def initialize(queue_manager, q)
    super(queue_manager)
    raise ArgumentError.new "Expected 2nd param to be a Numeric" if !q.is_a?(Numeric)
    @q = q.to_int
    @timer = @q
  end

  def next_proc(queue_identifier, current_proc=nil)
    super

    return queue_manager[queue_identifier].pop if current_proc.nil? && reset!
    return current_proc if queue_manager[queue_identifier].first.nil? && reset!

    # The current proc still has time left.
    if (@timer -= 1) == 0
      # Time share is up, reset timer and return next process
      reset!
      queue_manager[queue_identifier].pop
    else
      current_proc
    end
  end

  def reset!
    @timer = q
  end

end
