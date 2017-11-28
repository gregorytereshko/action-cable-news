App.room = App.cable.subscriptions.create "MainNewsChannel",
  received: (data) ->
    return this.render_main_news(data)
  render_main_news: (data) ->
    $part = $(data.main_news).hide()
    $('#main_news').replaceWith($part)
    $part.fadeIn('fast')
