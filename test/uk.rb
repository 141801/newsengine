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
#url='https://www.bbc.com/zhongwen/simp/world-50110944'
url='https://www.bbc.com/ukchina/simp/vert-cap-48638237'
#url='https://www.bbc.com/zhongwen/simp/uk-50082986'
#url='https://www.bbc.com/zhongwen/simp/chinese-news-50107703'
doc = getDoc(url).css('.column--primary')
puts doc.css('.story-body__h1')#get the colume primaryp


doc.xpath('//@property').remove

f=doc.css('.story-body__inner')[0]
f.css('.js-delayed-image-load').each do |node|
	_src=node.attributes['data-src']
	node.parent.replace '<img src="'+_src+'">'
end

f.css('.media-with-caption__caption').each do |node|
	node.parent.remove
end

f.css('.story-body__line').each do |node|
	node.remove
end

f.css('.story-body__unordered-list').each do |node| 
	node.remove
end

f.css('story-body__list-item').each do  |node|
	node.remove
end

f.css('.bbccom_slot.mpu-ad').each do |node|
	node.remove
end

f.css('a').each do |node|
	   node.replace node.inner_html       
end

f.css('.off-screen').each do  |node|
        node.remove
end

#f.css('off-story-image-copyrightscreen').each do  |node|
#f.sss)0


f.css('.media-caption__text').each do  |node|
        node.remove

end
#edn

f.css('.story-image-copyright').each do  |node|
        node.remove
end

#^ px
#f.xpath('//@class').remove
f.xpath('//@width').remove
f.xpath('//@height').remove

puts f
