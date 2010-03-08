#!/usr/bin/ruby
# coding: utf-8
=begin
    Copyright (C) 2010 Nicolás G. Guzzo <nicguzzo@gmail.com>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
=end
##
## Yet another pastebin commandline tool
##
require 'net/http'
require 'uri'
require 'optparse'

formats=["abap","actionscript","actionscript3","ada","apache","applescript","apt_sources","asm","asp","autoit","avisynth","bash","basic4gl","bibtex","blitzbasic","bnf","boo","bf","c","c_mac","cill","csharp","cpp","caddcl","cadlisp","cfdg","klonec","klonecpp","cmake","cobol","cfm","css","d","dcs","delphi","dff","div","dos","dot","eiffel","email","erlang","fo","fortran","freebasic","gml","genero","gettext","groovy","haskell","hq9plus","html4strict","idl","ini","inno","intercal","io","java","java5","javascript","kixtart","latex","lsl2","lisp","locobasic","lolcode","lotusformulas","lotusscript","lscript","lua","m68k","make","matlab","matlab","mirc","modula3","mpasm","mxml","mysql","text","nsis","oberon2","objc","ocaml-brief","ocaml","glsl","oobas","oracle11","oracle8","pascal","pawn","per","perl","php","php-brief","pic16","pixelbender","plsql","povray","powershell","progress","prolog","properties","providex","python","qbasic","rails","rebol","reg","robots","ruby","gnuplot","sas","scala","scheme","scilab","sdlbasic","smalltalk","smarty","sql","tsql","tcl","tcl","teraterm","thinbasic","typoscript","unreal","vbnet","verilog","vhdl","vim","visualprolog","vb","visualfoxpro","whitespace","whois","winbatch","xml","xorg_conf","xpp","z80"]

options = { :duration => '1M', :format=>"text", :name=>'', :subdomain=>'' ,:private=>'0'}
OptionParser.new do |opts|
  opts.banner = "Usage: rpaste [options] file"
  opts.on("-f", "--format FORMAT",String, "Code format") do |f|
    if formats.include?(f.downcase)
      options[:format]=f
    else
      puts "Bad Format: #{f}"
      puts "Use one of these: "+formats.to_s
      exit
    end
  end
	opts.on("-d", "--duration DURATION",String, "Post duration N = Never, 10M = 10 Minutes, 1H = 1 Hour, 1D = 1 Day, 1M = 1 Month") do |d|
    case d
      when 'N','10M','1H','1D','1M'
        options[:duration] = d
      else
        puts "Dad duration!!! use one of N 10M 1H 1D 1M "
        exit
    end
	end
  opts.on("-n", "--name NAME",String,"Post title or name") do |n|
    options[:name] = n
  end
  opts.on("-p", "--private ", "Make this post private")do | p|
    options[:private] = 1
  end
  opts.on("-s", "--subdomain SUBDOMAIN",String,"Use a subdomain")do | s |
    options[:subdomain] = s
  end
end.parse!

code=""
unless STDIN.tty?  # we are in a pipeline
  while((line = STDIN.gets))
    code+=line
  end
else
  file=ARGV[ARGV.length-1]  
  if file and File.exist?(file)
    f=File.open(file,"r")
    code=f.readlines.join("")
  else
    puts "You must specify a file!"
    exit
  end
end

post={
    'paste_code'=>URI.escape(code,"!*'();:@&=+$,/?%#[]" ),
    'paste_expire_date'=>options[:duration],
    'paste_format'=>options[:format],
    'paste_name'=>options[:name],
    'paste_private'=>options[:private],
    'paste_subdomain'=>options[:subdomain],
}

post1=[]
post.each do |k,v|
  post1<<k+'='+v
end
http = Net::HTTP.start("pastebin.com", 80)
resp,data = http.post("/api_public.php",post1.join("&"))

case resp
when Net::HTTPSuccess
  puts "duration set to: #{options[:duration]}"
  puts "link: #{data}" 
else
  resp.error!
  puts "error: #{data}" 
end
