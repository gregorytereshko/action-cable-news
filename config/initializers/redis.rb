# $redis = Redis.new({
#   host: ENV['redis_db_2_host'],
#   port: ENV['redis_db_2_port'].to_i,
#   db: 2,
#   password: ENV['redis_db_2_password'],
#   namespace: ENV['redis_db_2_namespace']
# })

$redis = Redis.new(url: ENV['REDIS_VARS_URL'])
