require 'ruby-os/scheduler'

class RubyOS::PriorityScheduler < RubyOS::Scheduler
  # This scheduler expects that PCBs in the queue respond to :priority. Moreover
  # :priority should be set to a non-nil sortable value. Otherwise, a sort will
  # fail.

  attr_reader :options

  def initialize(queue_manager, options = {})
    super(queue_manager)
    @options = default_options.merge(options)
  end

  def next_proc(queue_identifier, current_proc=nil)
    super

    priority_sort(queue_manager[queue_identifier])
    return queue_manager[queue_identifier].pop if current_proc.nil?

    # Current proc is not nil, so we have to compare it's priority
    # First, if the next proc is nil (i.e. there are no more procs in queue),
    # return the current proc
    return current_proc if queue_manager[queue_identifier].first.nil?

    # Both the next proc and current proc or not nil, compare priorities
    next_proc_priority = queue_manager[queue_identifier]
      .first
      .priority
    if next_proc_priority < current_proc.priority
      queue_manager[queue_identifier].pop
    else
      current_proc
    end

  rescue ArgumentError => e
    # TODO Log error and message about nil priority
    puts "Encountered Error: #{e}\n Do any of the processes have 'nil' priority?"
    nil
  end

  def reverse_priority_sort_order
    reverse_order = priority_sort_order == :asc ? :desc : :asc
    options[:priority_sort_order] = reverse_order
  end

  def priority_sort_order
    options[:priority_sort_order]
  end

  def priority_sort(queue)
    case priority_sort_order
    when :asc
      queue.sort_by!(&:priority)
    when :desc
      queue.sort_by(&:priority).reverse!
    end
  end

  private

  def default_options
    {
      priority_sort_order: :asc
    }
  end
end
