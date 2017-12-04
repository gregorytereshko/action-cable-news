# ACTION CABLE NEWS

 To run this app you'll need:

 ### Clone or download the repo
 ```
 git clone https://...
 ```
 ### Make sure that you haven't running redis or postgresql process on your local machine
 to stop them type:
 ```
 sudo /etc/init.d/redis-server stop
 sudo /etc/init.d/postgresql stop
 ```
 ### Do some changes in .env if needed
 ### Run and build docker
 ```
 docker-compose up --build
 ```
 In future you can run docker as daemon
 ```
 docker-compose up -d
 ```
 and to stop the daemon:
 ```
 docker-compose stop
 ```
 ### Reset database if not exists
 ```
 docker-compose exec website bundle exec rails db:reset
 ```
 ### Enter rails console to run news scheduler
 ```
 docker-compose exec website rails console
 ```
 and run following command:
 ```
 YandexMainNewsRssService.run
 ```
 ### Run tests
 ```
 docker-compose exec website bundle exec rspec spec
 ```
 ### Got to
 ```
 http://0.0.0.0:3000
 ```
 ### Enjoy
