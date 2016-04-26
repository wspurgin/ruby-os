module RubyOS::Memory
  class FirstFitManager < Manager
    def assign_process_base_address(process)
      super
      # Find the first available address
      starting_address, _ = memory_map.find(proc { [nil, nil] }) { |addr, flag| flag == FREE }
      raise OutOfMemoryError.new if starting_address.nil?

      # Find the first reserved location
      first_reserved, _ = memory_map
        .find(proc { [nil, nil] }) { |addr, flag| addr > starting_address and flag == RESERVED }

      # if the first_reserved address is nil, then there is only available space
      # after the starting address
      if first_reserved.nil? || first_reserved - starting_address >= process.memory_required
        process.base_address = starting_address
        process.memory_limit = process.memory_required
      else
        loop do
          # The space between starting_address and first_reserved is not enough
          # for the requesting process. So continue on to the next 'hole'
          starting_address, _ = memory_map
            .find(proc { [nil, nil] }) { |addr, flag| addr > first_reserved and flag == FREE }

          # if the address is nil, then there were no further 'holes'
          raise NoContiguousMemoryError.new if starting_address.nil?

          first_reserved, _ = memory_map
            .find(proc { [nil, nil] }) { |addr, flag| addr > starting_address and flag == RESERVED }
          if first_reserved.nil? || first_reserved - starting_address >= process.memory_required
            process.base_address = starting_address
            process.memory_limit = process.memory_required
            break
          end
        end
      end

      reserve_memory(process.base_address, process.memory_limit)
      # TODO rescue OutOfBoundsAssignment error here or let the OS handled it?
    end
  end
end
