class DarkiceConfig

  attr_accessor :sections
 
  def initialize
    @sections = Hash.new do
      Hash.new
    end

    @sections[:general] = {
      :duration => 1,
      :bufferSecs => 5,
      :reconnect => "yes"
    }

    @sections[:input] = {
      :device          => "/dev/dsp",
      :sampleRate      => 44100,
      :bitsPerSample   => 16,
      :channel         => 2
    }
  end

  delegate :[], :[]=, :to => :sections

  def write
    File.open(file, "w") do |f|
      sections.each_pair do |name, section|
        f.puts "[#{name}]"
        section.each_pair do |attribute, value|
          f.puts "#{attribute} = #{value}"
        end
      end
    end
    self
  end

  def file
    "#{Rails.root}/tmp/darkice.cfg"
  end

end
