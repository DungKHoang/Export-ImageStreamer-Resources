# Export Image Streamer resources

Export-i3sResources.ps1 is a PowerShell script that leverages HPE OneView PowerShell library and Excel to colelct information about Image Streamer resources 
Export-i3sresources.ps1 queries to OneView to collect ImageStreamer resources and save them in CSV files.

## Prerequisites
Both scripts require the latest OneView PowerShell library : https://github.com/HewlettPackard/POSH-HPOneView/releases





## Export-i3sResources.PS1 

Export-i3sResources.ps1 is a PowerShell script that exports Image Streamer resources into CSV files including:
   * OS volumes
   * Golden Images
   * Deployment plans
   * OS Build plan
   * Plan Scripts


## Syntax

### To export all resources

```
    .\Export-i3sResources.ps1 -OVApplianceIP <OV-IP-Address> -OVAdminName <Admin-name> -OVAdminPassword <password> -All

```

### To export OS volumes

```
    .\Export-i3sResources.ps1 -OVApplianceIP <OV-IP-Address> -OVAdminName <Admin-name> -OVAdminPassword <password> -i3sOSvolumeCSV c:\osvolume.csv

```
### To export Golden Images

```
    .\Export-i3sResources.ps1 -OVApplianceIP <OV-IP-Address> -OVAdminName <Admin-name> -OVAdminPassword <password> -i3sGoldenImageCSV c:\goldenimage.csv

```

### To export Deployment plan

```
    .\Export-i3sResources.ps1 -OVApplianceIP <OV-IP-Address> -OVAdminName <Admin-name> -OVAdminPassword <password> -i3sDeploymentPlanCSV c:\DeploymentPlan.csv

```

### To export OS build plan

```
    .\Export-i3sResources.ps1 -OVApplianceIP <OV-IP-Address> -OVAdminName <Admin-name> -OVAdminPassword <password> -i3sBuildPlanCSV c:\BuildPlan.csv

```

### To export plan scripts

```
    .\Export-i3sResources.ps1 -OVApplianceIP <OV-IP-Address> -OVAdminName <Admin-name> -OVAdminPassword <password> -i3sPlanScriptCSV c:\PlanScript.csv

```

### To export Artifact Bundles

```
    .\Export-i3sResources.ps1 -OVApplianceIP <OV-IP-Address> -OVAdminName <Admin-name> -OVAdminPassword <password> -i3sArtifactBundleCSV c:\ArtifactBundle.csv

```


