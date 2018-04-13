import os
import sys
from sys import argv
import os.path
from optparse import OptionParser
parser = OptionParser(usage="mail projects result ")

parser.add_option("--mailfrom", dest="mailfrom", default = False, help="Sender email,only with 126.com; must be given",  metavar="PATH")
parser.add_option("--passwd", dest="passwd",default=False, help="password; must be given ", metavar="path") 
parser.add_option("--mailto",  dest="mailto", default=False, help="recipient email;must be given ")  
parser.add_option("--subject", dest="subject", help=" subject; default=projects result",default="projects result")  
parser.add_option("--content",  dest="content", help="result stat txt file;must be given", default=False)
(options, args) = parser.parse_args()

if options.mailfrom==False or options.passwd ==False  or options.mailto ==False  or options.content ==False:
	parser.print_help()
	os._exit(0)

import os
import smtplib
smtp=smtplib.SMTP()
from email.mime.text import MIMEText

msg_from=options.mailfrom
passwd=options.passwd
msg_to=options.mailto
subject=options.subject
content=open(options.content).read()


msg=MIMEText(content)
msg['Subject'] = subject
msg['From'] = msg_from
msg['To'] = msg_to

try:
	s=smtplib.SMTP_SSL("mail.capitalbiotech.com",4653)
	s.login(msg_from, passwd)
	s.sendmail(msg_from, msg_to, msg.as_string())
	print 'Done' 
except s.SMTPException,e:
	print 'fail email'
finally:
#	s.quit()
	print 'no halt'
	os._exit(0)
