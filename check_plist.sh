#!/bin/sh

hostname=`hostname`
sar -q 10 3 > /tmp/${hostname}.monitor 
