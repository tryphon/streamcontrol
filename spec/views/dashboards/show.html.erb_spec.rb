require 'spec_helper'

describe "/dashboards/show.html.erb" do

  let!(:events) do
    assign :events, EventDecorator.decorate_collection(Array.new(3) { |n| Event.create! :severity => :info, :message => "dummy" }.paginate)
  end

  it "should display last events" do
    render
    response.should have_selector('table[class=events]') do
      with_tag("td","Dummy", @events.size)
    end
  end
end
