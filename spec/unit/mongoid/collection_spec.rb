require "spec_helper"

describe Mongoid::Collection do

  let(:master) do
    stub.quacks_like(Mongoid::Collections::Master.allocate)
  end

  let(:slaves) do
    stub.quacks_like(Mongoid::Collections::Slaves.allocate)
  end

  let(:collection) do
    Mongoid::Collection.new("people")
  end

  before do
    collection.instance_variable_set(:@master, master)
    collection.instance_variable_set(:@slaves, slaves)
  end

  context "Mongo::Collection write operations" do

    Mongoid::Collections::Operations::WRITE.each do |name|

      it "defines #{name}" do
        collection.should respond_to(name)
      end
    end

  end

  context "Mongo::Collection read operations" do

    Mongoid::Collections::Operations::READ.each do |name|

      it "defines #{name}" do
        collection.should respond_to(name)
      end
    end
  end

  describe "#directed" do

    context "when the counter is less than the maximum" do

      before do
        collection.instance_variable_set(:@counter, 0)
      end

      it "delegates to the master" do
        collection.directed.should == master
      end

      it "increments the counter" do
        collection.directed
        collection.counter.should == 1
      end
    end

    context "when the counter is at the max" do

      before do
        slaves.expects(:empty?).returns(false)
        collection.instance_variable_set(:@counter, 5)
      end

      it "delegates to the slave" do
        collection.directed.should == slaves
      end

      it "resets the counter" do
        collection.directed
        collection.counter.should == 0
      end
    end

    context "when the slave does not exist" do

      before do
        collection.instance_variable_set(:@counter, 5)
        slaves.expects(:empty?).returns(true)
      end

      it "delegates to the master" do
        collection.directed.should == master
      end
    end
  end
end
