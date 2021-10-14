<#
Author: Brent Lasater
https://github.com/bbaall/PowerShell

October 14, 2021

Description: Sorts the users downloads folder. More specifically it 
creates folders named after each file extension currently present in the
downloads folder (For example, if you had the following in your downloads
folder: log.txt, game.exe, document.pdf - this script would create three
new folders txt, exe, and pdf. Then log.txt would be found in the txt
folder, game.exe would be found in the exe folder, etc.

****************************
			NOTE
****************************
Only works if there is one ENABLED user on the computer
****************************
		  END NOTE
****************************

TO DO

Re-create but use read-host to get the folder path that you
would like to be sorted.
#>

<#Get the current signed-in user#>
Get-LocalUser | ForEach-Object {
if ($_.enabled){
    $currentuser = $_.name;
    }
}

<#Set path to current user's downloads folder#>    
$dpath = "C:\Users\" + $currentuser + "\Downloads\"

cd $dpath

$contents = ls

for($i=0; $i -lt $contents.length; $i++){

    $loc = Get-Location
	
	<#Extract the path from the location object - basically convert to string#>
    $loc = $loc.path
	
	<#set file path to current directory plus the file extension removing the period(.)#>
    $path = $loc + "\" + ($contents[$i].extension -replace '[.]',"")

    <#Test the folder path, if it does not exist make a folder of the file extension removing the period(.)#>
    if(!(test-path $path)){
    New-Item -Path . -Name ($contents[$i].Extension -replace '[.]','') -ItemType "directory"
        }
}

<#Move individual files to the respective, newly created extensions folder#>
for($i=0; $i -lt $contents.length; $i++){

    $currentItem = $contents[$i]
    
    <#if statement to test if the item is a folder or file - if file will move it to folder#>
    if($contents[$i].mode -ne "d-----"){
    Move-Item -Path ($dpath + ($currentItem.name)) -Destination ($dpath + ($contents[$i].extension -replace '[.]',""))
        }
    }