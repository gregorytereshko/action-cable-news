require 'rails_helper'

RSpec.describe RedisHashService do

  # let(:redis_conn) { Redis.new }
  let(:test_key) { 'test_key' }
  let(:test_value) { { test: '123' } }
  before(:all) do
    @redis_conn = Redis.new(url: ENV['REDIS_VARS_URL'])
  end
  before do
    @redis_conn.flushall
  end
  subject { described_class.new(test_key, redis: @redis_conn) }

  describe 'setting instance vars' do
    it 'should has proper key' do
      expect(subject.key).to equal(test_key)
    end

    it 'should has redis' do
      expect(subject.redis).to be_a_kind_of(Redis)
    end
  end

  describe 'working with data' do

    context 'writing' do
      context '#set' do
        context 'valid value' do
          let(:result) { subject.set(test_value) }
          it { expect(result).to match('OK') }
        end
        context 'invalid value' do
          it { expect { subject.set("Invalid data") }.to raise_error(TypeError) }
        end
      end
    end

    context 'reading' do
      before do
        subject.set(test_value)
      end

      context '#get' do
        let(:get) { subject.get }

        it { expect(get).to eql(test_value.to_json) }
      end

      context '#structured' do
        let(:structured) { subject.structured }

        it { expect(structured).to eql(OpenStruct.new(test_value)) }
      end

      context '#hashed' do
        let(:hashed) { subject.hashed }

        it { expect(hashed).to be_a_kind_of(Hash) }
      end

      context '#del' do
        let(:deleted) { subject.del }

        it { expect(deleted).to eql(1) }
      end

      context '#same?' do
        context 'valid value' do
          let(:result) { subject.same?(test_value) }

          it { expect(result).to be_truthy }
        end
        context 'invalid value' do
          let(:result) { subject.same?({data: 'invalid'}) }

          it { expect(result).to be_falsey }
        end
      end

      context '#present?' do
        context 'valid value' do
          let(:result) { subject.present? }

          it { expect(result).to be_truthy }
        end
        context 'invalid value' do
          before { subject.del }
          let(:result) { subject.present? }

          it { expect(result).to be_falsey }
        end
      end


    end


  end

end
