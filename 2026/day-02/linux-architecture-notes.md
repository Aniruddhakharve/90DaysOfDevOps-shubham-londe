# Day 02 – Linux Architecture, Processes & systemd

## Linux Architecture

Linux is mainly divided into four layers:

### Application Layer
- Top-most layer of the architecture  
- This is where the user works  
- Acts as the interface between the user and the system  
- Applications run in user space  
- User space is isolated from the kernel  

### Shell
- Interactive way to communicate with the kernel  
- Acts as a bridge between applications and the kernel  
- Commands entered by the user are interpreted here  
- Applications use system calls to request services from the kernel  

### Kernel
- Core part of the operating system  
- Manages CPU, memory, and devices  
- Retrieves data from hardware and provides it to applications  
- Responsible for process and memory management  

### Hardware
- Physical components like CPU, RAM, disk  
- Kernel communicates directly with hardware  
- Hardware sends data back up the stack  

---

## How Processes Are Created and Managed

- Every running program in Linux is a process  
- When we run a command or start a service, a new process is created  
- Each process gets a unique PID (Process ID)  
- When a command finishes, the process ends  
- All processes are managed by the kernel  

### Common Process States
- Running → currently using CPU  
- Sleeping → waiting for input or resource  
- Stopped → paused  
- Zombie → finished but still in process table  

---

## Common Process Management Commands

- `top` or `htop` → shows real-time CPU and memory usage  
- `ps aux` → lists all running processes  
- `kill <PID>` → stops a specific process  
- `nice` / `renice` → change process priority  

---

## What is systemd?

systemd is the service manager used in most modern Linux systems.  
It is the first process started by the kernel during boot and runs with PID 1.

systemd is responsible for:
- Starting services at boot  
- Stopping and restarting services  
- Managing background services  
- Keeping logs of services  

Example:  
Services like nginx, docker, and ssh are managed by systemd.

Why it matters:  
If a service crashes in production, we use systemctl commands to check logs and restart services.

---

## Commands I Will Use Daily

- `ps aux` → see running processes  
- `top` → live CPU and memory usage  
- `htop` → better process view  
- `systemctl status nginx` → check service status  
- `systemctl restart nginx` → restart service  

---

## Why This Matters for DevOps

Most production servers run on Linux.  
If CPU usage becomes high or a service crashes, the application or website can go down.  
Understanding processes and systemd helps in troubleshooting such issues quickly.

This knowledge will help me debug servers and manage services in real environments.
