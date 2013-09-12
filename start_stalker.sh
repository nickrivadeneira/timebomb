#!/usr/bin/env bash

if [[ -s "/home/ubuntu/.rvm/environments/ruby-2.0.0-p247" ]] ; then
  source "/home/ubuntu/.rvm/environments/ruby-2.0.0-p247"
  stalk /home/ubuntu/appdev/timebomb/jobs.rb
else
  echo "ERROR: Missing RVM environment file: 'ruby-2.0.0-p247'" >&2
  exit 1
fi
