require 'rails_helper'
require 'pry'

describe "pumi.js", :js do
  before do
    visit(new_address_path)
  end

  let(:sample_disabled_class) { "my-disabled-class" }

  it "should disable the District, Commune and Village fields by default" do
    expect(page).to have_field('District', :disabled => true)
    expect(page.find("#district")[:class]).to eq(sample_disabled_class)
    expect(page).to have_field('Commune', :disabled => true)
    expect(page.find("#commune")[:class]).to eq(sample_disabled_class)
    expect(page).to have_field('Village', :disabled => true)
    expect(page.find("#village")[:class]).to eq(sample_disabled_class)
  end

  context "Choosing a province" do
    before do
      select("Phnom Penh", :from => "Province")
    end

    it "should enable the District input" do
      expect(page).to have_field('District')
      expect(page.find("#district")[:class]).not_to eq(sample_disabled_class)
    end

    context "Choosing a district" do
      before do
        select("Chamkar Mon", :from => "District")
      end

      it "should enable the Commune input" do
        expect(page).to have_field('Commune')
        expect(page.find("#commune")[:class]).not_to eq(sample_disabled_class)
      end

      context "Choosing a commune" do
        before do
          select("Tonle Basak", :from => "Commune")
        end

        it "should enable the Village input" do
          expect(page).to have_field('Village')
          expect(page.find("#village")[:class]).not_to eq(sample_disabled_class)
        end

        context "Choosing a province then submitting the form" do
          before do
            select("Phum 1", :from => "Village")
            click_button("Save")
          end

          it "should remember by selection" do
            expect(page).to have_select("Province", :selected => "Phnom Penh")
            expect(page).to have_select("District", :selected => "Chamkar Mon")
            expect(page).to have_select("Commune", :selected => "Tonle Basak")
            expect(page).to have_select("Village", :selected => "Phum 1")
          end
        end
      end
    end
  end
end
