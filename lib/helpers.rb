include Nanoc::Helpers::Blogging
include Nanoc::Helpers::Rendering
require 'date'

# Defining state constants
module State
	UP=1
	DOWN=2
	WARNING=3
end

def service_icons(service)
	content = ""

	if service_has_notices?(service)
		content << notice_icon + " "
	end

	unless (forced_state = get_forced_state(service)) == nil
		content << status_icon(forced_state)
		return content
	end

	case ServiceRegistry.instance.services[service]
	when State::UP
		content << status_icon('up')
	when State::WARNING
		content << status_icon('warning')
	when State::DOWN
		content << status_icon('down')
	else
		content << status_icon('na')
	end

	content
end

def status_icon(status)
	case status.to_s
	when 'up'
		return '<img src="/img/status_up.png" alt="The service is up and running." title="The service is up and running." />'
	when 'down'
		return '<img src="/img/status_down.png" alt="The service is down." title="The service is down." />'
	when 'warning'
		return '<img src="/img/status_warning.png" alt="There are issues with the service." title="There are issues with the service." />'
	when 'maintenance'
		return '<img src="/img/maintenance.png" alt="The service is undergoing scheduled maintenance." title="The service is undergoing scheduled maintenance." />'
	else
		return '<img src="/img/na.png" alt="No data available." title="No data available." />'
	end
end

def notice_icon
	return '<img src="/img/notice.png" alt="There are notices regarding this service posted below." title="There are notices regarding this service posted below." />'
end

def item_icon(type)
	case type.to_s
	when 'maintenance'
		return '<img src="' + base_url + 'img/maintenance.png" alt="Scheduled maintenance" title="Scheduled maintenance" />'
	when 'outage'
		return '<img src="' + base_url + '/img/outage.png" alt="Unplanned outage" title="Unplanned outage" />'
	when 'information'
		return '<img src="' + base_url + '/img/information.png" alt="General information" title="General information" />'
	end
end

# Compiles all active notices into one piece of HTML
def notices
	content=""

	sorted_articles.each do |notice|
		next if is_expired? notice

		content += notice.compiled_content(:snapshot => :single_post)
	end

	content
end

# Are there any notices for the service?
def service_has_notices?(service)
	articles.each do |notice|
		next if is_expired? notice

		if notice.attributes.has_key? :affects and notice[:affects].include? service
			return true
		end
	end
	
	false
end

def get_forced_state(service)
	return nil unless service_has_notices?(service)

	sorted_articles.each do |notice|
		next if is_expired? notice

		if notice.attributes.has_key? :affects and notice[:affects].include? service
			return notice[:force_state] if notice.attributes.has_key? :force_state
		end
	end
end

# Filters expired items and items w/o expiration date that are older than a week.
def is_expired?(notice)
	if notice.attributes.has_key? :active
		return true if notice[:active] != true
	end

	if notice.attributes.has_key? :expire
		expire_date = DateTime.parse(notice[:expire])

		DateTime.now > expire_date
	else
		creation_date = DateTime.parse(notice[:created_at])
		date_diff = DateTime.now - creation_date

		date_diff.to_i > 7
	end
end

def feed_proc
	lambda do |notice|
		notice.compiled_content(:snapshot => :single_post)
	end
end

def feed_articles
	articles.select {|n| not is_expired? n}
end

def base_url
	@site.config[:base_url] + '/'
end
