every 1.day, :at => '1:00 am' do 
  rake "lolek:fetch"
  rake "lolek:position"
end

every 1.day, :at => '5:00 am' do
  rake "-s sitemap:refresh"
  rake "lolek:spam"
  rake "lolek:randomize"
end

every 1.week, :at => "23:00 am" do
  rake "tmp:clear"
  rake "tmp:create"
  rake "lolek:ranks"
end