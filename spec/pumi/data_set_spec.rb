require 'spec_helper'

describe Pumi::DataSet do
  describe "#data" do
    it { expect(subject.data).to be_a(Hash) }
  end

  describe "#provinces" do
    it { expect(subject.provinces).to be_a(Hash) }
  end

  describe "#districts" do
    it { expect(subject.districts).to be_a(Hash) }
  end

  describe "#communes" do
    it { expect(subject.communes).to be_a(Hash) }
  end

  describe "#villages" do
    it { expect(subject.villages).to be_a(Hash) }
  end
end
