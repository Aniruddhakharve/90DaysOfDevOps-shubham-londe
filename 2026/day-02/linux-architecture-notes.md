\# Day 02 – Linux Architecture, Processes \& systemd



\##  Linux Architecture

Linux is mainly divided into two parts:



\*\*Application\*\*

\- It is top-most layer of the architecture

\- this is layer where user works

\- It serves as the primary interface between user and shell

\- In application layer applications run in a restricted environment called User Space

\- which is isolated from kernel



\*\*Shell\*\*

\- It is interactive way to talk to kernel 

\- It act as a bridge between the application \& kernel

\- The application uses system calls to ask the kernel for the file data



\*\*Kernel\*\*

\- Third layer of architecture 

\- It is a computer program 

\- kernel retrives the data from the hardware(hard-drive).



\*\*Hardware\*\*

\- Fourth layer of architecture 
\- The physical disk reads the data and sends it back up the stack



---



\## How processes are created and managed

\- Every running program in Linux is a process, Every time you run a cmd or start a services a new process is born
\- Every process gets a unique PID (Process ID)
\- Once the command finishes, that child process dies, and you get your prompt back
\- It is all managed by kernel 


\## Common Management Commands

\- top or htop: A real-time dashboard showing what's using the most CPU and RAM
\- ps aux: Lists all active processes on the system in detail
\- kill <PID>: Sends a signal to stop a specific process (the PID is its unique ID number)
\- nice / renice: Used to set or change a program's priority



\### Common Process States

\- Running → currently using CPU

\- Sleeping → waiting for input or resource

\- Stopped → paused

\- Zombie → finished but not cleaned from process table



---



\## What is systemd?

systemd is the service manager it is a master process called systemd (PID 1) manages services in most modern Linux systems, the only process that doesn't have a parent is PID 1 (init/systemd), which is started directly by the Linux Kernel during boot. 


\- Systemd  Starts services at boot

\- It also Stops/restarts services

\- IT Manages background services

\- IT also Keeps logs of services



Example:

nginx, docker, ssh all run as services managed by systemd.



Why it matters:

If a service crashes in production, we use systemctl to debug and restart.



---



\## Commands I will use daily

ps aux - see running processes  

top - live CPU/memory usage  

htop - better process view  

systemctl status nginx - check service status  

systemctl restart nginx - restart service  



---



\## Why this matters for DevOps

Most servers run Linux   

If a service fails or CPU becomes high then our server can crash which will lead to site or applications go down , so understanding processes and systemd helps in troubleshooting this problem quickly.

Learning this will help me debug servers and manage services in real environments.

