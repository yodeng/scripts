#!/usr/bin/env py
#coding:utf-8
### 解析kobas中的所有数据表
import sys,sqlite3,os
## scripts.py sqlits.db1 sqlits.db2...... output_dir

reload(sys)
sys.setdefaultencoding('utf-8')

od = os.path.abspath(sys.argv[-1])
for db in sys.argv[1:-1]:
	if not db.endswith(".db"):
		continue
	db_dir = os.path.basename(db)
	try:
		os.makedirs(od + "/" + os.path.splitext(db_dir)[0])
	except:
		continue	
	print "Start parse %s file" % os.path.abspath(db)
	conn = sqlite3.connect(db)
	c = conn.cursor() 
	tables = c.execute("SELECT name FROM sqlite_master WHERE type='table';")
	for table in tables.fetchall():
		table = table[0]
		print "Start parse %s table" %table
		c.execute("SELECT * from %s" %table)
		data = c.fetchall()
		db_table = open(od + "/" + os.path.splitext(db_dir)[0] + "/" + table + ".txt","w")
		for i in data:
				i = list(i)
				i=map(str,i)
				db_table.write(" ".join(i) + "\n")
				db_table.flush()
		db_table.close()
