#!/bin/sh

for E in /etc/container_environment/*
do
  export ${E##*/}="`cat $E`"
done
