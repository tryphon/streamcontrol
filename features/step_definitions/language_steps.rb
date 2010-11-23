class Capybara::Driver::RackTest
  def headers(key = nil, value = nil)
    if key.nil?
      @headers ||= {}
    elsif value.nil?
      headers[key]
    else
      headers[key] = value
    end
  end

  def env
    env = headers.dup
    begin
      env["HTTP_REFERER"] = request.url
    rescue Rack::Test::Error
      # no request yet
    end
    env
  end

end

Given /^an Accept Language header with "(.*)"$/ do |languages|
  page.driver.headers "HTTP_ACCEPT_LANGUAGE", languages
end
