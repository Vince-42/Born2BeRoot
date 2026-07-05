# Born2BeRoot
Virtual Machine


## Ressources 

User Manual Virtual Box : __https://download.virtualbox.org/virtualbox/7.2.12/UserManual.pdf__

Rocky Linux : __https://dl.rockylinux.org__

Debian OS (CD - without netsinst image) : __https://cdimage.debian.org/debian-cd/current/arm64/iso-cd/__


## Instruction 

Source : _User Manual Virtual Box_.

The following example uses various VBoxManage commands to specify the VM and configure an
unattended guest installation for an Oracle Linux VM on a Linux host
It then shows the use of the VBoxManage unattended install command to install and configure the
guest OS.

### 1. Set a variable for the name of the OS.
```
VM=<vm name>
```

### 2. Select an OS type.
   
List the available guest OS types.
```
VBoxManage list ostypes
```
Note the exact ID of the one you need. This is required
in VBoxManage commands. 

Example : The below OS work on Mac architecture, __arm64__.

***ID*** / Description: ***Debian_arm64*** -- Debian (ARM 64-bit)

Family:           Linux / Debian (Linux)

Architecture:     ARMv8 (64-bit)

```
OS=<ostype ID>
```

### 3. Create the virtual machine.

```
VBoxManage createvm --name $VM --ostype $OS --register
```
The VM has a unique UUID. An XML settings file is generated.


### 4. Create a 32768 MB (32GB) virtual hard disk for the VM.
   
   _You can define the virtual hard disk size according to your needs._
   
```
VBoxManage createhd --filename /VirtualBox/$VM/$VM.vdi --size 32768
```

### 5. Create storage devices for the VM.
   
Create a SATA storage controller and attach the virtual hard disk.

```
VBoxManage storagectl $VM --name "SATA Controller" --add sata --controller IntelAHCI
```

```
VBoxManage storageattach $VM --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium /VirtualBox/$VM/$VM.vdi
```

### 6. Create an IDE storage controller for a virtual DVD drive and attach an Oracle Linux
installation ISO.

_You can also rattach the virtual DVD drive to SATA Controller port 1_

```
VBoxManage storagectl $VM --name "IDE Controller" --add ide
```

```
VBoxManage storageattach $VM --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium /u01/Software/OL/OracleLinux-R7-U6-Server-x86_64-dvd.iso
```

### Optional Configuration

Enable I/O APIC for the motherboard of the VM.
```
VBoxManage modifyvm $VM --ioapic on
```

Configure the boot device order for the VM.
```
VBoxManage modifyvm $VM --boot1 dvd --boot2 disk --boot3 none --boot4 none
```

Allocate 8192 MB of RAM (8GB) and 128 MB of video RAM to the VM.
```
VBoxManage modifyvm $VM --memory 8192 --vram 128
```

### 7. Specify the Unattended Installation parameters, and then install the OS.

Specify an Oracle Linux ISO as the installation ISO. Specifiy a user name, full name, and password for a default user on the guest OS. Specifiy a user name, full name, and password for a default user on the guest OS.

```
# VBoxManage unattended install $VM --iso=/u01/Software/OL/OracleLinux-R7-U6-Server-x86_64-dvd.iso --user=login --full-user-name=name --user-password password \

• Specify that you want to install the VirtualBox Guest Additions on the VM.
49
User Guide for Release 7.2
--install-additions \
• Sets the time zone for the guest OS to Central European Time (CET).
--time-zone=CET
8. Start the virtual machine.
# VBoxManage startvm $VM --type headless
The VM starts in headless mode, which means that it does not have a GUI.


Delete both the VM registration and its virtual disk/configuration files

```
VBoxManage unregistervm "$VM" --delete
```
