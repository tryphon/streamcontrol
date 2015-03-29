require 'spec_helper'

feature "Scenario management" do

  before do
    @stream  = { identifier: "b0bddf72", target: 'http://source:secret@stream.tryphon.eu:8000/streamcontrol.mp3', format: "mp3:vbr(q=7)", server_type: 'icecast2' }.to_json
    ActiveResource::HttpMock.respond_to do |mock|
      mock.post   "/streams.json",  {}, @stream, 200
      mock.get    "/streams/b0bddf72.json", {}, @stream
    end
  end

  scenario "User creates a new Stream" do
    visit "/streams/new"

    fill_in "Name", :with => "Test Stream"

    select "Icecast2", from: "Server type"

    fill_in "Server", :with => "stream.tryphon.eu"
    fill_in "Port", :with => "8000"
    fill_in "Mount point", :with => "streamcontrol.mp3"
    fill_in "Password", :with => "secret"

    choose "MP3"
    choose "VBR"

    select "7", from: "Quality"

    fill_in "Description", :with => "A Stream Test"
    fill_in "Genre", :with => "Test"
    fill_in "Url", :with => "http://www.tryphon.eu"

    click_button "Add"

    expect(current_url).to eq(stream_url(id: 'b0bddf72'))

    expect(page).to have_text("Stream was successfully created")

    expect(page).to have_text("Server type : Icecast2")

    expect(page).to have_text("Server : stream.tryphon.eu")
    expect(page).to have_text("Port : 8000")
    expect(page).to have_text("Mount point : streamcontrol.mp3")
    expect(page).to have_text("Password : secret")

    expect(page).to have_text("Format : MP3 VBR Quality: 7")
  end
end
