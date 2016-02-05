shared_examples_for "location" do
  describe ".all" do
    let(:result) { described_class.all }
    it { expect(result.first).to be_a(described_class) }
  end

  describe "instance accessors" do
    subject { described_class.new(code, nil, {"name_en" => name_en, "name_km" => name_km}) }
    let(:code) { "code" }
    let(:name_en) { "Phnom Penh" }
    let(:name_km) { "ភ្នំពេញ" }
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
