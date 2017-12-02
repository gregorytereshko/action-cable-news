App.room = App.cable.subscriptions.create "MainNewsChannel",
  received: (data) ->
    return this.render_main_news(data)
  render_main_news: (data) ->
    $part = $(data.main_news).hide()
    console.log($part)
    $('#main_news').html($part)
    $part.fadeIn('fast')
