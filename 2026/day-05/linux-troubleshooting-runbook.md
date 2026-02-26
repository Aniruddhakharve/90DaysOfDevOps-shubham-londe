# Day 05 – Linux Troubleshooting Runbook

## Target Service
Is drill ke liye maine sshd service choose ki.

---

## Environment Details

Commands run kiye:
uname -a  
cat /etc/os-release  

Observation:
System CentOS par run ho raha hai. Kernel details check kiye aur environment normal lag raha hai. Koi unusual cheez nahi mili.

---

## Filesystem Sanity Check

/tmp me ek test folder create kiya aur /etc/hosts file copy ki.

Commands:
mkdir /tmp/runbook-demo  
cp /etc/hosts /tmp/runbook-demo/hosts-copy  
ls -l /tmp/runbook-demo  

Observation:
File successfully copy ho gayi. Permissions bhi normal dikhe. Filesystem me koi error ya issue nahi tha.

---

## Snapshot – CPU & Memory

Pehle sshd ka PID check kiya using pgrep.

Commands:
ps -o pid,pcpu,pmem,comm -p <PID>  
free -h  

Observation:
CPU usage kaafi low tha. Memory usage bhi stable tha. Koi abnormal spike ya heavy usage nahi dikha.

---

## Snapshot – Disk & IO

Commands:
df -h  
du -sh /var/log  

Observation:
Disk usage safe limit me tha. /var/log ka size manageable hai. Disk full hone ka koi issue nahi hai.

---

## Snapshot – Network

Commands:
ss -tulpn | grep ssh  
curl -I http://localhost  

Observation:
SSH port 22 par listening hai. Network active lag raha hai. Koi connectivity issue nahi dikha.

---

## Logs Reviewed

Commands:
journalctl -u sshd -n 50  
tail -n 50 /var/log/messages  

Observation:
Last 50 log lines me koi critical error nahi mila. Mostly normal login aur system messages the.

---

## Quick Findings

- SSH service properly running hai  
- CPU aur memory stable hai  
- Disk usage normal hai  
- Logs me koi serious error nahi mila  

Overall system healthy lag raha hai.

---

## If This Worsens (Next Steps)

1. SSH service restart karke logs dubara monitor karunga  
2. Agar issue repeat ho to logging level increase karke detailed logs check karunga  
3. Network ya firewall rules verify karunga agar connection issue badhta hai  

Is drill se mujhe samajh aaya ki pehle system ka proper health snapshot lena chahiye, bina directly restart kiye. Ye approach production me kaafi helpful hoga.
