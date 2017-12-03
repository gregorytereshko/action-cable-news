# redis_conn = proc {
#   Redis.new(host: ENV['redis_db_3_host'], port: ENV['redis_db_3_post'], password: ENV['redis_db_3_password'], db: 3)
# }

sidekiq_config = { url: ENV['ACTIVE_JOB_URL'] }
Sidekiq.configure_client do |config|
  config.redis = sidekiq_config #ConnectionPool.new(size: 25, &redis_conn)
end
Sidekiq.configure_server do |config|
  config.redis = sidekiq_config #ConnectionPool.new(size: 25, &redis_conn)
end
