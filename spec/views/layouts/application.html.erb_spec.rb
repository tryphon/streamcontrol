require 'spec_helper'

describe "/layouts/application.html.erb" do

  it "should display link to Network" do
    render
    response.should have_link('Network')
  end

end
