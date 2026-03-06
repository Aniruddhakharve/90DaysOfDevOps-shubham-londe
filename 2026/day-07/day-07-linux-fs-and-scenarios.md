# Day 07 – Linux File System Hierarchy & Scenario Practice

Aaj maine apne CentOS system par Linux file system structure explore kiya aur kuch troubleshooting scenarios practice kiye.

---

## Linux File System Hierarchy

### /

Ye Linux ka root directory hai. System ki almost har directory isi se start hoti hai.

Command used:
ls -l /

Observation:
Yahan mujhe directories dikhi jaise /bin, /etc, /home, /usr aur /var.

I would use this when system ka overall structure dekhna ho.

---

### /home

Is directory me normal users ke home folders hote hain.

Command used:
ls -l /home

Observation:
Yahan user directories store hoti hain.

I would use this jab user files ya user environment check karna ho.

---

### /root

Ye root user ka personal home directory hota hai.

Command used:
sudo ls -l /root

Observation:
Yahan root user ki files aur configs store hoti hain.

I would use this jab root level ka troubleshooting ya configuration karna ho.

---

### /etc

Is directory me system configuration files store hoti hain.

Commands used:
ls -l /etc | head  
cat /etc/hostname

Observation:
Yahan hostname, hosts aur kaafi system config files mili.

I would use this jab system settings ya service configuration check karna ho.

---

### /var/log

Is directory me system aur services ke logs store hote hain.

Command used:
ls -l /var/log

Maine ye bhi run kiya:

du -sh /var/log/* 2>/dev/null | sort -h | tail -5

Observation:
Kuch log files ka size zyada tha. Isse pata chalta hai kaunsa log zyada space le raha hai.

I would use this jab service error ya system issue troubleshoot karna ho.

---

### /tmp

Is directory me temporary files store hoti hain.

Command used:
ls -l /tmp

Observation:
Temporary files yahan create hote hain aur kabhi kabhi system reboot par clean ho jate hain.

I would use this jab temporary testing ya scripts run karni ho.

---

### /bin

Is directory me basic system commands ke binaries hote hain.

Command used:
ls -l /bin | head

Observation:
Commands jaise ls, cp, mv yahan store hote hain.

---

### /usr/bin

Is directory me user commands aur installed tools hote hain.

Command used:
ls -l /usr/bin | head

Observation:
Yahan kaafi application commands mile.

---

### /opt

Ye directory optional ya third-party software ke liye use hoti hai.

Command used:
ls -l /opt

Observation:
Kabhi kabhi manually installed applications yahan milte hain.

---

## Scenario Practice

### Scenario 1 – Service Not Starting

Step 1  
Command: systemctl status sshd  
Why: Pehle check kiya service running hai ya nahi.

Step 2  
Command: journalctl -u sshd -n 20  
Why: Logs check kiye taaki error ka reason samajh aaye.

Step 3  
Command: systemctl is-enabled sshd  
Why: Check kiya service boot ke time automatically start hogi ya nahi.

---

### Scenario 2 – High CPU Usage

Step 1  
Command: top  
Why: Live CPU aur memory usage check kiya.

Step 2  
Command: ps aux --sort=-%cpu | head -10  
Why: Kaunsa process zyada CPU use kar raha hai wo identify kiya.

---

### Scenario 3 – Finding Service Logs

Step 1  
Command: systemctl status sshd  
Why: Service ka status check kiya.

Step 2  
Command: journalctl -u sshd -n 20  
Why: Recent logs dekhe.

Step 3  
Command: journalctl -u sshd -f  
Why: Real time logs monitor kiye.

---

### Scenario 4 – File Permission Issue

Step 1  
Command: ls -l ~/backup.sh  
Why: File permissions check kiye.

Step 2  
Command: chmod +x ~/backup.sh  
Why: Script ko executable banaya.

Step 3  
Command: ./backup.sh  
Why: Script run karke verify kiya.

---

## What I Learned

Aaj mujhe Linux ke important directories ka idea mila aur ye samajh aaya ki logs, configs aur binaries kaha store hote hain.  
Scenario practice se ye bhi samajh aaya ki troubleshooting step-by-step approach se karni chahiye instead of random commands.
