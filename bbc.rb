require 'nokogiri'
require 'open-uri'
require 'fileutils'
require 'base64'

time = Time.new

require 'nokogiri'
require 'open-uri'
@dict = {}
File.open('lab.txt') do |file|
    file.each_line do |labmen|
       @dict[labmen.split(',')[0]]=labmen.split(',')[1]
    end
end
@def_deep=10

@domain="http://vraku.com:8080"
@url = 'https://www.bbc.com/zhongwen/simp/'
@dir = '/autolab/'+time.year.to_s+time.month.to_s+time.day.to_s
puts @dir
FileUtils.mkdir_p('.'+@dir+"/details/")

def getdetailpage(_url,_file,_deep)
      charset = nil

      if @dict[_url] then
          return
      end 
      if _deep>@def_deep then
          return
      end
      puts  _deep
      @dict[_url]=_file

      begin
         html = open(_url) do |f|
            charset = f.charset
            f.read
         end
      rescue
          puts("-----------------cannot not geturl : "+_url)   
          @dict[_url]="404.html"
          return  
      end
 
      mfile = File.open('.'+@dir + _file, "w")
      myhtml=""
      doc = Nokogiri::HTML.parse(html, nil, charset)
     # //*[@id="page"]/div/div[2]/div/div[1]/div[1]
      doc.xpath('//*[@id="page"]/div/div[2]/div/div[1]/div[1]').each do |node|
          node.css('a').each do |nodea|
              if !nodea[:href].start_with?("/zhongwen/simp/")  then
             #        puts "will be removed"+nodea[:href]
                    nodea.parent.remove    
                    next              
              end
              if nodea[:href].start_with?("/zhongwen/simp/institutional")  then
             #        puts "will be removed"+nodea[:href]
                    nodea.parent.remove
                    next
              end
                      
              puts nodea[:href]
              detailurl='https://www.bbc.com'+nodea[:href]
              fname=nodea[:href]['/zhongwen/simp/'.length..nodea[:href].length-1]
         
              #encoding_data = Base64.encode64(detailurl)  #ファイルの末尾
              nodea[:href]=@domain+@dir+'/details/'+fname+'.html'   #rewrite the html link
              if @dict[detailurl] then
                 puts ("has collected "+fname)
              else
                 filepath='/details/'+fname+'.html' #file path
                 getdetailpage(detailurl,filepath,_deep+1)
              end
          end
          myhtml+=node.to_html
      end
      mfile.puts(myhtml)
      mfile.close
end

def getindex
     charset = nil
     html = open(@url) do |f|
      charset = f.charset
     f.read
     end
     mfile = File.open('.'+@dir+"/top.html", "w") 
     myhtml=""
     doc = Nokogiri::HTML.parse(html, nil, charset)
    
     doc.xpath('//*[@id="comp-top-story-1"]/div/div').each do |node|
       node.css('a').each do |nodea|  
        if !nodea[:href].start_with?("/zhongwen/simp/")  then
             #        puts "will be removed"+nodea[:href]
                    nodea.parent.remove
             next
          end 
         detailurl='https://www.bbc.com'+nodea[:href]
         #encoding_data = Base64.encode64(detailurl)
         #fname=nodea[:href]
         fname=nodea[:href]['/zhongwen/simp/'.length..nodea[:href].length-1]
         
         nodea[:href]=@domain+@dir+'/details/'+fname+'.html'
         filepath='/details/'+fname+'.html'
         getdetailpage(detailurl,filepath,1)           
       end
       myhtml+=node.to_html
    end
    mfile.puts(myhtml)
    mfile.close
    #puts  myhtml 
end

getindex
