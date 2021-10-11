<#
Checks network adapters, if there is a network adapter named "Ethernet"
then checks whether DNS is set statically. If DNS is statically set then
convert to dynamic/automatic.

Author: Brent Lasater

https://github.com/bbaall
#>

$ether = get-netadapter | Where-Object {$_.name -like "Ethernet"}

# Checks if the variable $ether is null (I.e. there is no network adapter named ethernet)

if (!$ether) {
	write-host "There is no network adapter named 'Ethernet'"
	Start-Sleep -s 5
	exit
}

# Set DNS to dynamic/automatic to pull information from DHCP server

else {
	$ifIndex = $ether.ifIndex
	
	Set-DnsClientServerAddress -interfaceIndex $ifIndex -ResetServerAddresses
	
	write-host "DNS settings have been set to dynamic for the network adapter" $ether.name
}
	
