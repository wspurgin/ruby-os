require 'ruby-os/memory/errors'

module RubyOS::Memory

  class Manager
    attr_reader :block_size, :total_memory, :highest_address,
      :default_proc_memory_limit

    def initialize(total_memory, block_size, default_proc_memory_limit)
      @block_size = block_size
      @total_memory = total_memory
      @highest_address = total_memory - 1
      @default_proc_memory_limit = default_proc_memory_limit
      @available_frame_list = {}
      @reserved_frame_list = {}
    end

    def assign_process_base_address(process)
      raise ArgumentError.new "#{self.class.name}: Expected RubyOS::PCB"
    end

    def free_memory(base_address, space = block_size)
      # TODO ensure frame address/space do not overlap existing "holes" in
      # available_frame_list, and that we aren't assigning past available
      # space.
      if base_address < 0 ||
          base_address > highest_address ||
          base_address + space - 1 > highest_address
        raise OutOfBoundsAssignment
      end
      available_frame_list[base_address] = space
    end

    def reserve_memory(base_address, space = memory_limit)
      # TODO ensure frame address/space do not overlap existing reserved memory
      # in reserved_frame_list, and that we aren't assigning past available
      # space.
      if base_address < 0 ||
          base_address > highest_address ||
          base_address + space - 1 > highest_address
        raise OutOfBoundsAssignment
      end
      reserved_frame_list[base_address] = space
    end

    def memory_limit
      default_proc_memory_limit
    end

    private

    def available_frame_list
      @available_frame_list
    end

    def reserved_frame_list
      @reserved_frame_list
    end
  end

end
