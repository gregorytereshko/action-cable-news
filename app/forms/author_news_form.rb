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
    service.new(
      title: title,
      description: description,
      published_at: published_at,
      expired_at: expired_at
    ).save!
    record = service.use

    update_in_view
  end

  def service
    AuthorMainNewsService
  end

  def update_in_view
    MainNewsBroadcastWorker.perform_async(MainNewsPolicy.new.main_news.to_h)
  end

end
