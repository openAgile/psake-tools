new-item (Get-Location).Path -name .nuget -type directory -force
	
$source = "http://nuget.org/nuget.exe"
$destination = (Get-Location).Path + '\.nuget\nuget.exe'
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($source, $destination)	
