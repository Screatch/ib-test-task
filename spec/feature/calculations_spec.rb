# frozen_string_literal: true

require "spec_helper"

def reimport_exchange_rates
  file = File.open("public/historical_data.json", "rb")
  contents = JSON.parse(file.read)

  ExchangeRate.create(contents)
end

context "Calculations Index Page" do
  let(:user) { FactoryGirl.create(:user) }
  let(:calculation) { FactoryGirl.create(:calculation, user: user) }

  scenario "confirm that we need to log in", js: true do
    visit calculations_path
    expect(page).to have_link("Sign up", href: new_user_registration_path)
  end

  scenario "test with no calculations", js: true do
    login_as(user)
    visit calculations_path
    expect(page).to have_link("New Calculation", href: new_calculation_path)
    expect(page).to have_link("Log out", href: destroy_user_session_path)
    expect(page).to have_content("You have no calculations")
  end

  scenario "test with 1 calculation" do
    login_as(user)

    calculation

    visit calculations_path
    expect(page).to have_css("table")
    expect(page).to have_css(".edit-btn")
    expect(page).to have_css(".delete-btn")
  end
end

context "Calculation New Page" do
  let(:user) { FactoryGirl.create(:user) }

  before(:context) do
    reimport_exchange_rates
  end

  scenario "confirm that new page loads correctly" do
    login_as(user)
    visit new_calculation_path
    expect(page).to have_button("Create Calculation")
  end

  scenario "creating new calculation with invalid data should fail" do
    login_as(user)
    visit new_calculation_path

    # Testing the max weeks to wait and same base and target currency
    fill_in "calculation_base_amount", with: 1500
    select "EUR", from: "calculation_base_currency"
    select "EUR", from: "calculation_target_currency"
    fill_in "calculation_weeks_to_wait", with: 255
    click_on "Create Calculation"

    expect(page).to have_css("#errors")
    expect(page).to have_content("Weeks to wait must be less than or equal to 250")
    expect(page).to have_content("Target currency can't be the same as base currency")
  end

  scenario "succesful creation of calculation" do
    login_as(user)
    visit new_calculation_path

    fill_in "calculation_base_amount", with: 1500
    select "EUR", from: "calculation_base_currency"
    select "CHF", from: "calculation_target_currency"
    fill_in "calculation_weeks_to_wait", with: 25
    click_on "Create Calculation"

    expect(page).to have_content("EUR → CHF")
  end
end

context "Calculation Show Page" do
  before(:context) do
    reimport_exchange_rates
  end

  let(:user) { FactoryGirl.create(:user) }
  let(:calculation) { FactoryGirl.create(:calculation, user: user) }

  scenario "has all the necessary data" do
    login_as(user)
    visit calculation_path(calculation)

    expect(page).to have_content("EUR → CHF")
    expect(page).to have_link("Edit", href: edit_calculation_path(calculation))
    expect(page).to have_link("Edit", href: edit_calculation_path(calculation))
  end
end
