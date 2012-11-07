# Accessing JSON data works via status_data
# Return State::UP, State::Down, or State::Warning
# Nagios states: 0 (ok), 1 (warning), 2 (critical), 3 (unknown), 4 (dependent)

Services do
	service 'www' do
		if service_flapping? 'avocet', 'http_www' and service_flapping? 'auklet', 'http_www'
			State::WARNING
		elsif service_up? 'avocet', 'http_www' or service_up? 'auklet', 'http_www'
			State::UP
		else
			State::DOWN
		end
	end

	service 'forums' do
		if service_flapping? 'godwit', 'http_forums' or service_flapping? 'gannet', 'http_forums'
			State::WARNING
		elsif service_up? 'godwit', 'http_forums' or service_up? 'gannet', 'http_forums'
			State::UP
		else
			State::DOWN
		end
	end

	service 'wiki' do
		default 'bittern', 'http_wiki'
	end

	service 'planet' do
		default 'brambling', 'http_planet'
	end

	service 'pgo' do
		default 'brambling', 'http_packages'
	end

	service 'lists' do
		default 'pigeon', 'smtp_lists'
	end

	service 'archives' do
		default 'finch'
	end

	service 'cvs' do
		default 'flycatcher', 'ssh_cvs'
	end

	service 'devmanual' do
		default 'brambling', 'http_devmanual'
	end

	service 'overlays' do
		default 'hornbill', 'http_overlays'
	end
	
	service 'tinderbox' do
		default 'tinderbox.dev'
	end

	service 'sources' do
		default 'motmot', 'http_sources'
	end

	service 'rsync' do
		if host_flapping? 'albatross' or host_flapping? 'kookaburra'
			State::WARNING
		elsif host_up? 'albatross' and host_up? 'kookaburra'
			State::UP
		else
			State::DOWN
		end
	end

	service 'bugzilla' do
		if service_flapping? 'yellowbishop', 'http_bugs' or service_flapping? 'yellowleg', 'http_bugs'
			State::WARNING
		elsif service_up? 'yellowbishop', 'http_bugs' and service_up? 'yellowleg', 'http_bugs'
			State::UP
		elsif service_up? 'yellowbishop', 'http_bugs' or service_up? 'yellowleg', 'http_bugs'
			State::WARNING
		else
			State::DOWN
		end
	end

	service 'dgo_ssh' do
		default 'woodpecker', 'ssh_dgo'
	end
	
	service 'dgo_http' do
		default 'woodpecker', 'http_dev_ssl'
	end

	service 'dgo_smtp' do
		default 'woodpecker', 'smtp_dgo'
	end

	service 'dgo_mbox' do
		default 'woodpecker', 'imap_dgo'
	end
end
