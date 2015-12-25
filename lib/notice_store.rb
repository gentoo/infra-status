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
      rescue => e
        $stderr.puts 'Invalid notice (%s): %s' % [e.message, file]
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
      is_active &= notice['expire_at'] >= DateTime.now if notice.key? 'expire_at'
      is_active &= notice['created_at'] <= DateTime.now if notice.key? 'created_at'

      is_active
    end
  end

  def active_notices
    notices.select do |notice|
      is_active = notice['active']
      is_active &= notice['expire_at'] >= DateTime.now if notice.key? 'expire_at'
      is_active &= notice['created_at'] <= DateTime.now if notice.key? 'created_at'
      is_active &= notice['starts_at'] <= DateTime.now if notice.key? 'starts_at'

      is_active
    end
  end

  def notice_affects_service(notice, service)
    notice.key?('affects') && !notice['affects'].nil? && notice['affects'].include?(service)
  end

  def active_notices_for(service)
    active_notices.select do |notice|
      notice_affects_service(notice, service)
    end
  end

  def visible_notices_for(service)
    visible_notices.select do |notice|
      notice_affects_service(notice, service)
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
  attr_reader :content

  def self.from_file(filename)
    content = File.read(filename)
    metadata = YAML.load(content) || {}
    metadata['updated_at'] = File.mtime(filename)
    description = 'missing description'
    description_splitpos = nil

    lines = content.split("\n").map(&:strip)
    if lines[0] == '---' && lines.grep('---').length >= 2
      description_splitpos = 2
    elsif lines.grep('---').length >= 1
      description_splitpos = 1
    else
      description_splitpos = 0
    end

    description = content.split('---')[description_splitpos].strip
    new(File.basename(filename, '.txt'), metadata, description)
  end

  def [](what)
    @metadata[what]
  end

  def key?(what)
    @metadata.key? what
  end

  def url
    MY_URL + 'notice/' + @metadata['id']
  end

  private

  def initialize(id, metadata, content)
    @metadata = metadata

    %w(created_at eta expire_at starts_at).each do |key|
      @metadata[key] = DateTime.parse(@metadata[key]) if @metadata.key? key
    end

    @metadata['id'] = id
    @content = content
  end
end
