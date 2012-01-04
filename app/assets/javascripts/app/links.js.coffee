# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

window.bindFacebook = ->
  FB.Event.subscribe 'edge.create', (response) ->
    console.log response

$(document).ready ->
  
  blank_image = $("#blank_image").attr("src")

  
  $('#pending_link').twipsy
    placement: "above"
    title: -> "32 nowe linki!"
  $('#pending_link').twipsy "show"

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
    inner = $(this).parents(".inner")
    height = $(this).data("height")
    height ||= $(this).height() - 32
    width = $(this).width()
    $(this).data("height", height)
    src = $(this).data("url")
    inner.css
      overflow: "hidden"
      height: "#{height}px"
      background: "transparent url('#{src}') no-repeat top center"
    $(this).css
      height: "#{height}px"
      width: "#{width}px"
    $(this).attr "src", blank_image
  $('.item .inner img').trigger("load")
