def darkice_config
  @darkice_config ||= DarkiceConfig.new.tap do |config|
    config[:"icecast2-0"] = {
      :bitrateMode => "vbr",
      :format => "vorbis",
      :quality => 0.1,
      :server => "localhost",
      :port => 8000,
      :password => "secret",
      :mountPoint  => "test.ogg"
    }
  end
end

def darkice_process
  @darkice_process ||= Darkice::Process.new(:config_file => darkice_config.write.file, :logger => Rails.logger)
end

def wait_for(limit = 5, &block)
  time_limit = Time.now + limit
  begin
    sleep 0.2 
    raise "Timeout" if Time.now > time_limit 
  end until yield
end

Given /^no stream is configured in darkice$/ do
  darkice_config.sections.delete :"icecast2-0"
end

Given /^the stream ([^ ]*) is "([^\"]*)"$/ do |parameter, value|
  darkice_config[:"icecast2-0"][parameter.to_sym] = value
end

When /^darkice starts$/ do
  darkice_process.run
end

Given /^darkice is running$/ do
  Thread.new { darkice_process.run }
  wait_for { darkice_process.running? }
end

When /^darkice is killed$/ do
  darkice_process.kill
  wait_for { darkice_process.status != :stopped }
end
