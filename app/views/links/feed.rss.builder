xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "#{I18n.t("title")} - #{I18n.t("summary")}"
    xml.description I18n.t("description")
    xml.link feed_links_url(format: :rss)
    
    for link in @links
      xml.item do
        xml.title I18n.l(link.publish_at, format: :long)
        xml.description image_tag(link.file.rss.url)
        xml.pubDate link.publish_at.to_s(:rfc822)
        xml.link link_url( id: link.id )
        xml.guid link_url( id: link.id )
      end
    end
  end
end