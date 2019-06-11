# Initial GlobaliD Registrar [![CircleCI](https://circleci.com/gh/sethherr/registrar_rails/tree/master.svg?style=svg)](https://circleci.com/gh/sethherr/registrar_rails/tree/master)

Containerized with [starter](https://cloud66.com/starter)

#### Webpacker

We're using [webpacker](https://github.com/rails/webpacker). Look in `app/webpacks` for javascript

Articles used as reference: https://medium.com/@coorasse/goodbye-sprockets-welcome-webpacker-3-0-ff877fb8fa79

#### Caching

We use [readthis](https://github.com/sorentwo/readthis) to cache in redis.

Toggle caching in development mode with `rails dev:cache`

#### Secrets/credentials

We use Rails 5's [encrypted credentials](https://medium.com/cedarcode/rails-5-2-credentials-9b3324851336) (or checkout the [DHH PR](https://github.com/rails/rails/pull/30067)). Credentials are stored in [config/credentials.yml.enc](config/credentials.yml.enc) and are encrypted with a master key. For local development, add the master key to `config/master.key` - on production the value is stored in the environmental variable `RAILS_MASTER_KEY`

Edit the credentials with `rails credentials:edit`
