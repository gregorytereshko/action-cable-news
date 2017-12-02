require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe MainNewsBroadcastWorker do
  before(:all) do
    Sidekiq::Testing.fake!
    @dummy_data = {
      title: 'Dummy title',
      description: 'Dummy description',
      expired_at: DateTime.current + 1.hour,
      published_at: DateTime.current
    }
  end
  before do
    Sidekiq::Worker.clear_all
  end
  after(:all) do
    Sidekiq::Testing.disable!
  end

  describe "adding worker to queue" do
    let (:main_news) { OpenStruct.new(@dummy_data) }

    it 'should increment queue size' do
      expect { described_class.perform_async(main_news) }.to change { described_class.jobs.size }.from(0).to(1)
    end

  end
end
