cls
  
$Cluster = Get-Cluster
$AllCSV = Get-ClusterSharedVolume -Cluster $Cluster
  
ForEach ($CSV in $AllCSV)
{
    write-output "$($CSV.Name) is owned by $($CSV.OWnernode.Name)"
      
    #We grab the friendly name of the CSV
    $CSVVolumeInfo = $CSV | Select -Expand SharedVolumeInfo
    $CSVPath = ($CSVVolumeInfo).FriendlyVolumeName
  
    #We deal with the \ being and escape character for string parsing.
    $FixedCSVPath = $CSVPath -replace '\\', '\\'
  
    #We grab all VMs that who's owner node is different from the CSV we're working with
    #From those we grab the ones that are located on the CSV we're working with
      $VMsToMove = Get-ClusterGroup | ? {($_.GroupType –eq 'VirtualMachine') -and ( $_.OwnerNode -ne $CSV.OWnernode.Name)} | Get-VM | Where-object {($_.path -match $FixedCSVPath)}
     
    ForEach ($VM in $VMsToMove)
     {
        write-output "`tThe VM $($VM.Name) located on $CSVPath is not running on host $($CSV.OwnerNode.Name) who owns that CSV"
        write-output "`tbut on $($VM.Computername). The CSV will be migrated."
        #Live migrate that VM off to the Node that owns the CSV it resides on
        #  Move-ClusterVirtualMachineRole -Name $VM.Name -MigrationType Live -Node $CSV.OWnernode.Name 
        Move-ClusterSharedVolume -Name $CSV.Name -Node $VM.ComputerName
    }
}