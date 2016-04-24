require 'ruby-os/hash'

class RubyOS::PCB

  attr_reader :pid, :accounting_information

  def initialize(pid, pcb_info = {})
    @pid = pid
    @accounting_information = default_accounting_information
      .merge(pcb_info)
      .symbolize_keys
  end

  def update_state(state)
    @state = state
  end

  def save_registers(registers)
    if !registers.is_a(Hash)
      raise ArgumentError.new("PCB#save_registers expects a Hash")
    end
    @registers = registers
  end

  def ==(obj)
    (self <=> obj) == 0
  end

  def !=(obj)
    !(self == obj)
  end

  def <=>(obj)
    if obj.is_a?(self.class)
      pid <=> obj.pid
    else
      pid <=> obj
    end
  end

  def to_s
    "<PCB pid=#{pid} remaining=#{remaining_processing_time} priority=#{priority}>"
  end

  def inspect
    self.to_s
  end

  # Handle dynamic accounting information added (e.g. from simulation) or
  # otherwise implicit data withing the accounting informtion
  def method_missing(m, *args, &block)
    is_assignment = m =~ /=$/
    attribute = m.to_s.sub(/=$/, '').to_sym
    if accounting_information.has_key?(attribute)
      if is_assignment
        accounting_information[attribute] = args.first
      else
        accounting_information[attribute]
      end
    else
      super
    end
  end

  # If you ever override method missing, you should override respond to missing
  # too
  def respond_to_missing?(m, include_private = false)
    accounting_information.has_key? m.to_s.sub(/=$/, '').to_sym || super
  end

  private

  def default_accounting_information
    {
      priority: nil,
      state: "ready",
      command: "",
      open_files_list: [],
      registers: {},
      remaining_processing_time: 0,
      arrival_time: nil,
      base_address: nil,
      memory_limit: nil,
    }
  end
end
