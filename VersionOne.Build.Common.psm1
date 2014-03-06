
function Get-EnvironmentVariableOrDefault([string] $variable, [string]$default){		
	if([Environment]::GetEnvironmentVariable($variable))
	{
		return [Environment]::GetEnvironmentVariable($variable)
	}
	else
	{
		return $default
	}
}

function New-NugetDirectory(){
	new-item (Get-Location).Path -name .nuget -type directory -force
}

function Get-NugetBinary (){	
	$source = "http://nuget.org/nuget.exe"
	$destination = (Get-Location).Path + '\.nuget\nuget.exe'
	$wc = New-Object System.Net.WebClient
	$wc.DownloadFile($source, $destination)
	#Invoke-WebRequest $source -OutFile $destination
}

function Write-AssemblyInfo($version,$organizationName){
	$files = Get-ChildItem -r -filter AssemblyInfo.cs
	if($files -ne $null)
	{
		foreach($f in $files) {		
			$componentName = Get-CSharpComponentName $f.fullname
			$template = Get-CSharpAssemblyInfoTemplate $version $organizationName $componentName			
			Set-Content -Path $f.fullname -Value $template
		}
	}
	
	$files = Get-ChildItem -r -filter AssemblyInfo.fs
	if($files -ne $null)
	{
		foreach($f in $files) {		
			$componentName = Get-FSharpComponentName $f.fullname		
			$template = Get-FSharpAssemblyInfoTemplate $version $organizationName $componentName
			Set-Content -Path $f.fullname -Value $template
		}
	}
	
}

function Get-CSharpComponentName($fullPath){	
	$pattern = '([a-zA-Z\.])*?(?=\\Properties\\AssemblyInfo.cs)'
	$result = ($fullPath | Select-String -Pattern $pattern -allmatches).matches		
	return $result.value
}

function Get-FSharpComponentName($fullPath){	
	$pattern = '([a-zA-Z\.])*?(?=\\Properties\\AssemblyInfo.fs)'
	$result = ($fullPath | Select-String -Pattern $pattern -allmatches).matches	
	return $result.value
}

function Get-CSharpAssemblyInfoTemplate(
	[string]$version, 
	[string]$organizationName, 
	[string]$componentName ){
	
return @"
using System;
using System.Reflection;
using System.Resources;
using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;

[assembly: AssemblyVersion("$version")]
[assembly: AssemblyFileVersion("$version")]
[assembly: AssemblyCompany("$organizationName")]
[assembly: AssemblyDescription("$componentName")]

"@
}

function Get-FSharpAssemblyInfoTemplate(
	[string]$version, 
	[string]$organizationName, 
	[string]$componentName ){
	
return @"
module AssemblyInfo

open System.Reflection

[<assembly: AssemblyVersion("$version")>]
[<assembly: AssemblyFileVersion("$version")>]
[<assembly: AssemblyCompany("$organizationName")>]
[<assembly: AssemblyDescription("$componentName")>]

do ()
"@
}