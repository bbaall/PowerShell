<#
Author: Brent Lasater
https://github.com/bbaall/PowerShell

August 14, 2021

Get physical disk information (Some SMART [Self-Monitoring, Analysis, and Reporting Technology]
information). Note that not all SMART disk information is provided by PowerShell.
Some information is proprietary relative to the disk manufacturer or some SMART
information may only be available through BIOS.

This is a simple check - should run a performance monitor test to determine more
sophisticated hardware (SMART) errors.
#>

## Complicated way to get physical disk information -OR- just run get-disk

get-wmiobject Win32_LogicalDisk | ForEach-Object -process {
	if (!$_.ProviderName) {
		$pdisks = $_

        $fspace = [math]::Round($_.FreeSpace / 1Gb, 2)
        $pspace = [math]::Round(($_.FreeSpace / $_.Size)*100, 2)

        write-host The $_.DeviceID "drive has" $fspace "Gb" "("$pspace "%)" "remaining."
	}
}

## Extended information about physical disks

$smart = Get-Disk | Get-StorageReliabilityCounter

## Query through if statement to determine whether some metric has been exceeded.
## For example, says disk PowerOnHours has exceeded 3 years, then do something.
## This something could be export a log file or send an email
## that notifies someone that the disk has been running for the maximum determined
## time conceived by company policy. Some notable values that can be retrieved 
## are ManufactureDate, PowerOnHours, ReadErrorsTotal. WriteErrorsTotal, TemperatureMax.

	if ($smart.PowerOnHours -gt 26280) {
		Out-File -FilePath "C:\Logs\Physical Disk WARNING.txt" -InputObject $smart
		
		Add-Content -Path "C:\Logs\Physical Disk WARNING.txt" -Value (Get-Date)
	}

