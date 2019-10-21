require 'nokogiri'
require 'open-uri'
require 'fileutils'
require 'base64'


@dic_file='./dict.txt'

def  saveDic
    f=File.open(@dic_file,"w+") do |file|
	    file.puts(Time.now.strftime("%Y_%m%d").to_s)
    end
end

saveDic    
	        #   f.close  #way? error?
	    #   end
