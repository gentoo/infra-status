# infra-status.gentoo.org
# Alex Legler <a3li@gentoo.org>
# AGPLv3

require 'bundler/setup'
require 'sinatra'
require 'sinatra/partial'
require 'redcarpet'
require 'rss'

require_relative 'lib/notice_store'
require_relative 'lib/service_registry'
require_relative 'lib/helpers'

MY_URL = 'http://infra-status.gentoo.org/'

configure do
  NoticeStore.instance.update!
  ServiceRegistry.instance.update!
  set :partial_template_engine, :erb
  mime_type :atom, 'application/atom+xml'
end

get '/' do
  erb :index
end

get '/notice/:id' do
  notice = NoticeStore.instance.notice(params[:id])

  if notice.nil?
    status 404
    erb :layout, :layout => false do
      '<h1>No such notice</h1><p>The notice you have requested does not exist or has been removed as it was resolved long ago.</p>'
    end
  else
    erb :notice, :locals => { :notice => notice }
  end
end

get '/feed.atom' do
  rss = RSS::Maker.make('atom') do |maker|
    maker.channel.author  = 'Gentoo Infrastructure Team'
    maker.channel.title   = 'Gentoo Infrastructure Notices'
    maker.channel.link    = MY_URL
    maker.channel.id      = MY_URL
    maker.channel.updated = Time.now.to_s

    NoticeStore.instance.active_notices.each do |notice|
      maker.items.new_item do |item|
        item.link = MY_URL + 'notice/' + notice['id']
        item.title = notice['title']
        item.updated = notice['updated_at'].to_s
        item.description = markdown(notice.get_content)
      end
    end
  end

  content_type :atom
  body rss.to_s
end

# Forcibly update the notice store
get '/force_update' do
  NoticeStore.instance.update!
  ServiceRegistry.instance.update!
  redirect '/#ok'
end

