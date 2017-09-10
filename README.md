# Export Image Streamer resources

Export-i3SResources.ps1 is a PowerShell script that leverages HPE OneView PowerShell library and Excel to colelct information about Image Streamer resources 
Export-i3Sresources.ps1 queries to OneView to collect ImageStreamer resources and save them in CSV files.

## Prerequisites
Both scripts require the latest OneView PowerShell library : https://github.com/HewlettPackard/POSH-HPOneView/releases





## Export-i3SResources.PS1 

Export-i3SResources.ps1 is a PowerShell script that exports Image Streamer resources into CSV files including:
   * OS volumes
   * Deployment plans
   * OS Build plan
   * Plan Scripts


## Syntax

### To export all resources

```
    .\Export-i3SResources.ps1 -OVApplianceIP <OV-IP-Address> -OVAdminName <Admin-name> -OVAdminPassword <password> -All

```

### To export OS volumes

```
    .\Export-i3SResources.ps1 -OVApplianceIP <OV-IP-Address> -OVAdminName <Admin-name> -OVAdminPassword <password> -i3SOSvolumeCSV c:\osvolume.csv

```

### To export Deployment plan

```
    .\Export-i3SResources.ps1 -OVApplianceIP <OV-IP-Address> -OVAdminName <Admin-name> -OVAdminPassword <password> -i3SDeploymentPlanCSV c:\DeploymentPlan.csv

```

### To export OS build plan

```
    .\Export-i3SResources.ps1 -OVApplianceIP <OV-IP-Address> -OVAdminName <Admin-name> -OVAdminPassword <password> -i3SBuildPlanCSV c:\BuildPlan.csv

```

### To export plan scripts

```
    .\Export-i3SResources.ps1 -OVApplianceIP <OV-IP-Address> -OVAdminName <Admin-name> -OVAdminPassword <password> -i3SPlanScriptCSV c:\PlanScript.csv

```




