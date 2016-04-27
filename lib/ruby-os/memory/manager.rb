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
      @memory_map = Hash.new { |hash, addr| hash[Integer(addr)] }
      (0..@highest_address).each do |address|
        @memory_map[address] = FREE
      end
    end

    def assign_process_base_address(process)
      raise ArgumentError.new("#{self.class.name}: Expected RubyOS::PCB") if !process.is_a?(RubyOS::PCB)
      raise Error.new "Process already assigned memory address" if !process.base_address.nil?
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

    def possible_external_fragmentation?
      external_fragmentation_total > 0
    end

    def internal_fragmentation?
      internal_fragmentation_total > 0
    end

    def external_fragmentation_total
      # Is the memory contiguously reserved? or are there holes?
      hole = find_hole

      return 0 if hole.nil? # all memory is filled

      # Hole goes to end of memory map
      return 0 if hole[:end_address] > highest_address

      # If we find another hole in memory, then at least the first hole is
      # an external fragmentation
      next_hole = find_hole(hole[:end_address])
      return 0 if next_hole.nil?

      total = hole[:mem_available]
      loop do
        total += next_hole[:mem_available]
        break unless next_hole = find_hole(next_hole[:end_address])
      end

      total
    end

    def internal_fragmentation_total
      0 # Contiguous memory has no internal fragmentation
    end

    def total_available_memory
      memory_map.count { |_, flag| flag == FREE }
    end

    def total_reserved_memory
      memory_map.count { |_, flag| flag == RESERVED }
    end

    def find_hole(starting_at=nil)
      hole = {}
      starting_at = -1 if starting_at.nil?

      # Find leading edge
      lead, _  = memory_map.find(proc { [nil, nil] }) { |addr, flag| addr > starting_at && flag == FREE }

      # If the address is nil, then there is no memory available.
      return nil if lead.nil?

      # Next find the trailing edge
      tail, _ = memory_map.find(proc { [nil, nil] }) { |addr, flag| addr > lead && flag == RESERVED }

      # If it's nil, the highest_address is the last free spot, (and thus
      # highest_address + 1 is the first 'reserved' spot)
      tail = highest_address + 1 if tail.nil?

      hole[:base_address] = lead
      hole[:end_address] = tail
      hole[:mem_available] = tail - lead

      hole
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
