<#
SCRIPTNAME: Store-CohesityCreds.ps1
AUTHOR: Charles Ahern (cahern@cambridgecomputer.com)
COMPANY: Selective Insurance Company
DATE: 3/26/2019
DESCRIPTION: Store Authentication Creds in Certificate Encrypted text file
MODULES: 
INPUT FILE FORMAT: Console
OUTPUT FILE FORMAT: Encrypted TXT File
CHANGELOG: 
#>

<#
Sign with Certificate created in the local user store with the following syntax:
$cert = New-SelfSignedCertificate -CertStoreLocation cert:\currentuser\my -Subject encryptcreds@selective.com -NotAfter (Get-Date).AddYears(3) -KeySpec KEYEXCHANGE -TextExtension @("2.5.29.37={text}1.3.6.1.4.1.311.80.1") -KeyLength 2048 -FriendlyName "Data Protection Cert" -KeyUsage DataEncipherment
Use the printed Thumbprint in the -To field on Protect-CmsMessage and UnProtect-CmsMessage throughout the scripts
Resulting certificate can be exported/imported to local user stores for global use, however the cert will decrypt all files it was used to encrypt
#>


$cUsername = Read-Host "Enter the Cohesity Username"
$cDomain = Read-Host "Enter the Cohesity Domain"
$cPassword = Read-Host "Enter the password" -AsSecureString
$cOutfile = Read-Host "Enter the file name to store the encrypted creds (.txt)" 

$bStr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($cPassword)
$cPwd = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bStr)

$secureCred = New-Object System.Object
$secureCred | Add-Member -MemberType NoteProperty -Name "domain" -value $cDomain
$secureCred | Add-Member -MemberType NoteProperty -Name "username" -value $cUsername
$secureCred | Add-Member -MemberType NoteProperty -Name "password" -value $cPwd
$secureCred | ConvertTo-Csv| Protect-CmsMessage -OutFile $cOutFile -To 046C4BF2BF7326A3FE6BB17A6EE5FA2B0BC41351