﻿## -------------------------------------------------------------------------------------------------------------
##
##
##      Description: Export
##
## DISCLAIMER
## The sample scripts are not supported under any HPE standard support program or service.
## The sample scripts are provided AS IS without warranty of any kind. 
## HP further disclaims all implied warranties including, without limitation, any implied 
## warranties of merchantability or of fitness for a particular purpose. 
##
##    
## Scenario
##     	Export OneView resources
##	
## Description
##      The script export OneView resources to CSV files    
##		
##
## Input parameters:
##         OVApplianceIP                      = IP address of the OV appliance
##		   OVAdminName                        = Administrator name of the appliance
##         OVAdminPassword                    = Administrator's password
##
##         i3sOSvolumeCSV                     = Path to the CSV file containing OS Volumes definition
##         i3sDeploymentPlanCSV               = Path to the CSV file containing Deployment Plans definition
##         i3sBuildPlanCSV                    = Path to the CSV file containing Build Plans definition
##         i3sPlanScriptCSV                   = Path to the CSV file containing Plan Scripts definition
##
##
##         All                                = if present, the script will export all resources into CSv files ( default names will be used)
##
## History: 
##          Aug 2017         - First release
##
##   Version : 3.1
##
##   Version : 3.1 - August 2017
##
## Contact : Dung.HoangKhac@hpe.com
##
##
## -------------------------------------------------------------------------------------------------------------
<#
  .SYNOPSIS
     Export resources to OneView appliance.
  
  .DESCRIPTION
	 Export resources to OneView appliance.
        
  .EXAMPLE

    .\ Export-i3sResources.ps1  -OVApplianceIP 10.254.1.66 -OVAdminName Administrator -password P@ssword1 -i3sOSvolumeCSV  .\OSvolume.csv 
        The script connects to the OneView appliance and exports Image Streamer OS volumes to the OSvolume.csv file

    .\ Export-i3sResources.ps1  -OVApplianceIP 10.254.1.66 -OVAdminName Administrator -password P@ssword1 -i3sDeploymentPlanCSV  .\deploymentplan.csv 
        The script connects to the OneView appliance and exports Image Streamer Deployment plans to the deploymentplan.csv file

     .\ Export-i3sResources.ps1  -OVApplianceIP 10.254.1.66 -OVAdminName Administrator -password P@ssword1 -i3sBuildPlanCSV  .\buildplan.csv 
        The script connects to the OneView appliance and exports Image Streamer build plans to the buildplan.csv file

     .\ Export-i3sResources.ps1  -OVApplianceIP 10.254.1.66 -OVAdminName Administrator -password P@ssword1 -i3sBuildPlanCSV  .\planscript.csv 
        The script connects to the OneView appliance and exports Image Streamer  plan script to the planscript.csv file
    
    
     .\ Export-i3sResources.ps1  -OVApplianceIP 10.254.1.66 -OVAdminName Administrator -password P@ssword1 -i3sArtifactBundleCSV  .\artifactbundle.csv 
        The script connects to the OneView appliance and exports Image Streamer  artifact bundles to the planscript.csv file
    
    .\ Export-i3sResources.ps1  -OVApplianceIP 10.254.1.66 -OVAdminName Administrator -password P@ssword1 -All
        The script connects to the OneView appliance and exports Image Streamer  resources to the planscript.csv file

  .PARAMETER OVApplianceIP                   
    IP address of the OV appliance

  .PARAMETER OVAdminName                     
    Administrator name of the appliance

  .PARAMETER OVAdminPassword                 
    Administrator s password

  .PARAMETER All
    if present, export all resources

  .PARAMETER i3sOSvolumeCSV
    Path to the CSV file containing OS Volumes definition

  .PARAMETER i3sGoldenImageCSV
    Path to the CSV file containing Golden Images definition
    
  .PARAMETER i3sDeploymentPlanCSV
    Path to the CSV file containing Deployment Plans definition

  .PARAMETER i3sBuildPlanCSV
    Path to the CSV file containing Build Plans definition
  
  .PARAMETER i3sPlanScriptCSV
    Path to the CSV file containing Plan Scripts definition

  .PARAMETER i3sGoldenImageCSV
     Path to the CSV file containing Artifact Bundles definition

  .PARAMETER OneViewModule
    Module name for POSH OneView library.
	
  .PARAMETER OVAuthDomain
    Authentication Domain to login in OneView.

  .Notes
    NAME:  Export-i3sResources
    LASTEDIT: 01/11/2017
    KEYWORDS: OV  Export
   
  .Link
     Http://www.hpe.com
 
 #Requires PS -Version 5.0
 #>
  
## -------------------------------------------------------------------------------------------------------------

Param ( 
[string]$OVApplianceIP          = "", 
[string]$OVAdminName            = "Administrator", 
[string]$OVAdminPassword        = "password",
[string]$OVAuthDomain           = "local",

[switch]$All,

[string]$i3sOSvolumeCSV         =  "",                                               
[string]$i3sDeploymentPlanCSV   =  "",
[string]$i3sBuildPlanCSV        =  "",                                                     
[string]$i3sPlanScriptCSV       =  "",
[string]$i3sGoldenImageCSV      =  "",
[string]$i3sArtifactBundleCSV   =  "",


[string]$OneViewModule        = "HPOneView.310"

)

$DoubleQuote    = '"'
$CRLF           = "`r`n"
$Delimiter      = "\"   # Delimiter for CSV profile file
$Sep            = ";"   # USe for multiple values fields
$SepChar        = '|'
$LF             = "`r"
$OpenDelim      = "={"
$CloseDelim     = "}" 
$CR             = "`n"
$Comma          = ','
$Equal          = '='

$HexPattern     = "^[0-9a-fA-F][0-9a-fA-F]:"


# ------------------ Headers

$OSvolumeHeader              = "OSvolume,Size(GiB),ProfileName"
$GoldenImageHeader           = "Name,Size(GiB),BuildPlanName"

$DeploymentPlanHeader        = "Name,Description,State,BuildPlan,GoldenImage,CustomAttributes"
$BuildPlanHeader             = "Name,Description,Type,Steps"
$PlanScriptHeader            = "Name,Description,Type,Content,CustomAttributes"
$ArtifactBundleHeader        = "Name,Description,Content"







#------------------------------------
# Image Streamer (i3s) Management
#------------------------------------

[String]$OSvolumesUri                  = '/rest/os-volumes/' 
[String]$ArtifactBundlesUri            = '/rest/artifact-bundles/'
[String]$DeploymentPlansUri            = '/rest/deployment-plans/'
[String]$GoldenImagesUri               = '/rest/golden-images/'
[String]$BuildPlansUri                 = '/rest/build-plans/'
[String]$PlanScriptsUri                = '/rest/plan-scripts/'

$script:headers                        = @{}
$script:i3sip                          = ""

## -------------------------------------------------------------------------------------------------------------
##
##                     Function Get-Script-Directory
##
## -------------------------------------------------------------------------------------------------------------
function Get-Script-Directory
{
    $scriptInvocation = (Get-Variable MyInvocation -Scope 1).Value
    return Split-Path $scriptInvocation.MyCommand.Path
}


## -------------------------------------------------------------------------------------------------------------
##
##                     Function Get-i3s IP and Update headers 
##
## -------------------------------------------------------------------------------------------------------------

Function Get-i3sip_Headers
{
    if ($global:ApplianceConnection)
    {
        ## GEt IP address
        $ThisDeploymentServer = Get-HPOVOSDeploymentServer
        if ($ThisDeploymentServer)
        {
                $script:i3sip  =  $ThisDeploymentServer.primaryIPv4

        }

        # Update headers
        $script:headers["X-API-Version"] = "300"
        $script:headers["Auth"]          = $global:ApplianceConnection.SessionID

        # Add this step below to avoid authentication warnings
        add-type -TypeDefinition  @"
        using System.Net;
        using System.Security.Cryptography.X509Certificates;
        public class TrustAllCertsPolicy : ICertificatePolicy {
            public bool CheckValidationResult(
                ServicePoint srvPoint, X509Certificate certificate,
                WebRequest request, int certificateProblem) {
                return true;
            }
        }
"@
    [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

    }
    else 
    {
        write-host -ForegroundColor YELLOW " There is no OneView session established. Please log in to OneView..."
        $i3sip          = ""
        $script:headers = @{}

    }



}

## -------------------------------------------------------------------------------------------------------------
##
##                     Function Export-i3sOSvolume
##
## -------------------------------------------------------------------------------------------------------------
Function Export-i3sOSvolume([string]$OutFile)  
{
    $httpsi3s      = "https://$script:i3sip"
    $ThisUri       = $httpsi3s + $OsvolumesUri
    $ValuesArray   = @()

    try 
    {
        $res            = invoke-RestMethod -Uri $ThisUri -Headers $script:headers -Method GET 
        $ListOSVolumes  = $res.members
        foreach ($vol in $ListOSVolumes)
        {
            $volname     = $vol.name
            $volSize     = "{0:N2}" -f $($vol.Size / 1000000000)

            $Profilename = ""
            $Profileuri  = $httpsi3s + $vol.statelessServerUri + "/"

            try
            {
                $res         = invoke-RestMethod -Uri $Profileuri -Headers $script:headers -Method GET 
                $Profilename = $res.serverProfileName
            }
            catch 
            {
                write-host -foreground YELLOW " Error in invoke-restmethod to get server profile ....."
            }
            
                            #"OSvolume,Size(GiB),ProfileName"
            $ValuesArray += "$volName,$volSize,$ProfileName" + $CR
        

        }

        
        if ($ValuesArray -ne $NULL)
        {
            $a= New-Item $OutFile  -type file -force
            Set-content -Path $OutFile -Value $OSvolumeHeader
            Add-content -path $OutFile -Value $ValuesArray

        }
    } 
    catch 
    {
        write-host -foreground YELLOW "OSVolume: Error in invoke-restmethod calling $ThisUri ....."

    }


     
}


## -------------------------------------------------------------------------------------------------------------
##
##                     Function Export-i3sGoldenImage
##
## -------------------------------------------------------------------------------------------------------------
Function Export-i3sGoldenImage([string]$OutFile)  
{
    $httpsi3s      = "https://$script:i3sip"
    $ThisUri       = $httpsi3s + $GoldenImagesUri
    $ValuesArray   = @()

    try 
    {
        $res               = invoke-RestMethod -Uri $ThisUri -Headers $script:headers -Method GET 
        $ListGoldenImages  = $res.members
        foreach ($gi in $ListGoldenImages)
        {
            $GIname             = $gi.name
            $GIsize             = "{0:N2}" -f ($gi.Size / 1000000000)
            $GIBuildPlanname    = $gi.BuildPlanName


            
                            #"Name,Size(GiB),BuildPlanName"
            $ValuesArray += "$GIname,$GIsize,$GIBuildPlanname" + $CR
        

        }

        
        if ($ValuesArray -ne $NULL)
        {
            $a= New-Item $OutFile  -type file -force
            Set-content -Path $OutFile -Value $GoldenImageHeader
            Add-content -path $OutFile -Value $ValuesArray

        }
    } 
    catch 
    {
        write-host -foreground YELLOW "OSVolume: Error in invoke-restmethod calling $ThisUri ....."

    }


     
}

## -------------------------------------------------------------------------------------------------------------
##
##                     Function Export-i3sDeploymentPlan
##
## -------------------------------------------------------------------------------------------------------------
Function Export-i3sDeploymentPlan([string]$OutFile)  
{
    $httpsi3s      = "https://$script:i3sip"
    $ThisUri       = $httpsi3s + $DeploymentPlansUri 
    $ValuesArray   = @()

    try 
    {
        $res              = invoke-RestMethod -Uri $ThisUri -Headers $script:headers -Method GET 
        $ListDeployPlans  = $res.members
        foreach ($DP in $ListDeployPlans)
        {
            $DPname         = $DP.name
            $DPstate        = $DP.state
            $DPdescription  = $DP.description -replace $CR, $LF -replace $Comma, $Equal            # Replace comma with equal as comma is delimiter in CSV
            $goldenImageUri = $DP.goldenImageUri
            $BuildPlanUri   = $DP.oeBuildPlanUri

            $DPgoldenImage  = ""
            if ($goldenImageUri)
            {
              $goldenImageUri = $httpsi3s + $goldenImageUri + "/"
              try
              {
                  $res           = invoke-RestMethod -Uri $goldenImageUri -Headers $script:headers -Method GET 
                  $DPgoldenImage = $res.name
              }
              catch 
              {
                  write-host -foreground YELLOW " Error in invoke-restmethod to get Golden Image ....."
              }
            }



            $DPbuildPlan   = ""
            if ($BuildPlanUri)
            {
              $BuildPlanUri = $httpsi3s + $BuildPlanUri + "/"
              try
              {
                  $res           = invoke-RestMethod -Uri $BuildPlanUri -Headers $script:headers -Method GET 
                  $DPDeployPlan  = $res.name
              }
              catch 
              {
                  write-host -foreground YELLOW " Error in invoke-restmethod to get Deployment Plan....."
              }
            }

            #"Name,Description,State,BuildPlan,GoldenImage,CustomAttributes"
            $ValuesArray += "$DPname,$DPdescription,$DPstate,$DPbuildPlan,$DPgoldenImage,<TBD>" + $CR
        }

        if ($ValuesArray -ne $NULL)
        {
            $a= New-Item $OutFile  -type file -force
            Set-content -Path $OutFile -Value $DeploymentPlanHeader
            Add-content -path $OutFile -Value $ValuesArray

        }
    }
    catch 
    {
        write-host -foreground YELLOW "Deployment Plan : Error in invoke-restmethod calling $ThisUri ....."

    }

}    

## -------------------------------------------------------------------------------------------------------------
##
##                     Function Export-i3sBuildPlan
##
## -------------------------------------------------------------------------------------------------------------
Function Export-i3sBuildPlan([string]$OutFile)  
{
    $httpsi3s      = "https://$script:i3sip"
    $ThisUri       = $httpsi3s + $BuildPlansUri 
    $ValuesArray   = @()

    try 
    {
        $res              = invoke-RestMethod -Uri $ThisUri -Headers $script:headers -Method GET 
        $ListBuildPlans   = $res.members
        foreach ($BP in $ListBuildPlans)
        {
            $BPname         = $BP.name
            $BPType         = $BP.oeBuildPlanType
            $BPdescription  = $BP.description -replace $CR, $LF -replace $Comma, $Equal            # Replace comma with equal as comma is delimiter in CSV
            $buildstep      = $BP.BuildStep

            $PLArray        = @()
            if ($buildstep)
            {
              foreach ($seq in $buildstep)
              {
                  $plUri    = $seq.planScripturi
                  $plStep   = $seq.serialNumber
                  #$plparams = $seq.parameters

                  $plName   = ""
                  if ($plUri)
                  {
                      $plUri    = $httpsi3s + $plUri + "/"
                      try
                      {
                          $res           = invoke-RestMethod -Uri $plUri -Headers $script:headers -Method GET 
                          $plName        = $res.name
                          $Sequence      = " $plStep = $plName "
                          $PLArray      += $Sequence

                      }
                      catch 
                      {
                          write-host -foreground YELLOW " Build Plan : Error in invoke-restmethod to get Plan script ....."
                      }     
                  }
              }
            }

            if ($PLArray)
            {
              $BPsequence   = $PLArray -join $LF
            }




            

            #"Name,Description,Type,Steps"
            $ValuesArray += "$BPname,$BPdescription,$BPType,$BPSequence" + $CR
        }

        if ($ValuesArray -ne $NULL)
        {
            $a= New-Item $OutFile  -type file -force
            Set-content -Path $OutFile -Value $BuildPlanHeader
            Add-content -path $OutFile -Value $ValuesArray

        }
    }
    catch 
    {
        write-host -foreground YELLOW "Build Plan : Error in invoke-restmethod calling $ThisUri ....."

    }

} 

## -------------------------------------------------------------------------------------------------------------
##
##                     Function Export-i3sPlanScript
##
## -------------------------------------------------------------------------------------------------------------
Function Export-i3sPlanScript([string]$OutFile)  
{
    $httpsi3s      = "https://$script:i3sip"
    $ThisUri       = $httpsi3s + $PlanScriptsUri 
    $ValuesArray   = @()


    try 
    {
        $res              = invoke-RestMethod -Uri $ThisUri -Headers $script:headers -Method GET 
        $ListPlanScripts  = $res.members

        # Configure Scripts folder and zip file
        $ScriptFolder    = "$script:ThisPath\PlanScripts"
        if (-not (Test-Path $ScriptFolder))
        {   md $ScriptFolder  | out-NULL }
        $ScriptZip       = new-item "$script:ThisPath\PlanScripts.zip" -type File -force

        foreach ($PS in $ListPlanScripts)
        {
            $PSname         = $PS.name
            $PSType         = $PS.PlanType
            $PSdescription  = $PS.description -replace $CR, $LF -replace $Comma, $Equal            # Replace comma with equal as comma is delimiter in CSV
            
            $content        = $PS.content
            $ContentFile    = "$ScriptFolder\$PSName" + ".txt"

            Out-File -FilePath $ContentFile -InputObject $PS.content 
            Compress-Archive -update -path $ContentFile -DestinationPath  $ScriptZip 

            
            $PScontent      = " See file $ContentFile in  $ScriptZip  "

            #"Name,Description,Type,Content,CustomAttributes"
            $ValuesArray += "$PSname,$PSdescription,$PSType,$PSContent,<TBD>" + $CR
        }

        if ($ValuesArray -ne $NULL)
        {
            $a= New-Item $OutFile  -type file -force
            Set-content -Path $OutFile -Value $PlanScriptHeader
            Add-content -path $OutFile -Value $ValuesArray

        }
    }
    catch 
    {

        write-host -foreground YELLOW "Plan Script : Error in invoke-restmethod calling $ThisUri ....."

    }

} 

## -------------------------------------------------------------------------------------------------------------
##
##                     Function Export-i3sArtifactBundle
##
## -------------------------------------------------------------------------------------------------------------
Function Export-i3sArtifactBundle([string]$OutFile)  
{
    $httpsi3s      = "https://$script:i3sip"
    $ThisUri       = $httpsi3s + $ArtifactBundlesUri 
    $ValuesArray   = @()
$ThisUri

    try 
    {
        $res                  = invoke-RestMethod -Uri $ThisUri -Headers $script:headers -Method GET 
        $ListArtifactBundles  = $res.members

        foreach ($AB in $ListArtifactBundles)
        {
            $ABname         = $AB.name
            $ABdescription  = $AB.description -replace $CR, $LF -replace $Comma, $Equal            # Replace comma with equal as comma is delimiter in CSV
       
            $ABzipFile     = "$script:ThisPath\$ABName.zip"
            $downloadURI   = $AB.downloadURI
            
            $ThisUri       = "$httpsi3s$downloadURI"

            try 
            {
                invoke-webrequest -URI $ThisUri -headers $script:headers -outfile $ABzipFile
            }
            catch 
            {
                write-host -foreground YELLOW "Artifact Bundle : Error in invoke-restmethod calling $ThisUri ....."
            }
            

 $ABname           
           

            #"Name,Description,Content"
            $ValuesArray += "$ABname,$ABdescription,$ABzipFile" + $CR
        }

        if ($ValuesArray -ne $NULL)
        {
            $a= New-Item $OutFile  -type file -force
            Set-content -Path $OutFile -Value $ArtifactBundleHeader
            Add-content -path $OutFile -Value $ValuesArray

        }
    }
    catch 
    {

        write-host -foreground YELLOW "Artifact-bundle : Error in invoke-restmethod calling $ThisUri ....."

    }

} 


# ---------------- Connect to OneView appliance

        write-host -foreground Cyan "$CR Connect to the OneView appliance..."
        $global:ApplianceConnection =  Connect-HPOVMgmt -appliance $OVApplianceIP -user $OVAdminName -password $OVAdminPassword  -AuthLoginDomain $OVAuthDomain

        # Get i3sP IP and update headers
        Get-i3sip_Headers

        # CSV folder
        $script:ThisPath        =  Get-Script-Directory
        $CSVFolder              = "$script:ThisPath\CSV" 
        

        if (-not (Test-Path $CSVFolder))
            {   md $CSVFolder | out-NULL }

        

        if ($All)
        {
            $i3sosVolumeCSV                        = "$CSVFolder\OSVolume.csv"
            $i3sGoldenImageCSV                     = "$CSVFolder\GoldenImage.csv"
            $i3sdeploymentPlanCSV                  = "$CSVFolder\DeploymentPlan.csv"
            $i3sbuildPlanCSV                       = "$CSVFolder\BuildPlan.csv"
            $i3sPlanScriptCSV                      = "$CSVFolder\Planscript.csv"
            $i3sArtifactBundleCSV                  = "$CSVFolder\ArtifactBundle.csv"
                  
        }  
            

        # ------------------------------ 

        if ($i3sosVolumeCSV)
        { 
                write-host -ForegroundColor Cyan "Exporting Image Streamer OS volumes to CSV file --> $i3sosVolumeCSV " 
                Export-i3sosVolume        -OutFile $i3sosVolumeCSV 
        }

        if ($i3sDeploymentPlanCSV)
        { 
                write-host -ForegroundColor Cyan "Exporting Deployment Plans to CSV file --> $i3sDeploymentPlanCSV " 
                Export-i3sDeploymentPlan       -OutFile $i3sDeploymentPlanCSV
        }

        if ($i3sBuildPlanCSV)
        { 
                write-host -ForegroundColor Cyan "Exporting Build Plans to CSV file --> $i3sbuildPlanCSV " 
                Export-i3sBuildPlan       -OutFile $i3sBuildPlanCSV
        }

        if ($i3sPlanScriptCSV)
        { 
                write-host -ForegroundColor Cyan "Exporting Plan Scripts to CSV file --> $i3sPlanScriptCSV " 
                Export-i3sPlanScript       -OutFile $i3sPlanScriptCSV
        
        }

        if ($i3sGoldenImageCSV)
        { 
                write-host -ForegroundColor Cyan "Exporting Image Streamer Golden Images to CSV file --> $i3sGoldenImageCSV " 
                Export-i3sGoldenImage        -OutFile $i3sGoldenImageCSV
        }

         
        if ($i3sArtifactBundleCSV)
        { 
                write-host -ForegroundColor Cyan "Exporting Image Streamer Artifact Bundles to CSV file --> $i3sArtifactBundleCSV " 
                Export-i3sArtifactBundle        -OutFile $i3sArtifactBundleCSV
        }
        write-host -foreground Cyan "$CR Disconnect from the OneView appliance..."
        Disconnect-HPOVMgmt

