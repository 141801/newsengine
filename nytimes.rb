require 'nokogiri'
require 'open-uri'
require 'fileutils'
require 'base64'

Element = Struct.new(:type, :value)



@dict={}
@dic_file='./dict.txt'

@domain="http://vraku.com:8080"  #domain
@dir='/autolab/'   #server dir saved
@def_deep=2     #page deep copy

@url = 'https://cn.nytimes.com/'  # target
@base_url='https://cn.nytimes.com/'

@ignore_link_list=['https://www.nytimes.com']  #ignore the links which  start with str in array
@link_list=['/']

#支持div里面除去小div
#[[div1,[div1_1,div1_2]],
# [div2,[div2_1,div2_2]]]
@home_div_list=[['//*[@id="regularHomepage"]/div[1]/div[1]',[]],
['//*[@id="regularHomepage"]/div[1]/div[2]',[]]]

@sub_div_list=[['/html/body/main/div[2]/article',[Element.new('class','big_ad')]]]

#不要的class属性和tag标签删除
@del_attri_list=['class','data-seconds','aria-hidden','property']
@del_tag_list=['script']

#支持div的id变更
#  div  |  id  |  target_value  |  replece_value
@replace_attri_value=[['div','id','bbccom_mpu_1_2','mm']]

def  readDic
    f=File.open(@dic_file) do |file|
        file.each_line do |s|
            @dict[s.split(",")[0]]=s.split(",")[1]
            
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
            #          #image.attribute("src").value=@base_url+image.attribute("src").value
            #          # image.attribute("src").value='https://'+image.attribute("src").value
            if  image.attribute('data-url')
                
                image.attribute("src").value=image.attribute('data-url').value
            end
            puts image.attribute("src")
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
        
        if nodea[:href] && nodea[:href].start_with?(*@ignore_link_list)  then
            nodea.replace nodea.text
            next
        end
        
        if nodea[:href] && nodea[:href].start_with?(@base_url) then
            nodea[:href]=nodea[:href][@base_url.length-1..nodea[:href].length]
        end
        
        if nodea[:href] &&!nodea[:href].start_with?(*@link_list)  then
            begin
                nodea.remove
                rescue =>e
                puts e
            end
            next
        end
        
        if nodea[:href]
            detailurl=@base_url+nodea[:href]
            puts detailurl
            if !@dict[detailurl]
                fname=getSerialNum+'.html'
                puts fname
                nodea[:href]=@domain+@dir+'/details/'+fname   #rewrite the html link
                filepath='/details/'+fname   #file path
                getSubPage(detailurl,filepath,_deep+1)
                else
                nodea[:href]=@domain+@dir+@dict[detailurl].chop
            end
        end
    end
    return    _node
end

def  getDoc(_url)
    _url=uri = URI.parse(URI.escape(_url))
    charset = nil
    puts _url
    begin
        html = open(_url) do |f|
            charset = f.charset
            f.read
        end
        doc = Nokogiri::HTML.parse(html, nil, charset)
        # puts  doc
        rescue
        puts("-----------------cannot not geturl : "+_url)
        return
    end
    return doc
end

def purlHtml(_html)
    
    _doc= Nokogiri::HTML(_html)
    repalceAttributeValue(_doc)
    delTags(_doc)
    delAttributes(_doc)
    margeBlankDiv(_doc)
    return _doc.to_html
end

def margeBlankDiv(_doc)
    #  _doc.css('div').find_all.each do |div|
    #      if is_blank?(div)
    #         puts  "---------------"+ div
    #      end
    #  end
    return _doc
end

def repalceAttributeValue(_doc)
    @replace_attri_value.each do |rep_a |
        _doc.css(rep_a[0]).each do |ele|
            if ele.attribute(rep_a[1])
                if ele.attribute(rep_a[1]).value==rep_a[2]
                    ele.attribute(rep_a[1]).value=rep_a[3]
                end
            end
        end
    end
    return  _doc
end

def delTags(_doc)
    @del_tag_list.each do |tag|
        _doc.css(tag).remove
    end
    return  _doc
end

def delAttributes(_doc)
    @del_attri_list.each do |attri|
        _doc.css('*').remove_attr(attri)
    end
    return _doc
end
def  generatePage(_url,_div_list,_deep)
    myhtml=""
    doc=getDoc(_url)
    _div_list.each do |div_a|
        doc.xpath(div_a[0]).each do |node1|
            
            div_a[1].each do |node2|
                case node2.type
                    when 'xpath'
                    node1.xpath(node2.value).remove
                    when  'class'
                    node1.css('.'+node2.value).remove
                end
            end
            myhtml+=parse_node(node1,_deep).to_html
        end
    end
    return  purlHtml(myhtml)
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
    mfile.puts(generatePage(_url,@sub_div_list,_deep))
    
    mfile.close
end

def getHomePage
    mfile = File.open('.'+@dir+"/nytimes.html", "w")
    mfile.puts(generatePage(@url,@home_div_list,0))
    mfile.close
end

prepare
readDic
getHomePage
saveDic

