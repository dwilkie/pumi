shared_examples_for "location" do
  describe ".all" do
    let(:result) { described_class.all }
    it { expect(result.first).to be_a(described_class) }
  end

  describe ".find_by_id(id)" do
    let(:result) { described_class.find_by_id(id) }

    context "for a known id" do
      let(:id) { sample_id }
      it { expect(result).to be_a(described_class) }
    end

    context "for an unknown id" do
      let(:id) { "99999999" }
      it { expect(result).to eq(nil) }
    end
  end

  describe "instance accessors" do
    subject { described_class.new(id, nil, {"name_en" => name_en, "name_km" => name_km}) }
    let(:id) { 12 }
    let(:name_en) { "Phnom Penh" }
    let(:name_km) { "ភ្នំពេញ" }
    describe "#id" do
      it { expect(subject.id).to eq(id) }
    end

    describe "#name" do
      it { expect(subject.name).to eq(name_km) }
    end

    describe "#name_km" do
      it { expect(subject.name_km).to eq(name_km) }
    end

    describe "#name_en" do
      it { expect(subject.name_en).to eq(name_en) }
    end
  end
end
