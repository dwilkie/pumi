shared_examples_for "location" do
  describe ".all" do
    let(:result) { described_class.all }
    it { expect(result.first).to be_a(described_class) }
  end

  describe ".where(params = {})" do
    let(:result) { described_class.where(params) }

    context "passing no params" do
      let(:params) { {} }
      it { expect(result.size).to eq(asserted_number_of_total) }
    end

    context "filtering by" do
      context "'id'" do
        let(:params) { { "id" => sample_id } }
        it { expect(result.first.id).to eq(sample_id) }
      end

      context "'name_en'" do
        let(:params) { { "name_en" => sample_name_en } }
        it { expect(result.first.name_en).to eq(sample_name_en) }
      end

      context "'name_km'" do
        let(:params) { { "name_km" => sample_name_km } }
        it { expect(result.first.name_km).to eq(sample_name_km) }
      end
    end
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

  describe "#id" do
    it { expect(subject.id).to eq(sample_id) }
  end

  describe "#name_km" do
    it { expect(subject.name_km).to eq(sample_name_km) }
  end

  describe "#name_en" do
    it { expect(subject.name_en).to eq(sample_name_en) }
  end
end

shared_examples_for "district" do
  describe ".where(params = {})" do
    let(:result) { described_class.where(params) }

    context "filtering by" do
      context "'province_id'" do
        let(:params) { { "province_id" => sample_province_id } }
        it { expect(result.size).to eq(asserted_number_of_in_province) }
      end
    end
  end

  describe "#province_id" do
    it { expect(subject.province_id).to eq(sample_province_id) }
  end

  describe "#province" do
    it { expect(subject.province.id).to eq(sample_province_id) }
  end
end

shared_examples_for "commune" do
  describe ".where(params = {})" do
    let(:result) { described_class.where(params) }

    context "filtering by" do
      context "'district_id'" do
        let(:params) { { "district_id" => sample_district_id } }
        it { expect(result.size).to eq(asserted_number_of_in_district) }
      end
    end
  end

  describe "#district_id" do
    it { expect(subject.district_id).to eq(sample_district_id) }
  end

  describe "#district" do
    it { expect(subject.district.id).to eq(sample_district_id) }
  end
end

shared_examples_for "village" do
  describe ".where(params = {})" do
    let(:result) { described_class.where(params) }

    context "filtering by" do
      context "'commune_id'" do
        let(:params) { { "commune_id" => sample_commune_id } }
        it { expect(result.size).to eq(asserted_number_of_in_commune) }
      end
    end
  end

  describe "#commune_id" do
    it { expect(subject.commune_id).to eq(sample_commune_id) }
  end

  describe "#commune" do
    it { expect(subject.commune.id).to eq(sample_commune_id) }
  end
end

shared_examples_for "api request" do
  describe "GET '/'" do
    before do
      do_api_request
    end

    it { expect(json).to be_a(Array) }
    it { expect(json.first["id"]).not_to eq(nil) }
    it { expect(json.first["name_en"]).not_to eq(nil) }
    it { expect(json.first["name_km"]).not_to eq(nil) }
  end
end
