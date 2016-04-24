module RubyOS::Memory

  class Manager
    attr_reader :frame_list, :block_size, :total_frames,
      :default_proc_memory_limit

    def initialize(block_size, total_frames, default_proc_memory_limit)
      @frame_list = {}
    end

    def assign_process_base_address(process)
      raise ArgumentError.new "#{self.class.name}: Expected RubyOS::PCB"
    end

    def memory_limit
      default_proc_memory_limit
    end
  end

end
