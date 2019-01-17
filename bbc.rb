require 'nokogiri'
require 'open-uri'
require 'fileutils'
require 'base64'

@dict={}
@dic_file='./dict.txt'

@domain="http://vraku.com:8080"  #domain
@dir='/autolab/'   #server dir saved
@def_deep=30     #page deep copy

@url = 'https://www.bbc.com/zhongwen/simp/'  # target
@base_url='https://www.bbc.com'  

@ignore_link_list=['/zhongwen/simp/institutional','#']  #ignore the links which  start with str in array
@link_list=['/zhongwen/simp/']


#支持div里面除去小div
#[[div1,[div1_1,div1_2]],
# [div2,[div2_1,div2_2]]]


@home_div_list=[['//*[@id="comp-top-story-1"]',[]],
                ['//*[@id="comp-top-story-2"]',[]],
                ['//*[@id="comp-top-story-3"]',[]]]


@sub_div_list=[['//*[@id="page"]/div/div[2]/div/div[1]/div[1]',['//*[@id="page"]/div/div[2]/div/div[1]/div[1]/div[1]/div/div/div[2]']]]


def  readDic
  f=File.open(@dic_file) do |file|
     file.each_line do |labmen|
      @dict[labmen.split(",")[0]]=labmen.split(",")[1]
     end
  end
  f.close
end

def  saveDic
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

def  getSerialNum
   t = Time.now      
   tf="%10.9f" % t.to_f   #=> "1195280283.536151409"
   return tf.to_s.split('.').join("")
end

def  parse_node(_node,_deep)

    ##deal with <image scr>
    _node.css('img').each do |image|
       if !image.attribute("src").value.start_with?("http") then
          image.attribute("src").value=@base_url+image.attribute("src").value
       end
    end
 
     ##deal with div-src image
     _node.css('div').each do |div|
        if div.attribute("data-src") then
             imagesrc=div.attribute("data-src")
             div.replace '<img src="'+imagesrc+'"/>'
        end
    end

     #######deal with <a>
    _node.css('a').each do |nodea|

              #expect /zh/XX   
              #case1:  <ui><li><a href=random_url></li></ui>
              #case2:  <image><a href=random_url></image>  
              if nodea[:href].start_with?(*@ignore_link_list)  then
                   begin
                     nodea.parent.remove
                   rescue =>e
                     puts e
                   end
                   next
              end
              
              if !nodea[:href].start_with?(*@link_list)  then
                  begin
                     nodea.parent.remove
                   rescue =>e
                     puts e
                   end
                   next       
              end
              puts  nodea[:href]
              detailurl=@base_url+nodea[:href]
              if !@dict[detailurl]
                 fname=getSerialNum+'.html'
                 nodea[:href]=@domain+@dir+'/details/'+fname   #rewrite the html link
                 filepath='/details/'+fname   #file path
                 getSubPage(detailurl,filepath,_deep+1)
              else   
                  nodea[:href]=@domain+@dir+@dict[detailurl]     
              end
   end 
  return    _node
end

def  getDoc(_url)
     _url=uri = URI.parse(URI.escape(_url))
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

def getSubPage(_url,_file,_deep)
      charset = nil
      if @dict[_url] then
          return
      end 
      if _deep>@def_deep then
          return
      end
      if _deep<@def_deep then  #the deepest page not to add to dict bacause It will cause no link problems in future 
           @dict[_url]=_file
      end
      mfile = File.open('.'+@dir + _file, "w")
      myhtml=""
      doc=getDoc(_url)
      @sub_div_list.each do |div_a|
           div_a[1].each do |node|
               doc.xpath(node).remove 
           end
	   doc.xpath(div_a[0]).each do |node|
                myhtml+=parse_node(node,_deep).to_html
           end
      end
      mfile.puts(myhtml)
      mfile.close
end

def getHomePage
     mfile = File.open('.'+@dir+"/top2.html", "w") 
     myhtml=""
     doc=getDoc(@url) 
     @home_div_list.each do |div_a|
         div_a[1].each do |node|
            doc.xpath(node).remove
         end
         doc.xpath(div_a[0]).each do |node|
            myhtml+=parse_node(node,0).to_html
 	 end
     end
    mfile.puts(myhtml)
    mfile.close
end

prepare
readDic
getHomePage
saveDic
