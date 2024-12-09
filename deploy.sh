#!/bin/sh

cd `dirname $0`

# bundle install
GIT_SSH_COMMAND="ssh -i /etc/webhook/rsa_key/git_rsa" git pull origin gh-pages
JEKYLL_ENV=production bundle exec jekyll build -d /var/www/blog
