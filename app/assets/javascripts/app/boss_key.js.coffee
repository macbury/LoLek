boss_site = "/boss_key.html"
iframe = null
toggle = false
bossKey = ->
  toggle = !toggle

  if toggle
    iframe.css
      height: "100%"
      width: "100%"
    $.cookie "boss_key", true
    iframe.show()
  else
    iframe.hide()

bind = ->
  iframe = $("<iframe src='#{boss_site}'></iframe>")
  iframe.load -> 
    iframe.hide()
    $(window).focus()

  iframe.css({ position: "fixed", top: "0px", right: "0px", left: "0px", bottom: "0px", "z-index": "10000", width: "1px", height: "1px", border: "0px", overflow: "hidden" })
  $('body').append iframe

  $("body").keypress ->
    bossKey() if event.which == 98
  $(window).focus()


$(document).ready -> bind()