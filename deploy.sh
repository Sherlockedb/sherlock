#!/bin/sh

cd `dirname $0`

# bundle install
bundle exec jekyll build -d /var/www/blog
