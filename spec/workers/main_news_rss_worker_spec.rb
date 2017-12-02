require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe MainNewsRssWorker do
  before(:all) do
    Sidekiq::Testing.fake!
  end
  before do
    Sidekiq::Worker.clear_all
  end
  after(:all) do
    Sidekiq::Testing.disable!
  end

  describe "adding worker to queue" do
    let (:url) { YandexMainNewsRssService.default_url }

    it 'should increment queue size' do
      expect { described_class.perform_async(url: url) }.to change { described_class.jobs.size }.from(0).to(1)
    end

  end
end
