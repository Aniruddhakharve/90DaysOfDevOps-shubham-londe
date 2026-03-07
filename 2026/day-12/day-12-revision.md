# Day 12 – Revision & Reflection (Days 01–11)

Aaj ka day mainly revision ke liye tha. Pichle 11 days me jo Linux fundamentals practice kiye the unhe dobara review kiya taaki concepts clear rahe aur commands yaad rahein.

------------------------------------------------------------

## Quick Revision Notes

### Day 01 – Learning Plan
Maine apna initial DevOps learning plan dobara dekha. Goals abhi bhi relevant lag rahe hain: Linux fundamentals strong karna, cloud deployment samajhna aur daily hands-on practice maintain karna.

### Day 02 – Linux Architecture
Linux system ka structure samjha jisme kernel, shell aur user space important parts hain.

### Day 03 – Command Cheat Sheet
Common commands revise kiye jaise:
ls  
cd  
ps  
top  
grep  

Ye commands troubleshooting me sabse pehle kaam aate hain.

### Day 04 – Processes & Services
System processes aur services check karne ke commands dobara run kiye.

Example commands:

ps aux | head  
systemctl status sshd  
journalctl -u sshd -n 10  

Observation: SSH service properly running thi aur logs me koi error nahi tha.

### Day 05 – Troubleshooting Drill
CPU, memory aur logs check karne ka workflow revise kiya.

Commands used:

top  
free -h  
df -h  

Ye commands system health quickly check karne me help karte hain.

### Day 06 – File Read/Write
Basic file operations revise kiye:

echo "test" >> notes.txt  
cat notes.txt  
head -n 2 notes.txt  
tail -n 2 notes.txt  

### Day 07 – File System Hierarchy
Important directories revise kiye:

/etc – configuration files  
/var/log – system logs  
/home – user directories  
/tmp – temporary files  

### Day 08 – Cloud Deployment
EC2 instance launch kiya tha aur Nginx deploy kiya tha.  
Security group me port 80 allow karna important step tha.

### Day 09 – User & Group Management
Users aur groups create karne ka workflow revise kiya.

Example commands:

sudo useradd testuser  
sudo groupadd devteam  
groups testuser  

### Day 10 – File Permissions
chmod command ka use revise kiya.

Examples:

chmod +x script.sh  
chmod 640 notes.txt  

### Day 11 – File Ownership
Ownership change karne ke commands revise kiye.

Examples:

sudo chown tokyo file.txt  
sudo chgrp developers file.txt  

------------------------------------------------------------

## Mini Self Check

### Which 3 commands save you the most time right now?

1. **ls -l**  
   File permissions aur ownership quickly check karne ke liye.

2. **top**  
   System CPU aur memory usage dekhne ke liye.

3. **systemctl status <service>**  
   Service running hai ya nahi check karne ke liye.

------------------------------------------------------------

### How do you check if a service is healthy?

Usually ye commands run karta hoon:

systemctl status nginx  
journalctl -u nginx -n 20  
ps aux | grep nginx  

In commands se service ka status, logs aur running processes pata chal jata hai.

------------------------------------------------------------

### How do you safely change ownership and permissions?

Example:

sudo chown user:group file.txt  
chmod 640 file.txt  

Isse owner aur permissions change ho jate hain bina unnecessary access diye.

------------------------------------------------------------

### Focus for the Next 3 Days

Agle kuch dino me main focus karunga:

- Linux networking commands
- System monitoring tools
- Docker basics

Ye skills DevOps workflow me bahut useful rahenge.

------------------------------------------------------------

## Key Takeaway

Pichle 11 days me Linux ke fundamentals strong hue.  
Daily practice se commands yaad rehne lage hain aur troubleshooting approach bhi clear ho rahi hai.
