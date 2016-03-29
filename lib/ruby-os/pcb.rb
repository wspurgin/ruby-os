class RubyOS::PCB

  attr_reader :pid, :pc, :accounting_information

  def initialize(pid, exec_address, pcb_info = {})
    @pid = pid
    @pc = exec_address
    @accounting_information = default_accounting_information.merge(pcb_info)
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
    if obj.is_a?(RubyOS::PCB)
      pid <=> obj.pid
    else
      pid <=> obj
    end
  end

  def to_s
    "<PCB pid=#{pid}>"
  end

  def inspect
    self.to_s
  end

  # Handle dynamic accounting information added (e.g. from simulation) or
  # otherwise implicit data withing the accounting informtion
  def method_missing(m, *args, &block)
    if accounting_information.has_key?(m)
      accounting_information[m]
    else
      super
    end
  end

  # If you ever override method missing, you should override respond to missing
  # too
  def respond_to_missing?(m, include_private = false)
    accounting_information.has_key? m || super
  end

  private

  def default_accounting_information
    {
      priority: nil,
      state: "ready",
      command: "",
      open_files_list: [],
      registers: {},
    }
  end
end
