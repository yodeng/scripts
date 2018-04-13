#!/bin/bash

if [ $# -eq 0 ];then
echo 'Git push your file into "git@github.com:yodeng/scripts" Repositories'
echo "USAGE: bash gitadd.sh file1 file2 file3 ..."
exit
fi

git init
ssh -T git@github.com
#git config --global user.name "yodeng"
#git config --global user.email "393548812@qq.com"
#git remote add origin git@github.com:yodeng/scripts
git remote add origin git@github.com:yodeng/scripts || git remote rm origin;git remote add origin git@github.com:yodeng/scripts
git add $*
git commit -m "first commit"
#git push origin master || git pull origin master;git push origin master
git push origin master
