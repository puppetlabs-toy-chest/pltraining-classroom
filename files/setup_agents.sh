#!/bin/bash

for node in `docker ps | awk '{print $12}' | grep -v '^$'`
do
docker exec $node puppet agent -t
done
