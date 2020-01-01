#!/bin/bash

## 		Module name: appbackupmodule.sh	
##		Author: Alif Amzari Mohd Azamee
##		Date: 2019-12-25
##		Dependencies: mainNcBackup.sh
##		Job retention: n/a
##		Job type: Manual
##		Version: 0.1
##		Version Control: Git
##################################################
fileName="nextcloud-appbkp"	
# Backing up Web App
echo "$(currentTime) $infostrA Creating backup of Nextcloud webapp directory..." | tee -a $logPath/ncbackup.log

if [ -w $backupAppDir ]; then
	tar -zcpf "${backupAppDir}/${fileName}_${currentDate}.tar.gz" -C "${nextcloudWebDir}" . 
	echo "$(currentTime) $infostrA Webapp directory backup completed" >> $logPath/ncbackup.log
	echo "$(currentTime) $infostrA ${fileName}_${currentDate}.tar.gz created" >> $logPath/ncbackup.log
	else
		echo "$(currentTime) ${errorStrA} Destination directory ${backupAppDir} inaccesible. Backup aborted" | tee -a $logPath/ncbackup.log
		echo "$(currentTime) ${errorStrA} Restoring main services.." | tee -a $logPath/ncbackup.log
		StartwebSvcUnit
		DisableMaintenanceMode
		echo "$(currentTime) ${errorStrA} See $logPath/ncbackup.log for more details"
		exit 1
fi

# Delete old backup if required
nrOfApBAckups=$(ls -l ${backupAppDir} | grep -c 'nextcloud-appbkp.*gz')
nAbackupToRemove=$(( ${nrOfApBAckups} - ${maxNrOfAppBackups} ))

echo "$(currentTime) $infostrA Checking number of backups available..." >> $logPath/ncbackup.log

if [ ${maxNrOfAppBackups} != 0 ]; then	
	echo "$(currentTime) $infostrA Current no of backups available ${nrOfApBAckups}" >> $logPath/ncbackup.log
	if [ ${nrOfApBAckups} -gt ${maxNrOfAppBackups} ]; then		
		echo "$(currentTime) $infostrA Max number of backup(s) is set to ${maxNrOfAppBackups}. Removing ${nAbackupToRemove} old backup(s)" >> $logPath/ncbackup.log		
		ls -t ${backupAppDir} | grep 'nextcloud-appbkp.*gz' | tail -$nAbackupToRemove |while read -r aBkpToRemove; do
			rm "${backupAppDir}/${aBkpToRemove}"
			echo "$(currentTime) $infostrA ${aBkpToRemove} - Remove" >> $logPath/ncbackup.log
			done
		else
			echo "$(currentTime) $infostrA Max number of backups is set to ${maxNrOfAppBackups} to keep. 0 backup removed" >> $logPath/ncbackup.log
	fi
	elif [ ${maxNrOfAppBackups} = 0 ]; then
		echo "$(currentTime) $infostrA Current no of backups available ${nrOfApBAckups}" >> $logPath/ncbackup.log
		echo "$(currentTime) $infostrA Max number of backups is set to \"Unlimited\". 0 backup removed" >> $logPath/ncbackup.log
fi
echo "$(currentTime) $infostrA Nextcloud webapp backup completed" | tee -a $logPath/ncbackup.log
