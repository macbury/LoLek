# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->
  
  blank_image = $("#blank_image").attr("src")
  $('.item .inner img').protectImage
    image: $("#blank_image").attr("src")
  
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
