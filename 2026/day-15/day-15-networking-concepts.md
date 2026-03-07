# Day 15 – Networking Concepts: DNS, IP, Subnets & Ports

Aaj maine networking ke fundamental concepts revise kiye jaise DNS resolution, IP addressing, CIDR notation aur common ports jo DevOps troubleshooting me frequently use hote hain.

------------------------------------------------------------

## Task 1 – DNS (How Names Become IPs)

Jab hum browser me google.com type karte hain to sabse pehle DNS query generate hoti hai. DNS server domain name ko ek IP address me convert karta hai. Browser phir us IP address par HTTP request send karta hai aur website load hoti hai.

Common DNS Records:

A – Domain ko IPv4 address se map karta hai  
AAAA – Domain ko IPv6 address se map karta hai  
CNAME – Ek domain ko dusre domain name par point karta hai  
MX – Mail servers ke liye use hota hai  
NS – Domain ke authoritative name servers define karta hai  

Command used:

dig google.com

Observation:

Output me google.com ka **A record** aur TTL value show hoti hai.

------------------------------------------------------------

## Task 2 – IP Addressing

IPv4 address ek 32-bit address hota hai jo 4 octets me likha jata hai.

Example:

192.168.1.10

Public vs Private IP:

Public IP – Internet par globally reachable hota hai  
Example: 8.8.8.8

Private IP – Internal network me use hota hai  
Example: 192.168.1.10

Private IP ranges:

10.0.0.0 – 10.255.255.255  
172.16.0.0 – 172.31.255.255  
192.168.0.0 – 192.168.255.255

Command used:

ip addr show

Observation:

AWS instance ka IP private range me tha (example: 172.31.x.x).

------------------------------------------------------------

## Task 3 – CIDR & Subnetting

CIDR notation network prefix show karta hai.

Example:

192.168.1.0/24

Iska matlab first 24 bits network ke liye reserve hain.

Subnetting ka use network ko smaller logical networks me divide karne ke liye hota hai taaki IP management aur security better ho.

CIDR Table:

| CIDR | Subnet Mask | Total IPs | Usable Hosts |
|-----|-------------|-----------|--------------|
| /24 | 255.255.255.0 | 256 | 254 |
| /16 | 255.255.0.0 | 65536 | 65534 |
| /28 | 255.255.255.240 | 16 | 14 |

------------------------------------------------------------

## Task 4 – Ports (Doors to Services)

Port ek logical communication endpoint hota hai jisse different services same machine par run kar sakti hain.

Common Ports:

22 – SSH  
80 – HTTP  
443 – HTTPS  
53 – DNS  
3306 – MySQL  
6379 – Redis  
27017 – MongoDB  

Command used:

ss -tulpn

Observation:

System par SSH service port 22 par listening thi.

------------------------------------------------------------

## Task 5 – Putting It Together

curl http://myapp.com:8080

Is request me DNS domain ko IP me resolve karta hai, TCP connection establish hota hai aur HTTP protocol application layer par run karta hai.

Database connectivity issue:

Agar app database 10.0.1.50:3306 se connect nahi kar pa raha hai to check karunga:

Network connectivity (ping)  
Port accessibility (telnet or nc)  
Database service status

------------------------------------------------------------

## What I Learned

DNS domain names ko IP addresses me translate karta hai.  
CIDR notation network size aur host count define karta hai.  
Ports different services ko identify karne ke liye use hote hain.
