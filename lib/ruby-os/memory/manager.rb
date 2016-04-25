require 'ruby-os/memory/errors'

module RubyOS::Memory

  class Manager
    attr_reader :block_size, :total_memory, :highest_address,
      :default_proc_memory_limit

    RESERVED = 1
    FREE = 0

    def initialize(total_memory, block_size, default_proc_memory_limit)
      @block_size = block_size
      @total_memory = total_memory
      @highest_address = total_memory - 1
      @default_proc_memory_limit = default_proc_memory_limit
      @memory_map = {}
      (0..@highest_address).each do |address|
        @memory_map[address] = FREE
      end
    end

    def assign_process_base_address(process)
      raise ArgumentError.new("#{self.class.name}: Expected RubyOS::PCB") if !process.is_a?(RubyOS::PCB)
    end

    def free_memory(base_address, space = block_size)
      # TODO Should we raise an error if attempting to free memory that is
      # already free?
      address_range = (base_address..(base_address + space - 1))
      memory_assign_walk(address_range) { |reserved_flag| FREE }
    end

    def reserve_memory(base_address, space = memory_limit)
      address_range = (base_address..(base_address + space - 1))
      memory_assign_walk(address_range) do |reserved_flag|
        reserved_flag == RESERVED ? raise(AssignmentError.new) : RESERVED
      end
    end

    def memory_limit
      default_proc_memory_limit
    end

    def external_fragmentation?
      raise NotImplementedError.new
    end

    def internal_fragmentation?
      raise NotImplementedError.new
    end

    def external_fragmentation_total
      raise NotImplementedError.new
    end

    def internal_fragmentation_total
      raise NotImplementedError.new
    end

    # Make all memory locations reserved
    def reserve!
      memory_map.transform_values! { |_| RESERVED }
    end

    # Make all memory locations free
    def free!
      memory_map.transform_values! { |_| FREE }
    end

    def memory_assign_walk(addr_range, &block)
      if !addr_range.is_a?(Range)
        raise ArgumentError.new "1st argument must be a range"
      elsif !block_given?
        raise ArgumentError.new "Block required"
      elsif
        addr_range.first < 0 ||
          addr_range.first > highest_address ||
          addr_range.last > highest_address
        raise OutOfBoundsAssignment.new
      end
      addr_range.each do |addr|
        memory_map[addr] = yield(memory_map[addr])
      end
    end

    def memory_map
      @memory_map
    end

  end

end
