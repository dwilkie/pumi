require 'rails_helper'
require 'pry'

describe "pumi.js", :js do
  before do
    visit(new_address_path)
  end

  let(:sample_disabled_class) { "my-disabled-class" }

  it { expect(page).to have_field('District', :disabled => true) }
  it { expect(page.find("#district")[:class]).to eq(sample_disabled_class) }
  it { expect(page).to have_field('Commune', :disabled => true) }
  it { expect(page.find("#commune")[:class]).to eq(sample_disabled_class) }
  it { expect(page).to have_field('Village', :disabled => true) }
  it { expect(page.find("#village")[:class]).to eq(sample_disabled_class) }

  context "Choosing a province" do
    before do
      select("Phnom Penh", :from => "Province")
    end

    it { expect(page).to have_field('District') }
    it { expect(page.find("#district")[:class]).not_to eq(sample_disabled_class) }

    context "Choosing a district" do
      before do
        select("Chamkar Mon", :from => "District")
      end

      it { expect(page).to have_field('Commune') }
      it { expect(page.find("#commune")[:class]).not_to eq(sample_disabled_class) }

      context "Choosing a commune" do
        before do
          select("Tonle Basak", :from => "Commune")
        end

        it { expect(page).to have_field('Village') }
        it { expect(page.find("#village")[:class]).not_to eq(sample_disabled_class) }
        it { expect(page).to have_select("Village", :with_options => ["Phum 1"]) }
      end
    end
  end
end
