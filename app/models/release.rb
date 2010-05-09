require 'open-uri'

class Release < ActiveRecord::Base

  default_scope :order => 'name'

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :status

  def after_initialize
    self.status_updated_at ||= Time.now
    self.status ||= :available
  end

  @@latest_url = nil
  cattr_accessor :latest_url

  def self.check_latest
    Loader.save_release_at(latest_url) do |release|
      release.status = :available
      release.newer?(last)
    end
  end

  @@current_url = nil
  cattr_accessor :current_url

  def self.check_current
    Loader.save_release_at(current_url) do |release|
      release.status = :installed
      true
    end
  end

  def self.check
    check_current
    check_latest
  end

  def self.latest
    latest = last
    latest if latest and latest.newer?(current)
  end

  def self.current
    find_by_status("installed")
  end

  def human_name
    name.gsub("_"," ").capitalize.gsub("box","Box")
  end

  def status
    status = read_attribute :status
    status ? ActiveSupport::StringInquirer.new(status) : nil
  end

  def status=(status, update_timestamp = true)
    write_attribute :status, status ? status.to_s : nil
    self.status_updated_at = Time.now unless new_record?
  end

  def file
    "/tmp/#{name}.tar"
  end

  def newer?(other)
    other.nil? or (self.name and self.name > other.name)
  end

  def presenter
    @presenter ||= ReleasePresenter.new self
  end

  def download!
    return if self.status.downloaded?

    update_attribute :status, :download_pending

    open_url do |u|
      File.open(file, "w") do |f|
        FileUtils.copy_stream(u, f)
      end
    end

    raise "Invalid checksum after download" unless valid_checksum?
    self.status = :downloaded
  ensure
    self.status = :download_failed unless self.status.downloaded?
    save!
  end

  def open_url(&block)
    if URI.parse(url).scheme == "http"
      options = {
        :content_length_proc => lambda { |content_length| update_attribute(:url_size, content_length) }, 
        :progress_proc => lambda { |size| update_download_size(size) }
      }
      open url, options, &block
    else
      open url, &block
    end
  end

  def update_download_size(size)
    if @updated_download_size_at 
      if 10.seconds.ago > @updated_download_size_at
        update_attribute(:download_size, size)
        @updated_download_size_at = Time.now
      end
    else
      @updated_download_size_at = Time.now
    end
  end

  def start_download
    return if self.status.downloaded?

    update_attribute :status, :download_pending
    send_later :download!
  end

  @@install_command = nil
  cattr_accessor :install_command

  def install
    tempfile_with_attributes do |yaml_file|
      logger.info "Install #{self.inspect} : #{install_command} #{file} #{yaml_file}"
      if system "#{install_command} #{file} #{yaml_file}"
        Release.change_current self
        true
      end
    end
  end

  def tempfile_with_attributes(&block)
    Tempfile.open("release-#{name}") do |yaml_file|
      yaml_file.puts self.attributes.to_yaml
      yield yaml_file.path
    end
  end

  def self.change_current(new_release)
    Release.transaction do
      if current_release = current
        current_release.update_attribute :status, :old
      end
      new_release.update_attribute :status, :installed
    end
  end

  def valid_checksum?
    checksum and checksum == file_checksum
  end

  def file_checksum
    Digest::SHA256.file(file).hexdigest if File.exists?(file)
  end

  class Loader

    attr_reader :url

    def initialize(url)
      @url = url
    end

    def self.release_at(url)
      new(url).release if url
    end

    def self.save_release_at(url)
      if release = release_at(url)
        release.save unless block_given? and not yield release
      end
    end

    def attributes
      @attributes ||= YAML.load open(url,&:read) 
    rescue => e
      Rails.logger.error "Can't load attributes from #{url} : #{e}"
      {}
    end

    def supported_attributes
      attributes.reject do |attribute, _|
        not Release.column_names.include? attribute.to_s
      end
    end

    def release
      Release.new supported_attributes
    end

  end

end
