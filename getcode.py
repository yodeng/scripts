#!/usr/bin/env python
#coding:utf-8

import string,numpy,argparse

parser = argparse.ArgumentParser(description="This Script is used to get the random code")
parser.add_argument("-n","--num",type=int,help="the number length of code you want, default:10",default=10)
parser.add_argument("-s","--str",type=str,help="the extend char set you give ecxept digits and ascii_letters")
#parser.add_argument("-e","--except_str",default="oO02ZlI",type=str,help="the char set you do not want to appear in code")
parser.add_argument("-e","--except_str",type=str,help="the char set you do not want to appear in code")
parser.add_argument("--with_noreplace",action='store_false',default=True,help="Whether the char set is with or without replacement, default:with-replacement")
args = parser.parse_args()

a = string.digits + string.ascii_letters
if args.str:
    a = set(a).union(set(args.str))
if args.except_str:
    a = set(a).difference(set(args.except_str))
code = numpy.random.choice(list(set(a)),size=args.num,replace=args.with_noreplace)
print "".join(code)
