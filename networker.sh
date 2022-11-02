#!/bin/bash
CLIENT=$1
declare -a SERVER
count=0
if [ $# -eq 0 ]
then
        echo "Please supply machine name with the script, e.g. .\/find_client nke-lnx-ebr-p001"
        exit 1
fi
# This function gets the group information
getLatestBackup()
{
        BACKUP_SERVER=$1
        declare -a GROUP_NAMES
        count=0
        for i in ` printf ". type: nsr client; name: $CLIENT\n show group \n print \n" | nsradmin -s $BACKUP_SERVER -i- | grep -i group | cut -d ":" -f 2 | cut -d ";" -f 1`
       do
       START_TIME=` printf ". type: nsr group; name: $i\n show Last start \nprint\n" | nsradmin -s $BACKUP_SERVER -i- | grep -i start | cut -d "\"" -f 2`
                echo ---------------------------------------------------------------------------------------------------------------------------------
                echo Displaying backup information on  \< $BACKUP_SERVER \>  for the  the group \< $i \> last backed up on \< \"$START_TIME\" \>
                echo ---------------------------------------------------------------------------------------------------------------------------------
                echo
                echo
                mminfo -avot -s $BACKUP_SERVER -q group=$i -t "$START_TIME" | grep -i $CLIENT
                echo
                echo Hit enter to continue with the next group...
                read
                GROUP_NAMES[$count]=$i
                count=$(( $count + 1 ))
         done
}
#Find if NetWorker is on this system
hasNetWorker(){
#rpcinfo -p $CLIENT | grep -i 7937 > null 2>&1
printf ". type: nsrla\n" | nsradmin -s $CLIENT -p nsrexecd >  null 2>&1
if [ $? -eq "1" ]
then
        echo
        echo "The system $CLIENT has no NetWorker client services running, this script cannot continue"
        echo "The NetWorker services on this system might be down or this might system might not be backed up using NetWorker"
        echo
        exit 1
fi
SERVER_NAMES=`printf ".type: nsrla\n show servers\n print \n" | nsradmin -s $CLIENT -p nsrexecd -i- | grep servers|cut -d ":" -f 2 | cut -d ";" -f 1|cut -d ' ' -f 2`
for i in `printf ". type: nsr peer information\nshow name\nprint\n" | nsradmin -s $CLIENT -p nsrexecd -i- | grep -i name | cut -d ":" -f 2 | cut -d ";" -f 1`
         do
                echo $i
                printf ". type: nsr\n" | nsradmin -s $i -i- > null 2>&1
                if [ $? == 0 ]
                then
                SERVER[$count]=$i
                count=$(( $count + 1 ))
                fi
        done
        if [ ${#SERVER[@]} -gt 0 ]
           then
               for i in "${SERVER[@]}"
                do
                 getLatestBackup $i
                done
           else
              echo "Go on and try the Avamar"
        fi
}
hasNetWorker