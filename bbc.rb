require 'nokogiri'
require 'open-uri' 


def  getDoc(_url)
    _url=URI.parse(URI.escape(_url))
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


url='https://www.bbc.com/zhongwen/simp/chinese-news-49971807'
#url='https://www.bbc.com/zhongwen/simp/chinese-news-50083156'
#url='https://www.bbc.com/zhongwen/simp/business-50096588'
#url='https://www.bbc.com/zhongwen/simp/world-50060829'
#url='https://www.bbc.com/zhongwen/simp/science-50123913'
#url='https://www.bbc.com/zhongwen/simp/world-50128653'
#url='https://www.bbc.com/zhongwen/simp/chinese-news-50123325'
#url='https://www.bbc.com/zhongwen/simp/world-50110944'
#url='https://www.bbc.com/ukchina/simp/vert-cap-48638237'
#url='https://www.bbc.com/zhongwen/simp/uk-50082986'
#url='https://www.bbc.com/zhongwen/simp/chinese-news-50107703'
#doc = getDoc(url).css('.column--primary')
doc=getDoc(url)
puts doc.css('.story-body__h1')#get the colume primaryp


doc.xpath('//@property').remove

f=doc.css('.story-body__inner')[0]

begin
  f.css('.js-delayed-image-load').each do |node|
	_src=node.attributes['data-src']
	node.parent.replace '<img src="'+_src+'">'
  end
rescue
end

begin
  f.css('.media-with-caption__caption').each do |node|
	node.parent.remove
  end
rescue
end

begin
  f.css('.story-body__line').each do |node|
	node.remove
  end
rescue
end


begin
  f.css('.story-body__unordered-list').each do |node| 
	node.remove
  end
rescue
end

begin
  f.css('story-body__list-item').each do  |node|
	node.remove
  end
rescue
end

begin
  f.css('.bbccom_slot.mpu-ad').each do |node|
	node.remove
  end
rescue
end


begin
  f.css('a').each do |node|
	   node.replace node.inner_html       
  end
rescue
end


begin
  f.css('.off-screen').each do  |node|
        node.remove
  end
rescue
end


begin
  f.css('.media-caption__text').each do  |node|
        node.remove

  end
rescue
end

begin
   f.css('.story-image-copyright').each do  |node|
        node.remove
   end
rescue
end

begin
  f.xpath('//@width').remove
rescue
end

begin
  f.xpath('//@height').remove
rescue
end

begin
  f.css('.social-embed').each do |node|
        node.remove
  end
rescue
end

puts f
