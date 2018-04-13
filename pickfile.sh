#!/bin/bash
#文件路径,所有者,文件大小,最后访问日期,最后访问时间
path=`readlink -f $1`
find $path -type f -size +500M -and -mtime -5 -printf '%p\t%u\t%s\t%TY%Tm%Td\t%TT\t\n'
#find $path -type f -size +1k -and -mmin -500 -exec ls -hl {} \;
