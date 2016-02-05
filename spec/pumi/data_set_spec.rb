require 'spec_helper'

describe Pumi::DataSet do
  describe "#data" do
    it { expect(subject.data).to be_a(Hash) }
  end

  describe "#provinces" do
    it { expect(subject.provinces).to be_a(Hash) }
  end
end
