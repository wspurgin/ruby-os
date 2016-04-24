require 'spec_helper'

describe RubyOS::PCB do
  describe "#new" do
    it "should require at least 1 arguements" do
      intialize_method = described_class.instance_method(:initialize)
      expect(intialize_method.arity).to eq(-2) # i.e. has 1 rquired args
    end

    it "should set the first argument as the PCBs pid" do
      pid = 123
      pcb = described_class.new(pid)
      expect(pcb.pid).to eq pid
    end

    it "should set the default state as 'ready'" do
      pid = 123
      pcb = described_class.new(pid)
      expect(pcb.state).to eq("ready")
    end

    it "should leave the default priority as nil" do
      pid = 123
      pcb = described_class.new(pid)
      expect(pcb.priority).to be_nil
    end

    it "should leave the default command as blank" do
      pid = 123
      pcb = described_class.new(pid)
      expect(pcb.command).to be_empty
    end

    it "should take a hash as the thrid argument to set accounting information" do
      pid = 123
      pcb = described_class.new(pid,
                                priority: 4,
                                command: "/bin/ls")
      expect(pcb.priority).to eq 4
      expect(pcb.command).to eq "/bin/ls"

      # This is key, it should not overwrite any of the defaults if left
      # unspecified
      expect(pcb.state).to eq "ready"
    end
  end

  describe "Comparisons" do
    it "should compare the given object to the PCB's pid" do
      pid = 123
      pcb = described_class.new(pid)

      expect(pcb == 123).to be_truthy
      expect(pcb == 412).to be_falsey
      expect(pcb != 458).to be_truthy

      other_pcb = described_class.new(918237)
      expect(pcb == other_pcb).to be_falsey
      expect(pcb != other_pcb).to be_truthy
      expect(pcb == pcb).to be_truthy
      other_pcb = described_class.new(123)
      expect(pcb == other_pcb)
    end
  end

  describe "#method_missing" do
    it "should respond allow for data set through the accounting_information to\
    be called like an attribute" do
      special_data = "LLAP"
      uda_state = "I/O blocked"
      pcb = described_class.new(234,
                                my_special_data: special_data, state: uda_state)
      expect(pcb.my_special_data).to eq special_data
      expect(pcb.state).to eq uda_state
    end

    it "should allow setting of attributes in accounting as though they were\
    instance variables" do
      special_data = "LLAP"
      uda_state = "I/O blocked"
      pcb = described_class.new(234,
                                my_special_data: special_data, state: uda_state)
      expect(pcb).to respond_to :my_special_data
      expect(pcb).to respond_to :my_special_data=
      expect(pcb).to respond_to :state
      expect(pcb).to respond_to :state=
      pcb.state = "I/O read"
      expect(pcb.state).to eq "I/O read"
    end
  end
end
