class AuthorNewsForm
  include ActiveModel::Model
  include ShallowAttributes

  attribute :title, String
  attribute :description, String
  attribute :published_at, DateTime, default: DateTime.current
  attribute :expired_at, DateTime, default: DateTime.current + 1.minute

  validates :title, :description, :published_at, :expired_at, presence: true
  validates :title, :description, length: { maximum: 255 }


  attr_reader :record

  alias_method :_expired_at=, :expired_at=
  alias_method :_published_at=, :published_at=

  def expired_at=(value)
    value = Time.zone.parse(value) if value.kind_of? String
    self._expired_at = value
  end

  def save
    if valid?
      persist!
      true
    else
      false
    end
  end

  private

  def persist!
    news = service.new(
      title: title,
      description: description,
      published_at: published_at,
      expired_at: expired_at
    )
    news.save!
    record = news.use

    run_broadcast(record)
  end

  def service
    AuthorMainNewsService
  end

  def run_broadcast record
    MainNewsBroadcastWorker.perform_async(record.to_h)
  end

end
