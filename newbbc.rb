require 'nokogiri'
require 'open-uri'
require 'fileutils'
require 'base64'
require 'json'

@url = 'https://www.bbc.com/zhongwen/simp/'  # target
@base_url='https://www.bbc.com'
@dir='/autolab/'  

@page_urls=[]
@divhash={}
@navi_links=['//*[@id="comp-top-story-1"]/div/div/a[1]']

def  getDoc(_url)
    _url= URI.parse(URI.escape(_url))
    charset = nil
    begin
        html = open(_url) do |f|
            charset = f.charset
            f.read
        end
        doc = Nokogiri::HTML.parse(html, nil, charset)
        rescue
        puts("-----------------cannot not geturl : "+_url)
        return
    end
    return doc
end

# do something to pure the new page node
def parse_node(_node)
    return _node
end

# generate the new page node
def  generatePage(_url)
    
    #return parsetree(@divhash,_url)
     puts _url 
     rc=getDoc(_url).xpath('/html/body/div[2]/div[6]/div/div[5]/div/div[2]/div/div[1]')
     puts  rc.children[0].text
      rc.each do |node|
	 #      node.remove
	  puts node.path
      end

      

      return rc
  
end


## generate target page of  bbc.html
def getHomePage
    mfile = File.open("bbc.html", "w")
    @page_urls.each do |_url|
             mfile.puts(generatePage(_url))
     end
end   

## get pageurl by navi page
def  getPageUrl
       @navi_links.each do |_link|
	       _div=getDoc(@url).xpath(_link)
	     @page_urls.push(@base_url+_div.css('a')[0].attribute("href"))
        end
end

def  naviPage
      getPageUrl
end


def  readParseTree
      File.open("bbc.json") do |file|
         	  @divhash = JSON.load(file)
     end
       
      @divhash.each{|_div,_subdiv| puts "#{_div}\t#{_subdiv}" }

end

readParseTree
naviPage
getHomePage
