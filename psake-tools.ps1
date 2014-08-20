﻿.".\psake-tools-helpers.ps1"


properties {
	$config = (Get-ConfigObjectFromFile '.\build.properties.json')
	$version = Get-Version ((get-date).ToUniversalTime()) (Get-EnvironmentVariableOrDefault "BUILD_NUMBER" $null)
	$baseDirectory = (pwd).Path
}



#groups of tasks
task default -depends local
task local -depends restoreAndUpdatePackages,build,runNunitTests
task jenkins -depends runPreExtensions,restoreAndUpdatePackages,build,runNunitTests,pushMyGet,runPostExtensions


#tasks

task setAssemblyInfo {
	Get-Assemblies $baseDirectory | Update-Assemblies
}

task build -depends clean,setAssemblyInfo {
	exec { iex (Get-BuildCommand) }
}

task clean {
	exec { iex (Get-CleanCommand) }
}

task publish {
	exec { iex (Get-PublishCommand) }
}

task restoreAndUpdatePackages -depends restorePackages,updatePackages {
}

task restorePackages {
	exec { iex (Get-RestorePackagesCommand) }
}

task updatePackages {
	exec { iex (Get-UpdatePackagesCommand) }
}

task generatePackage {
    Get-ProjectsToPackage | % {
        iex (Get-GeneratePackageCommand $_)
    }
}

task pushMyGet -depends generatePackage {
	#TODO: should we check for the variables existence before?
	exec { iex (Get-PushMygetCommand $env:MYGET_API_KEY $env:MYGET_REPO_URL) }
}

task pushNuGet -depends generatePackage {
    #TODO: should we check for the variables existence before?
    exec { iex (Get-PushNugetCommand $env:NUGET_API_KEY) }
}

task installNunitRunners {
	exec { iex (Get-InstallNRunnersCommand) }
}

task runNunitTests -depends installNunitRunners {
	exec{ Invoke-NunitTests $baseDirectory }
}
task installNSpecRunners {
    exec { iex (Get-InstallNSpecCommand) }
}

task runNspecTests -depends installNSpecRunners {
    exec{ Invoke-NspecTests $baseDirectory }
}

task setUpNuget {
	New-NugetDirectory $baseDirectory
	Get-NugetBinary $baseDirectory
}

task runPreExtensions {
	Get-PreExtensions $baseDirectory | Invoke-Extensions
}

task runPostExtensions {
	Get-PostExtensions $baseDirectory | Invoke-Extensions
}

task publishDocumentation {
    exec { Publish-Documentation }
}

task publishToAppCatalog {
    exec { Publish-Catalog }
}

task publishCatalogFromGitShow {
    exec { Publish-CatalogFromGitShow }
}

task zipBaseFolder {
    $baseFolder = Split-Path (pwd) -Leaf
    Compress-Folder (pwd).Path "$baseFolder_$version.zip"
}

task zipProjects {    
    Get-ProjectsToZip  | % {
        $projectPath = (pwd).Path + "\$_\bin\$($config.configuration)" 
        Compress-Folder $projectPath "$_.$version.zip" 
    }
}

task zipFiles {
    Compress-FileList $baseDirectory
}