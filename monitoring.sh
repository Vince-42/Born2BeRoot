#!/bin/bash

# Var
currterm=$(tty| sed 's|/dev/||')
usedmem=$(free -m | grep Mem | awk '{print $3}')
fullmem=$(free -m | grep Mem | awk '{print $2}')
freemem=$(free -m | grep Mem | awk '{print $3/$2*100}')
vCPU=$(nproc --all)
CPU=1
hostarchi=$(hostnamectl | grep Architecture | awk '{print $2}')
kernelversion=$(hostnamectl | grep Kernel | awk '{print $2 $3}')
osystem=$(hostnamectl | grep "Operating System" | awk '{print $3 $4 $5}')
storageavailable=$(df -m --total | grep total | awk '{print $4/1000}')
storageused=$(df -m --total | grep total | awk '{print $3/1000}')
storagetotal=$(df -m --total | grep total | awk '{print $2/1000}')
storageratio=$(df -m --total | grep total | awk '{print $3/$2*100}')
# storageratio=$storageused/$storagetotal*100
cpuratio=$(vmstat 1 2 | tail -1 | awk '{print 100-$15}')
lastboot=$(uptime -s)
upsince=$(uptime -p)
currentdate=$(date -R)
lvmuse=$(lsblk | grep -q "lvm" && echo "YES" || "NO")
tcpconnect=$(ss -tn state established | tail -n+2 | wc -l)
usernb=$(who | wc -l)
networkip=$(ip -4 addr | grep "inet" | tail -n+2 | awk '{split ($2, a, "/"); print a[1]}')
networkmac=$(ip link show | grep ether | awk '{print $2}')
sudocommand=$(grep -c "COMMAND=" /var/log/sudo/sudo.log)

# Message Introduction 
intro=$(echo "Broadcast message from @$(whoami).$currentdate. Have a good day !")

# Architecture info : OS ; user name ; architecture info
architecture=$(printf "# Architecture : %s | OS : %s. | OS Architecture : %s.\n          Kernel Version : %s." "$(uname)" "$osystem" "$hostarchi" "$kernelversion")

# Physical CPUs
PCPUs=$(echo "# Physical CPU(s): $CPU.")

# Virtual CPUs
VCPUs=$(echo "# vCPU(s): $vCPU.")

# Memory info
memory=$(printf "# Memory Usage (RAM) : %i/%i MB (%.2f%%)." "$usedmem" "$fullmem" "$freemem")

# Storage info
storageinfo=$(printf "# Disk Usage : %.1f / %.1f GB (%.1f%%)." "$storageused" "$storagetotal" "$storageratio" )

# CPU Usage
cpuinfo=$(printf "# CPU load : %.1f%%." "$cpuratio")

# Last Boot Info
bootinfo=$(printf "# Last boot : %s. | %s." "$lastboot" "$upsince")

# LVM Use Info
lvminfo=$(printf "# LVM use : %s." "$lvmuse")

# TCP Connection(s) Info
tcpinfo=$(printf "# TCP Connection(s) : %i ESTABLISHED." "$tcpconnect")

# User Log Info
userinfo=$(printf "# User log : %i" "$usernb")

# Network IP Info
networkinfo=$(printf "# Network : IP %s (%s)" "$networkip" "$networkmac")

# Sudo Commands # Info
sudoinfo=$(printf "# Sudo : %i cmd (commands executed)." "$sudocommand")

# Create the final report
report=$(printf '\n%s\n\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n' "$intro" "$architecture" "$PCPUs" "$VCPUs" "$memory" "$storageinfo" "$cpuinfo" "$bootinfo" "$lvminfo" "$tcpinfo" "$userinfo" "$networkinfo" "$sudoinfo")

# Print the final report to all terminal | option -n to hide banner
printf '%s\n' "$report" | wall -n

