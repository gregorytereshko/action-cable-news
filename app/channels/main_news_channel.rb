class MainNewsChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'main_news'
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

end
