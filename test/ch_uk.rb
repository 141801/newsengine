require 'nokogiri'
require 'open-uri' 

# index.htmlを読み込み
#


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

url='https://www.bbc.com/zhongwen/simp/uk-50082986'
doc = getDoc(url).css('.column--primary')
puts doc.css('.story-body__h1')#get the colume primaryp
f=doc.css('.story-body__inner')[0]
f.css('.js-delayed-image-load').each do |node|
      node.parent.parent.remove
end
f.css('.media-with-caption__caption').each do |node|
	node.parent.remove
end

f.css('.story-body__line').each do |node|
	node.remove
end

puts f