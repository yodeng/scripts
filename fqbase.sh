#!/bin/bash
awk '{if(NR%4==0){print length($0)}}' $1 | awk '{sum+=$0;n+=1};END{print "basecounts", sum ,"bp";print "readsnumber",n ,"seqs"}'
