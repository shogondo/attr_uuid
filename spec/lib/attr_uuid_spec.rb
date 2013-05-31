require "spec_helper"
require "attr_uuid"

class Model1
  include AttrUuid
  attr_uuid :uuid
  attr_accessor :uuid
  def initialize(uuid)
    @uuid = UUIDTools::UUID.parse(uuid).raw
  end
end

class Model2
  include AttrUuid
  attr_uuid 1
end

describe AttrUuid do
  subject(:model) { Model1.new("faea220a-e94e-442c-9ca0-5b39753e3549") }

  describe ".attr_uuid" do
    it { expect(model.respond_to?(:formatted_uuid)).to be_true }
    it { expect(model.respond_to?(:formatted_uuid=)).to be_true }
    it { expect(model.respond_to?(:hex_uuid)).to be_true }
    it { expect(model.respond_to?(:hex_uuid=)).to be_true }

    context "when argument is neither String nor Symbol" do
      subject(:model) { Model2.new }
      it { expect(model.respond_to?(:formatted_1)).to be_false }
      it { expect(model.respond_to?(:formatted_1=)).to be_false }
      it { expect(model.respond_to?(:hex_1)).to be_false }
      it { expect(model.respond_to?(:hex_1=)).to be_false }
    end
  end

  describe "#formatted_xxx" do
    it "returns formatted attribute value" do
      expect(model.formatted_uuid).to eq "faea220a-e94e-442c-9ca0-5b39753e3549"
    end
  end

  describe "#formatted_xxx=" do
    it "updates original attribute" do
      uuid = UUIDTools::UUID.parse("d8354fff-f782-4b86-b4a7-7db46a5426d7")
      model.formatted_uuid = uuid.to_s
      expect(model.uuid).to eq uuid.raw
    end
  end

  describe "#hex_xxx" do
    it "returns hex digested attribute value" do
      expect(model.hex_uuid).to eq "faea220ae94e442c9ca05b39753e3549"
    end
  end

  describe "#hex_xxx=" do
    it "updates original attribute" do
      uuid = UUIDTools::UUID.parse("d8354fff-f782-4b86-b4a7-7db46a5426d7")
      model.hex_uuid = uuid.hexdigest
      expect(model.uuid).to eq uuid.raw
    end
  end
end
