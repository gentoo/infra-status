require 'yaml'
require 'date'
require 'singleton'

# Stores notices and caches them in memory.
# Automatically refreshes the cache after CACHE_SECONDS seconds.
class NoticeStore
  include Singleton
  CACHE_SECONDS = 600
  attr_reader :load_date

  def initialize
    update!
  end

  def update!
    @notices = []

    Dir.glob('data/notices/*.txt') do |file|
      begin
        @notices << Notice.from_file(file)
      rescue ArgumentError
        $stderr.puts 'Invalid notice: %s' % file
      end
    end

    @notices.sort! { |a, b| b['created_at'] <=> a['created_at'] }

    @load_date = DateTime.now
  end

  def notices
    update?
    @notices
  end

  def visible_notices
    notices.select do |notice|
      is_active = notice['active']
      is_active &= notice['expire_at'] >= DateTime.now if notice.has_key? 'expire_at'
      is_active &= notice['created_at'] <= DateTime.now if notice.has_key? 'created_at'

      is_active
    end

  end

  def active_notices
    notices.select do |notice|
      is_active = notice['active']
      is_active &= notice['expire_at'] >= DateTime.now if notice.has_key? 'expire_at'
      is_active &= notice['created_at'] <= DateTime.now if notice.has_key? 'created_at'
      is_active &= notice['starts_at'] <= DateTime.now if notice.has_key? 'starts_at'

      is_active
    end
  end

  def active_notices_for(service)
    active_notices.select do |notice|
      notice.has_key? 'affects' and notice['affects'].include? service
    end
  end

  def visible_notices_for(service)
    visible_notices.select do |notice|
      notice.has_key? 'affects' and notice['affects'].include? service
    end
  end

  def notice(id)
    notices.each do |notice|
      return notice if notice['id'] == id
    end

    nil
  end

  private
  def update?
    if ((DateTime.now - @load_date) * 60 * 60 * 24).to_i > CACHE_SECONDS
      update!
    end
  end
end

class Notice
  def self.from_file(filename)
    content = File.read(filename)
    metadata = YAML.load(content) || {}
    metadata['updated_at'] = File.mtime(filename)

    new(File.basename(filename, '.txt'), metadata, content.split('---')[2].strip)
  end

  def [](what)
    if @metadata.has_key? what
      @metadata[what]
    else
      nil
    end
  end

  def has_key?(what)
    @metadata.has_key? what
  end

  def get_content
    @content
  end

  private
  def initialize(id, metadata, content)
    @metadata = metadata

    %w[created_at eta expire_at starts_at].each do |key|
      @metadata[key] = DateTime.parse(@metadata[key]) if @metadata.has_key? key
    end

    @metadata['id'] = id
    @content = content
  end
end