class RubyOS::PCB

  attr_reader :pid, :state, :priority, :pc, :registers, :open_files_list,
    :command

  def initialize(pid, exec_address, priority = nil, state = "ready", command = "")
    @pid = pid
    @pc = exec_address
    @priority = priority
    @state = state
    @command=command
    @registers = {}
    @open_files_list = []

    # TODO impelment accounting information once OS is implemented
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

  # TODO more finite control over PCB contents (adding open files, saving pc,
  # etc.
end
