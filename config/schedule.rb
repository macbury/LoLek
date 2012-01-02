every 1.day, :at => '1:00 am' do 
  rake "lolek:fetch"
end

every 1.day, :at => '5:00 am' do
  rake "-s sitemap:refresh"
end

every 1.hour do
  rake "lolek:randomize"
end