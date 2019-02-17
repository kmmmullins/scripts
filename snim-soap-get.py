#!/usr/bin python
 
# use the SOAPpy module
from SOAPpy import SOAPProxy
 
username, password, instance = 'kmullins', 'T0mpetty', 'mitdev'
proxy, namespace = 'https://username:password@www.service-now.com/'+instance+'/incident.do?SOAP', 'https://mitdev.service-now.com/'
 
server = SOAPProxy(proxy,namespace)
response = server.getRecords(category = 'Request')
 
for record in response:
	for item in record:
		print item
