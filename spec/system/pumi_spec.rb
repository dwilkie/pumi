require "rails_helper"

RSpec.describe "pumi.js", :js, type: :system do
  it "submits a Pumi form" do
    visit(new_address_path)

    expect(page).to have_field("District", disabled: true)
    expect(page.find("#district")[:class]).to eq("my-disabled-class")
    expect(page).to have_field("Commune", disabled: true)
    expect(page.find("#commune")[:class]).to eq("my-disabled-class")
    expect(page).to have_field("Village", disabled: true)
    expect(page.find("#village")[:class]).to eq("my-disabled-class")

    select("Banteay Meanchey", from: "Province")

    expect(page).to have_field("District", disabled: false)
    expect(page.find("#district")[:class]).not_to eq("my-disabled-class")

    select("Mongkol Borei", from: "District")

    expect(page).to have_field("Commune", disabled: false)
    expect(page.find("#commune")[:class]).not_to eq("my-disabled-class")

    select("Bat Trang", from: "Commune")

    expect(page).to have_field("Village", disabled: false)
    expect(page.find("#village")[:class]).not_to eq("my-disabled-class")

    select("Khtum Reay Lech", from: "Village")
    click_button("Save")

    expect(page).to have_select("Province", selected: "Banteay Meanchey")
    expect(page).to have_select("District", selected: "Mongkol Borei")
    expect(page).to have_select("Commune", selected: "Bat Trang")
    expect(page).to have_select("Village", selected: "Khtum Reay Lech")
  end
end
