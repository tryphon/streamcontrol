require 'spec_helper'

describe "/metadata/new.html.erb" do

  let!(:metadata) { assign :metadata, Metadata.new }

  it "should have a song field" do
    render
    response.should have_field('Song')
  end

end
