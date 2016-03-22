require 'spec_helper'

describe RubyOS::PCB do
  describe "#new" do
    it "should require at least 2 arguements" do
      intialize_method = described_class.instance_method(:initialize)
      expect(intialize_method.arity).to eq(-3) # i.e. has two rquired args
    end

    it "should set the first argument as the PCBs pid and second as pc" do
      pid = 123
      cmd_address = 0x0283
      pcb = described_class.new(pid, cmd_address)
      expect(pcb.pid).to eq pid
      expect(pcb.pc).to eq cmd_address
    end

    it "should set the default state as 'ready'" do
      pid = 123
      cmd_address = 0x0283
      pcb = described_class.new(pid, cmd_address)
      expect(pcb.state).to eq("ready")
    end

    it "should leave the default priority as nil" do
      pid = 123
      cmd_address = 0x0283
      pcb = described_class.new(pid, cmd_address)
      expect(pcb.priority).to be_nil
    end

    it "should leave the default command as blank" do
      pid = 123
      cmd_address = 0x0283
      pcb = described_class.new(pid, cmd_address)
      expect(pcb.command).to be_empty
    end
  end

  describe "Comparisons" do
    it "should compare the given object to the PCB's pid" do
      pid = 123
      cmd_address = 0x0283
      pcb = described_class.new(pid, cmd_address)

      expect(pcb == 123).to be_truthy
      expect(pcb == 412).to be_falsey
      expect(pcb != 458).to be_truthy

      other_pcb = described_class.new(918237, 0x9999)
      expect(pcb == other_pcb).to be_falsey
      expect(pcb != other_pcb).to be_truthy
      expect(pcb == pcb).to be_truthy
      other_pcb = described_class.new(123, 0x9999)
      expect(pcb == other_pcb)
    end
  end
end
