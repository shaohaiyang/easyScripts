#!/usr/bin/env python
#-*- coding: iso-8859-1 -*-
import sys,smtplib,email.MIMEMultipart,email.MIMEText,email.MIMEBase,os.path
import linecache,socket,fcntl,struct
 
def get_ip_address(ifname):
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        return socket.inet_ntoa(fcntl.ioctl(
        s.fileno(),
        0x8915,  # SIOCGIFADDR
        struct.pack('256s', ifname[:15])
        )[20:24])
 
N = 0
N=int(N)

f = open('/etc/userlist.txt','rb')
w = open('/var/log/sendddos.log','ab')
ip = get_ip_address('eth0')
host = socket.gethostname()
 
Account = "service@audividi.com"
Pass = 'VidiNOW'
From = "Service<service@audividi.com>"
file_name = "/opt/nginx/conf/stoplist"
if os.path.getsize(file_name) > 0:
	string = '''
	<html>
	<body bgcolor="#baf3ba">
	<H3>DDoS Warning! [ Report from:'''+ip+''' ]</H3>
	</body>
	</html>
	'''
 
	text_msg = email.MIMEText.MIMEText(string,_subtype='html',_charset='gb2312')
	contype = 'application/octet-stream;charset="gb2312"'
	maintype,subtype = contype.split('/',1)
 
	data = open(file_name,'rb')
	file_msg = email.MIMEBase.MIMEBase(maintype,subtype)
	file_msg.set_payload(data.read())
	data.close()
	email.Encoders.encode_base64(file_msg)
 
	basename = os.path.basename(file_name)
	file_msg.add_header('Content-Disposition','attachment',filename='Fileintegrity.log')
 
	lines = f.readlines(100)
	M = len(lines)

	while N < M:
		To = lines[N].split(',')[0].strip()
		main_msg = email.MIMEMultipart.MIMEMultipart()
		main_msg.attach(text_msg)
		main_msg.attach(file_msg)
		main_msg['Subject'] = "[ "+host+" ] DDoS Report!"
		main_msg['From'] = From
 
		if To == '':
			continue
 
		Date = email.Utils.formatdate()
		main_msg['To'] = To
		main_msg['Date'] = Date
		fullText = main_msg.as_string()
	 
		String = "%-30s\t%s\t" %(To,Date)
		server = smtplib.SMTP('mail.audividi.com')
		server.rcpt(To)
	 
		try:
			print "%-30s\t%s" %(To,Date),
			server.login(Account,Pass)
			server.sendmail(From,To,fullText)
		finally:
			print "\t <- OK"
			server.quit()
		N=N+1
	f.close()
else:
	sys.exit()
