boss_site = "http://wikipedia.pl"
iframe = null
toggle = false
bossKey = ->
  toggle = !toggle

  if toggle
    iframe.css
      height: "100%"
      width: "100%"

    iframe.show()
  else
    iframe.hide()

bind = ->
  iframe = $("<iframe src='#{boss_site}'></iframe>")
  iframe.load -> 
    iframe.hide()
    $(window).focus()

  iframe.css({ "position":"absolute", top: "0px", right: "0px", left: "0px", bottom: "0px", "z-index": "10000", width: "1px", height: "1px", border: "0px" })
  $('body').append iframe

  $("body").keypress ->
    bossKey() if event.which == 98
  $(window).focus()


$(document).ready -> bind()