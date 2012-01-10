# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

window.bindFacebook = -> false  

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
  if unread_count > 0
    $('#pending_link').twipsy
      placement: "above"
      title: -> "#{unread_count} nowe obrazki!"
    Notificon("#{unread_count}")
  $('#pending_link').twipsy "show"

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
  
  $('.item .inner img.preview').bind "load", -> 
    return if $(this).data("loaded") == true
    inner = $(this).parents(".inner")
    height = $(this).data("height")
    height ||= $(this).height() - 32
    width = $(this).width()
    $(this).data("height", height)
    src = $(this).data("url")
    $(this).data("loaded", true)
    inner.css
      overflow: "hidden"
      height: "#{height}px"
      background: "transparent url('#{src}') no-repeat top center"
    $(this).css
      height: "#{height}px"
      width: "#{width}px"
    $(this).attr "src", blank_image
