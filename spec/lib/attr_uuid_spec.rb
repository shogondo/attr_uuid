require "spec_helper"
require "active_record"
require "attr_uuid"
require "json"

config_json = File.open(File.join("spec", "config", "database.json")).read
config = JSON.parse(config_json, :symbolize_keys => true)
ActiveRecord::Base.establish_connection(config)

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

class Model3
  include AttrUuid
  attr_uuid :uuid, :column_name => 1
end

describe AttrUuid do
  context "when PORO" do
    subject(:model) { Model1.new("faea220a-e94e-442c-9ca0-5b39753e3549") }

    describe ".attr_uuid" do
      context "when argument is String" do
        it { expect(model.respond_to?(:formatted_uuid)).to be_true }
        it { expect(model.respond_to?(:formatted_uuid=)).to be_true }
        it { expect(model.respond_to?(:hex_uuid)).to be_true }
        it { expect(model.respond_to?(:hex_uuid=)).to be_true }
      end

      context "when argument is neither String nor Symbol" do
        subject(:model) { Model2.new }
        it { expect(model.respond_to?(:formatted_1)).to be_false }
        it { expect(model.respond_to?(:formatted_1=)).to be_false }
        it { expect(model.respond_to?(:hex_1)).to be_false }
        it { expect(model.respond_to?(:hex_1=)).to be_false }
      end

      context "when column alias name is neither String nor Symbol" do
        subject(:model) { Model3.new }
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

  context "when ActiveRecord" do
    context "when disable autofill" do
      with_model :dummy do
        table do |t|
          t.binary :uuid
        end

        model do
          include AttrUuid
          attr_uuid :uuid
        end
      end

      context "when save without uuid" do
        subject(:model) { Dummy.create! }
        it { expect(model.uuid).to be_nil }
      end

      subject(:model) do
        uuid = UUIDTools::UUID.parse("faea220a-e94e-442c-9ca0-5b39753e3549")
        Dummy.new {|o| o.uuid = uuid.raw }
      end

      describe ".attr_uuid" do
        it { expect(model.respond_to?(:formatted_uuid)).to be_true }
        it { expect(model.respond_to?(:formatted_uuid=)).to be_true }
        it { expect(model.respond_to?(:hex_uuid)).to be_true }
        it { expect(model.respond_to?(:hex_uuid=)).to be_true }
        it { expect(Dummy.respond_to?(:find_by_formatted_uuid)).to be_true }
        it { expect(Dummy.respond_to?(:find_by_hex_uuid)).to be_true }
      end

      describe ".find_by_formatted_xxx" do
        before { model.save! }
        subject(:result) { Dummy.find_by_formatted_uuid(uuid) }

        context "when uuid matched" do
          let(:uuid) { "faea220a-e94e-442c-9ca0-5b39753e3549" }
          it { expect(result).to eq model }
        end

        context "when no uuid matched" do
          let(:uuid) { "00000000-e94e-442c-9ca0-5b39753e3549" }
          it { expect(result).to be_nil }
        end

        context "when uuid is nil" do
          let(:uuid) { nil }
          it { expect(result).to be_nil }
        end

        context "when uuid isn't String" do
          let(:uuid) { 1 }
          it { expect(result).to be_nil }
        end

        context "when uuid format is invalid" do
          let(:uuid) { "invalid" }
          it { expect(result).to be_nil }
        end
      end

      describe ".find_by_hex_xxx" do
        before { model.save! }
        subject(:result) { Dummy.find_by_hex_uuid(uuid) }

        context "when uuid matched" do
          let(:uuid) { "faea220ae94e442c9ca05b39753e3549" }
          it { expect(result).to eq model }
        end

        context "when no uuid matched" do
          let(:uuid) { "00000000e94e442c9ca05b39753e3549" }
          it { expect(result).to be_nil }
        end

        context "when uuid is nil" do
          let(:uuid) { nil }
          it { expect(result).to be_nil }
        end

        context "when uuid isn't String" do
          let(:uuid) { 1 }
          it { expect(result).to be_nil }
        end

        context "when uuid format is invalid" do
          let(:uuid) { "invalid" }
          it { expect(result).to be_nil }
        end
      end
    end

    context "when column name alias enabled" do
      with_model :dummy do
        table do |t|
          t.binary :x_uuid
        end

        model do
          include AttrUuid
          attr_uuid :uuid, :column_name => "x_uuid"
        end
      end

      context "when save without uuid" do
        subject(:model) { Dummy.create! }
        it { expect(model.x_uuid).to be_nil }
      end

      subject(:model) do
        uuid = UUIDTools::UUID.parse("faea220a-e94e-442c-9ca0-5b39753e3549")
        Dummy.new {|o| o.x_uuid = uuid.raw }
      end

      describe ".attr_uuid" do
        it { expect(model.respond_to?(:formatted_uuid)).to be_true }
        it { expect(model.respond_to?(:formatted_uuid=)).to be_true }
        it { expect(model.respond_to?(:hex_uuid)).to be_true }
        it { expect(model.respond_to?(:hex_uuid=)).to be_true }
        it { expect(Dummy.respond_to?(:find_by_formatted_uuid)).to be_true }
        it { expect(Dummy.respond_to?(:find_by_hex_uuid)).to be_true }
      end

      describe ".find_by_formatted_xxx" do
        before { model.save! }
        subject(:result) { Dummy.find_by_formatted_uuid(uuid) }

        context "when uuid matched" do
          let(:uuid) { "faea220a-e94e-442c-9ca0-5b39753e3549" }
          it { expect(result).to eq model }
        end

        context "when no uuid matched" do
          let(:uuid) { "00000000-e94e-442c-9ca0-5b39753e3549" }
          it { expect(result).to be_nil }
        end
      end

      describe ".find_by_hex_xxx" do
        before { model.save! }
        subject(:result) { Dummy.find_by_hex_uuid(uuid) }

        context "when uuid matched" do
          let(:uuid) { "faea220ae94e442c9ca05b39753e3549" }
          it { expect(result).to eq model }
        end

        context "when no uuid matched" do
          let(:uuid) { "00000000e94e442c9ca05b39753e3549" }
          it { expect(result).to be_nil }
        end
      end
    end

    context "when enable autofill" do
      with_model :dummy do
        table do |t|
          t.binary :uuid
        end

        model do
          include AttrUuid
          attr_uuid :uuid, :autofill => true
        end
      end

      context "when uuid is nil" do
        before do
          @uuid = UUIDTools::UUID.parse("080cd5cb-9556-4c07-9af3-a4559cf52627")
          UUIDTools::UUID.stub(:timestamp_create).and_return(@uuid)
        end
        subject(:model) { Dummy.create! }
        it { expect(model.uuid).to eq @uuid.raw }
      end

      context "when uuid is empty" do
        before do
          @uuid = UUIDTools::UUID.parse("40d5fafe-ff68-4606-9de7-554eae0d77a3")
          UUIDTools::UUID.stub(:timestamp_create).and_return(@uuid)
        end
        subject(:model) { Dummy.create! {|o| o.uuid = ""} }
        it { expect(model.uuid).to eq @uuid.raw }
      end

      context "when uuid is set" do
        subject(:model) do
          @uuid = UUIDTools::UUID.parse("3e1fe985-2fbf-44ce-a5fb-d1b3db49260d")
          Dummy.create! {|o| o.uuid = @uuid.raw }
        end
        it { expect(model.uuid).to eq @uuid.raw }
      end
    end
  end
end
