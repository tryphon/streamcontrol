# require "rails_helper"

feature "Scenario management" do
  scenario "User creates a new Stream" do
    visit "/streams/new"

    fill_in "Name", :with => "Test Stream"

    select "Icecast2", from: "Server type"

    fill_in "Server", :with => "stream-in.tryphon.eu"
    fill_in "Port", :with => "8000"
    fill_in "Mount point", :with => "streamcontrol.mp3"
    fill_in "Password", :with => "secret"

    choose "MP3"
    choose "VBR"

    select "7", from: "Quality"

    fill_in "Description", :with => "A Stream Test"
    fill_in "Genre", :with => "Test"
    fill_in "Related url", :with => "http://www.tryphon.eu"

    click_button "Add"

    expect(current_url).to eq(stream_url(id: 1))

    expect(page).to have_text("Stream was successfully created")

    expect(page).to have_text("Stream Test Stream")

    expect(page).to have_text("Server type : Icecast2")

    expect(page).to have_text("Server : stream-in.tryphon.eu")
    expect(page).to have_text("Port : 8000")
    expect(page).to have_text("Mount point : streamcontrol.mp3")
    expect(page).to have_text("Password : secret")

    expect(page).to have_text("Format : MP3, VBR, Quality : 7")
  end
end
