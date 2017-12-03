require 'rails_helper'
require 'sidekiq/testing'



RSpec.describe YandexMainNewsRssService do

  before(:all) do
    Sidekiq::Testing.fake!
    @dummy_data = {
      title: 'Dummy title',
      description: 'Dummy description',
      link: "https://ya.ru",
      published_at: DateTime.current
    }
    @redis_conn = Redis.new(url: ENV['REDIS_VARS_URL'])
  end
  before do
    @redis_conn.flushall
    Sidekiq::Worker.clear_all
  end
  after(:all) do
    Sidekiq::Testing.disable!
  end

  let(:redis) { RedisHashService.new(described_class.identifier, redis: @redis_conn) }
  let(:author_main_news_service) { AuthorMainNewsService.new(redis: @redis_conn) }

  subject { described_class.new(redis_service: redis) }

  describe "fully implementation parent" do
    context '#public_instance_methods' do
      @methods  = MainNewsService::PROPERTIES
      @methods += MainNewsRssService::METHODS

      @methods.each do |method_name|
        it "should not raise on ##{method_name}" do
          expect{subject.send(method_name.to_sym)}.to_not raise_error(NotImplementedError)
        end
      end

      it "should not raise on #properties" do
        expect{subject.properties}.to_not raise_error(NotImplementedError)
      end
    end

    context '.private_class_methods' do
      it "should not raise on .identifier" do
        expect{described_class.send(:identifier)}.to_not raise_error(NotImplementedError)
      end

      it "should not raise on .default_url" do
        expect{described_class.send(:default_url)}.to_not raise_error(NotImplementedError)
      end
    end
    context '.public_instance_methods' do
      it "should not raise on .run_broadcast" do
        expect{subject.send(:run_broadcast)}.to_not raise_error(NotImplementedError)
      end
    end
  end

  describe '#properties' do
    let(:methods) { MainNewsService::PROPERTIES }
    let(:properties) { subject.properties.keys.map(&:to_s) }
    it "should has all baseclass properties" do
      expect(properties).to include(*methods)
    end
  end

  describe "fetching rss data properly" do
    context "#load_main_news" do
      before { subject.load_main_news }
      let(:main_news) { subject.main_news }
      let(:title) { subject.title }
      let(:description) { subject.description }
      let(:published_at) { subject.published_at }
      let(:link) { subject.link }

      it { expect(main_news).not_to be_blank }
      it { expect(main_news).to be_kind_of(RSS::Rss::Channel::Item) }

      context 'properties' do
        it { expect(title).not_to be_blank }
        it { expect(description).not_to be_blank }
        it { expect(published_at).not_to be_blank }
        it { expect(link).not_to be_blank }
      end

    end
  end

  describe 'saving data' do
    context 'with blank properties' do
      let(:result) { subject.save! }
      it { expect(result).to be_falsey }
    end

    context 'with fulled properties' do
      # let(:dummy_data) { MainNewsService::PROPERTIES.map{|prop| [prop, 'Dummy text'] }.to_h }

      context 'exists' do
        before do
          redis.set(@dummy_data)
          subject.main_news = OpenStruct.new(@dummy_data)
        end
        let(:result) { subject.save! }
        it { expect(result).to be_falsey }
      end

      context 'new' do
        before do
          subject.load_main_news
        end
        let(:result) { subject.save! }
        it { expect(result).to be_truthy }
      end
    end
  end


  describe 'running broadcast' do
    context 'with existing author news' do
      let(:dummy_author_news) do
        {
          title: 'Dummy title',
          description: 'Dummy description',
          expired_at: DateTime.current + 1.hour,
          published_at: DateTime.current
        }
      end
      before do
        author_main_news_service.redis_service.set(dummy_author_news)

        subject.load_main_news
        subject.author_main_news_service = author_main_news_service
        subject.save!
      end
      it "shold not to run broadcast worker" do
        expect(MainNewsBroadcastWorker.jobs.size).to equal(0)
      end
    end
    context 'without author news' do
      before do
        subject.load_main_news
        subject.author_main_news_service = author_main_news_service
        subject.save!
      end
      it "shold run broadcast worker" do
        expect(MainNewsBroadcastWorker.jobs.size).to equal(1)
      end
    end
  end

  describe 'calling data' do
    before do
      subject.load_main_news
      subject.save!
    end
    let(:result) { subject.use }
    it { expect(result).to be_kind_of(OpenStruct) }
    it { expect(result.to_h).not_to be_blank }
  end

  describe 'schedule rss check' do
    let(:identifier) { described_class.send(:identifier) }
    context '.run' do
      before do
        described_class.run
        @job_names = Sidekiq::Cron::Job.all.map(&:name)
      end

      it 'must add a job to queue' do
        expect(@job_names).to include(identifier)
      end
    end

    context '.stop' do
      before do
        described_class.stop
        @job_names = Sidekiq::Cron::Job.all.map(&:name)
      end

      after do
        described_class.run
      end

      it 'must remove a job from queue' do
        expect(@job_names).not_to include(identifier)
      end
    end
  end





end
