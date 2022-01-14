<#

Used to calculate the increase in storage used on a weekly basis.

May need to use the actual byte value to convert to GB
1 GB = 1073741824 Bytes

#>

$disks = get-wmiobject win32_LogicalDisk | ForEach-Object -process { if ((!$_.ProviderName) -and ($_.Size)) { $_ | select deviceID, size, freeSpace }}

## Convert data to a more easily readable format.
		
$disks.size = [math]::Round($disks.size / 1073741824, 2)
$disks.freespace = [math]::Round($disks.freespace / 1073741824, 2)


## Create folder to store data if the folder does not already exist

if(!(test-path C:\Free_Space_log)) {
	New-Item -Path C:\ -Name "Disk Space Log" -ItemType "directory" -errorAction silentlyContinue
}

## Add current disk data (Drive ID (e.g. C:\ or D:\) space, total space to the file data.csv

$disks | export-csv -path "C:\Disk Space Log\data.csv" -append

Start-Sleep -s 1

$evaluationData = import-csv -path "C:\Disk Space Log\data.csv"

## Requires two data points to calculate an average
if (!($evaluationData[1])) {
	exit
}

## Subtracts the N data point (presumably the larger data point, but this can be smaller)
## from the N+1 data point. Average change per time unit (using a scheduled task per day or week, 
## the time unit can be of your own choosing

for(($i = 0); $i -lt ($evaluationData.length - 1); $i++) {
	
	$total += ($evaluationData.freeSpace[$i] - $evaluationData.freeSpace[$i + 1])
	
}

$averageUsage = [math]::Round(($total / ($evaluationData.length)), 2)

## freeSpace divided by averageUsage to determine the amount of time units remaining until
## the drive will be filled ON AVERAGE

$timeRemaining = $evaluationData[($evaluationData.length) - 1].freeSpace / $averageUsage

if (!(test-Path -path "C:\Disk Space Log\Log.txt")) {
	new-Item -Path "C:\Disk Space Log" -name Log.txt -ItemType "file"
}

$resultsText = (Get-Date), ($evaluationData[($evaluationData.length) - 1].freeSpace), "gigabytes of free space remaining. Time remaining until hard drive is full", [math]::Round($timeRemaining, 1), ' '

add-Content -Path "C:\Disk Space Log\Log.txt" -Value $resultsText

write-host "You have" ([math]::Round($evaluationData[($evaluationData.length) - 1].freeSpace, 2)) "gigabytes of free space remaining. Time remaining until hard drive is full:" ([math]::Round($timeRemaining, 1)) "days."
