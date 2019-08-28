# distribute-csv
Powershell Script to distribute the CSVs to the node where the VM is running.

I have a lot of small Hyper-V Cluster sites at customer coming from the old Windows Server 2008 (R2) world.
Due to backup issues (serial Backups) it was (my) best practice in the good old days to have a dedicated CSV per VM.
All those sites have a thin provisioned SAN beneath (mostly Datacore, some converged, some classic) so spacewaste is not an issue.
And, i find it well-ordered to have all VM Files on one CSV named it the same from ceiling to ground. As these are nearly static, small (~20 VMs) environments the admistrative overhead is not a problem.

But nowadays due to the automatic CSV distribuition mechanism and the fact that at backuptime a mis-placed CSV / VM ownernode will lead to redirected traffic over the clusternetwork and on these small older sites this is still 1GBit and therefor the backuptimes are horrible!

Looking around I found this nice little script on Didier Van Hoye's blog which describe the vice-versa problem from an actual point of view when u use "Pool"-CSVs and the VMs are wild spread over the cluster.
https://blog.workinghardinit.work/2015/04/07/optimizing-backups-powershell-script-to-move-all-virtual-machines-on-a-cluster-shared-volume-to-the-node-owing-that-csv/
I use this script as a base and changed it from moving the VMs to the CSV to moving the CSV to the VM.

The idea is to schedule this frequently so that when a backup happen there will be no, or less Redirected Traffic to streamline the Backupspeed

