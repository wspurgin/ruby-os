require 'ruby-os/scheduler'

class RubyOS::SrptScheduler < RubyOS::Scheduler
  # This scheduler expects that PCBs in the queue respond to
  # :remaining_processing_time as part of their accounting information

  def next_proc(queue_identifier, current_proc=nil)
    super

    queue_manager[queue_identifier].sort_by!(&:remaining_processing_time)
    return queue_manager[queue_identifier].pop if current_proc.nil?

    # Current proc is not nil, so we have to compare it's rpt.
    # First, if the next proc is nil (i.e. there are no more procs in queue),
    # return the current proc
    return current_proc if queue_manager[queue_identifier].first.nil?

    # Both the next proc and current proc or not nil, compare rpt.
    next_proc_remaining_processing_time = queue_manager[queue_identifier]
      .first
      .remaining_processing_time
    if next_proc_remaining_processing_time < current_proc.remaining_processing_time
      queue_manager[queue_identifier].pop
    else
      current_proc
    end
  end
end
