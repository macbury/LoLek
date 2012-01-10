# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = App::Config["url"]

SitemapGenerator::Sitemap.create do
  add root_path, :priority => 1.0, :changefreq => 'daily'
  add pending_links_path, :priority => 1.0, :changefreq => 'daily'
  add popular_links_path, :priority => 1.0, :changefreq => 'daily'
  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host
  #
  # Examples:
  #
  # Add '/articles'
  #
  #   add articles_path, :priority => 0.7, :changefreq => 'daily'
  #

  Link.is_published.all.each do |link|
    if link.image?
      add link_path(:id => link.id), lastmod: link.publish_at, images: { loc: File.join(App::Config["url"], link.file.url), title: link.seo_description }
    else
      add link_path(:id => link.id), lastmod: link.publish_at
    end
  end
  
  # Add all articles:
  #
  #   Article.find_each do |article|
  #     add article_path(article), :lastmod => article.updated_at
  #   end
end
