# Day 03 – Linux Commands Cheat Sheet

This is my personal Linux command cheat sheet.  
These are the commands I keep using during practice and troubleshooting.

---

## File System Commands

pwd – current directory kaha hai woh show karta hai  
ls – files and folders list karta hai  
ls -l – detailed listing with permissions  
cd /path – directory change karne ke liye  
mkdir folder – new folder create karne ke liye  
touch file.txt – empty file create karta hai  
cp file1 file2 – file copy karta hai  
mv file1 file2 – rename ya move karta hai  
rm file.txt – file delete karta hai  
rm -r folder – folder delete karta hai  
find / -name file – file search karne ke liye  
du -sh * – folder size check karne ke liye  
df -h – disk space usage dekhne ke liye  

---

## Process Management Commands

ps aux – system me chal rahe processes show karta hai  
top – live CPU aur memory usage show karta hai  
htop – interactive process viewer  
kill PID – specific process stop karne ke liye  
kill -9 PID – forcefully process kill karta hai  
pgrep nginx – process ka PID find karne ke liye  
uptime – system kitne time se running hai  
free -h – memory usage check karta hai  

---

## Service Management (systemd)

systemctl status nginx – service status check karne ke liye  
systemctl start nginx – service start karta hai  
systemctl stop nginx – service stop karta hai  
systemctl restart nginx – service restart karta hai  
journalctl -xe – service logs check karne ke liye  

---

## Networking Commands

ip addr – IP address check karne ke liye  
ping google.com – network connectivity test karne ke liye  
curl google.com – HTTP request test karne ke liye  
ss -tulnp – open ports check karta hai  
dig google.com – DNS lookup karta hai  

---

## Log & File Viewing Commands

cat file – file content show karta hai  
less file – large file read karne ke liye  
tail -f file – live logs dekhne ke liye  
head file – first few lines show karta hai  
grep word file – file me word search karne ke liye  

---

## Permission Related Commands

chmod 755 file – file permission change karta hai  
chown user:user file – file owner change karta hai  
umask – default permission check karta hai  

These are the commands I will practice daily so that I become comfortable working in Linux terminal and can troubleshoot faster.
