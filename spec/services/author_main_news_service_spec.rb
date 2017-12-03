require 'rails_helper'
require "action_cable/testing/rspec"

RSpec.describe AuthorMainNewsService do

  before(:all) do
    Sidekiq::Testing.fake!
    @dummy_data = {
      title: 'Dummy title',
      description: 'Dummy description',
      expired_at: DateTime.current + 1.hour,
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
  subject { described_class.new(redis_service: redis) }

  describe "fully implementation parent" do
    context '#public_instance_methods' do
      @methods  = MainNewsService::PROPERTIES

      @methods.each do |method_name|
        it "should not raise on ##{method_name}" do
          expect{subject.send(method_name.to_sym)}.to_not raise_error(NotImplementedError)
        end
      end

      it "should not raise on #properties" do
        expect{subject.properties}.to_not raise_error(NotImplementedError)
      end

      it "should not raise on #run_broadcast" do
        expect{subject.run_broadcast}.to_not raise_error(NotImplementedError)
      end
    end

    context '.private_class_methods' do
      it "should not raise on .identifier" do
        expect{described_class.send(:identifier)}.to_not raise_error(NotImplementedError)
      end
    end
    context '.public_class_methods' do
      it "should not raise on .run_broadcast" do
        expect{described_class.send(:run_broadcast)}.to_not raise_error(NotImplementedError)
      end
    end
  end

  describe '#properties' do
    let(:methods) { MainNewsService::PROPERTIES }
    let(:properties) { subject.properties.keys.map(&:to_s) }
    it "should has all baseclass properties" do
      expect(properties).to include(*methods)
    end

    it "should include specific property" do
      expect(properties).to include('expired_at')
    end
  end

  describe "creating properties" do
    context ".new" do
      subject { described_class.new(@dummy_data) }
      let(:title) { subject.title }
      let(:description) { subject.description }
      let(:published_at) { subject.published_at }
      let(:expired_at) { subject.expired_at }

      context 'properties' do
        it { expect(title).not_to be_blank }
        it { expect(description).not_to be_blank }
        it { expect(published_at).not_to be_blank }
        it { expect(expired_at).not_to be_blank }
      end

    end
  end

  describe 'saving data' do
    context 'with blank properties' do
      subject { described_class.new }
      let(:result) { subject.save! }
      it { expect(result).to be_falsey }
    end
    context 'with fulled properties' do
      context 'exists' do
        before do
          redis.set(@dummy_data)
          subject.assing_attributes(@dummy_data)
        end
        let(:result) { subject.save! }
        it { expect(result).to be_falsey }
      end
      context 'new' do
        before do
          subject.assing_attributes(@dummy_data)
        end
        let(:result) { subject.save! }
        it { expect(result).to be_truthy }
      end
    end
  end

  describe 'calling data' do
    before do
      subject.assing_attributes(@dummy_data)
      subject.save!
    end
    let(:result) { subject.use }
    it { expect(result).to be_kind_of(OpenStruct) }
    it { expect(result.to_h).not_to be_blank }
  end

  describe 'validating data to be a main news' do
    context 'with incorrect expired_at' do
      before do
        @dummy_data[:expired_at] = DateTime.current - 1.day
        subject.assing_attributes(@dummy_data)
        subject.save!
      end

      context '.validate' do
        let(:result) { subject.validate }
        it { expect(result).to be_falsey }
      end
      context '.valid?' do
        let(:result) { subject.valid? }
        it { expect(result).to be_falsey }
      end
      context '.hashed' do
        let(:result) { subject.hashed }
        it { expect(result).to be_blank }
      end
    end
    context 'with correct expired_at' do
      before do
        @dummy_data[:expired_at] = DateTime.current + 1.day
        subject.assing_attributes(@dummy_data)
        subject.save!
      end
      context '.validate' do
        let(:result) { subject.validate }
        it { expect(result).to be_kind_of(OpenStruct) }
      end
      context '.valid?' do
        let(:result) { subject.valid? }
        it { expect(result).to be_truthy }
      end
      context '.hashed' do
        let(:result) { subject.hashed }
        it { expect(result).not_to be_blank }
      end
    end
  end

  describe 'running broadcast' do
    before do
      subject.assing_attributes(@dummy_data)
      subject.save!
    end
    it "should run broadcast worker" do
      expect(MainNewsBroadcastWorker.jobs.size).to equal(1)
    end
  end


end
