require 'nokogiri'
require 'open-uri'
require 'fileutils'
require 'base64'

time = Time.new
@dict={}

@storynum=5      #story num 
@def_deep=10     #page deep copy
@domain="http://vraku.com:8080"  #domain
@url = 'https://www.bbc.com/zhongwen/simp/'  # target
#@dir = '/autolab/'+time.year.to_s+time.month.to_s+time.day.to_s
@dir='/autolab/'   #server dir saved
@ignores=['/zhongwen/simp/institutional']  #ignore the links which  start with str in array
@dic_file='./dict.txt'

def  readdic
  f=File.open(@dic_file) do |file|
     file.each_line do |labmen|
      @dict[labmen.split(",")[0]]=labmen.split(",")[1]
     end
  end
  f.close
end

def  savedic
 f=File.open(@dic_file,"w+") do |file|
     @dict.each{|s| file.puts(s[0]+","+s[1])}
 end
#   f.close  #way? error?
end

def prepare
  FileUtils.mkdir_p('.'+@dir+"/details/")
  if !File.exist?(@dic_file)
     File.new(@dic_file,"w+")
  end
end

def  parse_node(_node,_deep)
    _node.css('a').each do |nodea|
              if !nodea[:href].start_with?("/zhongwen/simp/")  then
             #        puts "will be removed"+nodea[:href]
                    nodea.parent.remove    
                    next              
              end
              if nodea[:href].start_with?(*@ignores)  then
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
      return    _node.to_html

end


def  getdoc(_url)
     charset = nil
     begin
         html = open(_url) do |f|
            charset = f.charset
            f.read
         end
     doc = Nokogiri::HTML.parse(html, nil, charset)
     rescue
          puts("-----------------cannot not geturl : "+_url)
          @dict[_url]="404.html"
          return
     end

    return doc
end

def getdetailpage(_url,_file,_deep)
      charset = nil

      if @dict[_url] then
          return
      end 
      if _deep>@def_deep then
          return
      end
      
      @dict[_url]=_file
         
      mfile = File.open('.'+@dir + _file, "w")
      myhtml=""
      doc=getdoc(_url)
     # //*[@id="page"]/div/div[2]/div/div[1]/div[1]
      doc.xpath('//*[@id="page"]/div/div[2]/div/div[1]/div[1]').each do |node|
           myhtml+=parse_node(node,_deep)
      end
      mfile.puts(myhtml)
      mfile.close
end

def getindex
     mfile = File.open('.'+@dir+"/top.html", "w") 
     myhtml=""
     doc=getdoc(@url) 
     storyid=1
     while storyid<=@storynum
 
	 doc.xpath('//*[@id="comp-top-story-'+storyid.to_s+'"]').each do |node|
            myhtml+=parse_node(node,1)
 	 end
     storyid+=1
     end
    mfile.puts(myhtml)
    mfile.close
end

prepare
readdic
getindex
savedic
