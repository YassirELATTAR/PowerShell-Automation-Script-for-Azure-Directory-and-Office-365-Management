"""
The following script creates random users. In case you have your users already created, 
just remove/comment the python line in the powershell script and add your file of users 
as follows in the same directory: users_{tenant}.csv
"""

import csv
import string
import random
import sys

if len(sys.argv) != 3:
    print("Usage: python script.py tenant ipaddress")
    sys.exit(1)

#Microsoft Account in use:
tenant = sys.argv[1]

#IP of the server in use:
ipaddress = sys.argv[2]

#Headers for the CSV file:
headers = ["DisplayName", "UserPrincipalName", "Password", "UsageLocation", "LicenseAssignment"]

with open('domains.txt') as f, open(f"users_{tenant}.csv", mode="w", newline="") as file:
    writer = csv.DictWriter(file, fieldnames=headers)
    writer.writeheader()

    for mydomain in f:
        domain = mydomain.strip()
        users = []
        for i in range(499):
            # Generate random string of 5 characters
            alias = ''.join(random.choices(string.ascii_uppercase + string.digits, k=6))
            FirstName = ''.join(random.choices(string.ascii_uppercase + string.digits, k=6))
            LastName = ''.join(random.choices(string.ascii_uppercase + string.digits, k=6))
            
            #Randomly choose the name of the license:
            if i%2==0:
                new_user = {
            "DisplayName": FirstName + " " + LastName,
            "UserPrincipalName": alias+str(i)+"@"+domain,
            "Password": "psWred12swA",
            "UsageLocation": "US",
            "LicenseAssignment": "Office 365 A1 for student"}
            else:
                new_user = {
            "DisplayName": FirstName + " " + LastName,
            "UserPrincipalName": alias+str(i)+"@"+domain,
            "Password": "psWred12swA",
            "UsageLocation": "US",
            "LicenseAssignment": "Office 365 A1 for faculty"}
            #create seperate SMTPs files for the domains(each domain to be sent seperately):
            with open(f'{tenant}_SMTPS_{domain}.txt', 'a') as filecrtx:
                filecrtx.write(f"smtp.office365.com,587,{new_user['UserPrincipalName']},{new_user['Password']},{new_user['UserPrincipalName']},yes,yes,yes,{ipaddress}\n")
            
            #add the new user to the list
            users.append(new_user)
        writer.writerows(users)