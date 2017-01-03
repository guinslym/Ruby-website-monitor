#!/usr/bin/env ruby

require 'net/http'
require 'active_support'
require 'active_support/core_ext'
require 'timeout'

def url_exist?(url_string)
  url = URI.parse(url_string)
  req = Net::HTTP.new(url.host, url.port)
  req.use_ssl = (url.scheme == 'https')
  path = url.path if url.path.present?
  res = req.request_head(path || '/')
  if res.kind_of?(Net::HTTPRedirection)
    url_exist?(res['location'])  # Go after any redirect and make sure you can access the redirected URL
  else
    ! %W(4 5).include?(res.code[0])  # Not from 4xx or 5xx families
  end
rescue
  false  # false if can't find the server
end

def main()
  url = "https://rosshill.ca" # change this to your website
  timestamp = Time.now.getutc
  begin
    exists = Timeout::timeout(10) {url_exist?(url)}
  rescue
    exists = false
  end
  if !exists
    # send notification
    system("notify-send -t 100000 -u critical 'Your website is down' '<b>%s</b> is down as of <b>%s</b>'" % [url, timestamp])
    # log the downtime with unix time stamp
    open('output.txt', 'a') { |f|
      f.puts Time.now.to_i
    }
  end
end

main()
