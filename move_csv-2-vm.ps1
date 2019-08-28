# Original Script is from 'Working Hard In IT' 
# https://blog.workinghardinit.work/2015/04/07/optimizing-backups-powershell-script-to-move-all-virtual-machines-on-a-cluster-shared-volume-to-the-node-owing-that-csv/
# I've changed primarily the move VM to CSV to CSV to VM.

# ToDo
# 1 Text Modifications
# 2 Test on Windows Server 2012 R2
# 3 Error Handling
# 4 Change Outputs to eventlog so script can be scheduled
# 5 Handle each CSV and not only the one which have to be moved in the loop to have a more complete output
# 6 Optional: Change loop to get all VMs and handle the repective CSV to have a more complete output

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
        Write-Host "`tThe VM $($VM.Name) located on $CSVPath is not running on host $($CSV.OwnerNode.Name) who owns that CSV"
        Write-Host "`tbut on $($VM.Computername). The CSV will be migrated to $($VM.Computername)."
        Write-Host
        #Live migrate that VM off to the Node that owns the CSV it resides on
        
        #  Move-ClusterVirtualMachineRole -Name $VM.Name -MigrationType Live -Node $CSV.OWnernode.Name 
        
        Move-ClusterSharedVolume -Name $CSV.Name -Node $VM.ComputerName 
    }
}
