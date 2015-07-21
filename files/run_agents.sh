#!/bin/bash

if [[ $1 = 'all' ]] ; then
  for node in `docker ps -q`
  do
    docker exec $node puppet agent -t
  done
elif [[ $1 = 'list' ]] ; then
  docker ps
else
    docker exec $1 puppet agent -t
fi
