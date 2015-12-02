web: bundle exec unicorn -p $PORT -c ./config/unicorn.rb
clock: bundle exec clockwork app/clock.rb
worker: bundle exec sidekiq -e production -C config/sidekiq.yml