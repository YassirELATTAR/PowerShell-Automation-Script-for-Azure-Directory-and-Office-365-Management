Disconnect-ExchangeOnline
$login = "{Account}"
$Psswd = '{Password}'
$securString = ConvertTo-SecureString $Psswd  -AsPlainText -Force
$UserCredential = New-Object System.Management.Automation.PSCredential ($login, $securString)
Connect-ExchangeOnline -Credential $UserCredential
Connect-MsolService  -Credential $UserCredential
Connect-AzureAD  -Credential $UserCredential

$ip= "10.10.10.10"
$tenant = "{tenant}"

python createCSV.py $tenant  $ip
$counter=0


#Khalih yerta7 meskin:
Start-Sleep -Seconds 3
$users = Import-Csv -Path "users_$tenant.csv"

    #Password profile:
    $PasswordProfile = New-Object -TypeName 'Microsoft.Open.AzureAD.Model.PasswordProfile'
    $PasswordProfile.ForceChangePasswordNextLogin = $false
    #License Preparation:

    $LicenseFac = New-Object Microsoft.Open.AzureAD.Model.AssignedLicense
    $LicenseFac.SkuId = (Get-AzureADSubscribedSku | Where-Object -Property SkuPartNumber -Value 'STANDARDWOFFPACK_FACULTY' -EQ).SkuID
    $LicenseSts = New-Object Microsoft.Open.AzureAD.Model.AssignedLicense
    $LicenseSts.SkuId = (Get-AzureADSubscribedSku | Where-Object -Property SkuPartNumber -Value 'STANDARDWOFFPACK_STUDENT' -EQ).SkuID
    $Licenses = New-Object Microsoft.Open.AzureAD.Model.AssignedLicenses
    #$Licenses.AddLicenses = $License

$counter=0

foreach ($user in $users) {
    $counter++
    $PasswordProfile.Password = $user.Password

    $params = @{
        AccountEnabled = $true
        DisplayName = $user.DisplayName
        SurName = "app$counter"
        GivenName = "test$counter"
        PasswordProfile = $PasswordProfile
        UserPrincipalName = $user.UserPrincipalName
        UsageLocation = "US"
		MailNickname = "Yass_app$counter"
    }

    if ($user.LicenseAssignment -eq "Office 365 A1 for faculty")
    {
        $Licenses.AddLicenses = $LicenseFac
    }
    else {
        $Licenses.AddLicenses = $LicenseSts
    }

    #Create the user and add the license:
    Set-AzureADUserLicense -ObjectId (New-AzureADUser @params).ObjectId -AssignedLicenses $Licenses
    Write-Host -NoNewline " Created: $counter"
    Write-Host -NoNewline "`r"
}

#Khalih yzid yerta7 meskin:
Start-Sleep -Seconds 5
$counter=0
# SMTP:
$Domains = Get-Content -Path "domains.txt"
foreach ($Domain in $Domains) {
	
$allUsers = Get-MsolUser -DomainName $Domain -All
foreach ($userToAssign in $allUsers.UserPrincipalName) {
				Set-CASMailbox -Identity $userToAssign  -SmtpClientAuthenticationDisabled $false
                $counter++
        Write-Host -NoNewline " Activated SMTPS:$counter"
        Write-Host -NoNewline "`r"
}


New-MailboxFolder -Parent :\ -Name "bounceof$Domain"
New-InboxRule -Mailbox $login -Name "bouncedby$Domain" -MoveToFolder ":\bounceof$Domain" -SubjectOrBodyContainsWords $Domain

}
$counter=0

# SMTP:
#$Domains = Get-Content -Path "domains.txt"

#foreach ($Domain in $Domains) {

#$allUsers = Get-MsolUser -DomainName $Domain -All
#foreach ($userToAssign in $allUsers.UserPrincipalName) {
#				Set-CASMailbox -Identity $userToAssign  -SmtpClientAuthenticationDisabled $false
#                $counter++
#        Write-Host -NoNewline " Activated SMTPS:$counter"
#        Write-Host -NoNewline "`r"
#}
#}


$counter=0

$users = Get-Mailbox -ResultSize Unlimited -Filter {RecipientTypeDetails -eq 'UserMailbox' -and Alias -like "yass_app*"}
$users | foreach {Set-Mailbox $_.Identity -DeliverToMailboxAndForward $true -ForwardingSMTPAddress $login 
						$counter++
                        Write-Host -NoNewline " Forwarding :$counter"
						Write-Host -NoNewline "`r"
		}



$counter=0

#Disconnect-AzureAD
#Disconnect-ExchangeOnline

