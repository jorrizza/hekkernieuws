#!/usr/bin/env ruby

require 'sinatra'
require 'nokogiri'
require 'open-uri'
require 'psych'

dict = Psych.load_file(File.join(File.dirname(__FILE__), 'dict.yml'))

get '/robots.txt' do
  content_type :text
  "User-agent: *\nDisallow: /"
end

get '*' do
  path = params[:splat].first
  path_params = params.map do |k, v|
    "#{k}=#{v}" unless %w{splat captures}.include?(k)
  end.compact.join('&')
  path += "?#{path_params}" if path_params
  url = 'http://news.ycombinator.org' + path
  html = open(url).read
  doc = Nokogiri::HTML(html)

  doc.xpath('//form').each do |form|
    form.remove
  end

  dict.each do |css, trans|
    doc.css(css).each do |html|
      html.xpath('.//text()').each do |text|
        trans.each do |k,v|
          text.content = text.content.gsub(/#{k}/, v)
        end
      end
    end
  end

  doc.to_s
end
