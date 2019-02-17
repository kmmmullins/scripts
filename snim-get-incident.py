#Need to install requests package for python
#easy_install requests
import requests

# Set the request parameters
url = 'https://mitdev.service-now.com/api/now/table/incident_sla?sysparm_limit=10'

# Eg. User name="admin", Password="admin" for this code sample.
user = 'api-kmullins'
pwd = 'T0mpetty'

# Set proper headers
headers = {"Content-Type":"application/json","Accept":"application/json"}

# Do the HTTP request
response = requests.get(url, auth=(user, pwd), headers=headers )

# Check for HTTP codes other than 200
if response.status_code != 200: 
    print('Status:', response.status_code, 'Headers:', response.headers, 'Error Response:',response.json())
    exit()

# Decode the JSON response into a dictionary and use the data
data = response.json()
print(data)
