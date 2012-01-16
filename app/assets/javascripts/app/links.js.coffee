
window.bindFacebook = -> 
  $("#invite_friends").click ->
    FB.ui
      method: 'apprequests',
      message: 'Witaj! Zaproś swoich znajomych do korzystania z Hardzio.pl! Każdy znajomy to dodatkowe punkty do zdobycia!',
      (resp) -> console.log(resp)
    false
        


onShare = (item) ->
  counter = item.find('.fb_share_count_inner')
  likes = parseInt(counter.text()) + 1
  counter.text(likes)

  $.getJSON item.data("like"), (resp) -> 
    if !resp.logged_in && !$.cookie("login_msg")
      like = $("#item_#{resp.id} .like")
      like.twipsy
        placement: "above"
        html: true
        offset: 20
        title: -> 
          btn = $("#login_button").clone()
          btn.removeAttr("id")
          obj = $("<p>Zaloguj się w hardzio.pl aby zdobywać punkty i odznaki za osiągnięcia!</p>")
          p = $("<p></p>")
          p.append(btn)
          obj.append(p)
          obj.html()
      like.twipsy "show"
    if resp.liked
      console.log "inc"

$(document).ready ->
  blank_image = $("#blank_image").attr("src")
  
  unread_count = $('#pending_link').data("count")

  show_unreaded = -> if unread_count > 0
    $('#pending_link').twipsy
      placement: "above"
      title: -> "#{unread_count} nowe obrazki!"
    Notificon("#{unread_count}")
    $('#pending_link').twipsy "show"
  
  setTimeout show_unreaded, 1000

  $('.item .facebook-share-button').click ->
    item = $(this)
    FB.ui {
      method: 'feed',
      link: item.attr("href"),
    }, (response) -> onShare(item)
      

    false

  items = []
  $('.item').each ->
    items.push $ @
  
  last_item = null
  for item in items.reverse()
    if last_item?
      item.find(".next").attr("href", "##{last_item.attr('id')}")
    else
      item.find(".next").attr("href", "#pages")
    last_item = item
  
  $('.item .next').click ->
   elementClicked = $(this).attr("href")
   destination = $(elementClicked).offset().top
   $("html:not(:animated),body:not(:animated)").animate({ scrollTop: destination-20}, 500 )
   return false

  $('.modal').addClass("in")
  $('.modal a').click ->
    $('.modal').fadeOut()
    $('.modal-backdrop').fadeOut()
    false
  
  $("#add_image").click ->
    $('#pending_link').twipsy "hide"
    $('.uploader').animate 
      height: $('.uploader .inner').height() + 20
    $(this).fadeOut()
    false
  
  $('.item .inner .game').each ->
    swfobject.embedSWF($(this).data("url"), $(this).attr("id"), $(this).data("width"), $(this).data("height"), "9.0.0", "expressInstall.swf");
  
  $('.item .inner .image').each ->
    img = new Image()
    url = $(this).data("img")
    img.onload = =>
      $(this).css
        "background-image": "url(#{url})"
      $(this).addClass("loaded")
    img.src = url
