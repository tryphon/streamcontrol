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
  sleep 0.1 until darkice_process.running?
end

When /^darkice is killed$/ do
  darkice_process.kill
  sleep 0.1 while darkice_process.status != :stopped
end
