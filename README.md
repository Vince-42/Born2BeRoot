# Born2BeRoot
Virtual Machine


## Ressources 

User Manual Virtual Box : __https://download.virtualbox.org/virtualbox/7.2.12/UserManual.pdf__

Rocky Linux : __https://dl.rockylinux.org__

Debian OS (CD - without netsinst image) : __https://cdimage.debian.org/debian-cd/current/arm64/iso-cd/__


## Instruction 

Source : _User Manual Virtual Box_.


***The following example uses various VBoxManage commands to specify the VM and configure an unattended guest installation for an OS on a Mac host. It then shows the use of the VBoxManage unattended install command to install and configure the guest OS.***

### 1. Set a variable for the name of the OS.
``` bash
VM=<vm name>
```

### 2. Select an OS type.
   
List the available guest OS types.
``` bash
VBoxManage list ostypes
```
Note the exact ID of the one you need. This is required
in VBoxManage commands. 

Example : The below OS work on Mac architecture, __arm64__.

***ID*** / Description: ***Debian_arm64*** -- Debian (ARM 64-bit)

Family:           Linux / Debian (Linux)

Architecture:     ARMv8 (64-bit)

``` bash
OS=<ostype ID>
```

### 3. Create the virtual machine.

``` bash
VBoxManage createvm --name $VM --ostype $OS --register
```
The VM has a unique UUID. An XML settings file is generated.


### 4. Create a 32768 MB (32GB) virtual hard disk for the VM.
   
   _You can define the virtual hard disk size according to your needs._
   
``` bash
VBoxManage createhd --filename /VirtualBox/$VM/$VM.vdi --size 32768
```

### 5. Create storage devices for the VM.
   
Create a VirtIO SCSI controller and attach the virtual hard disk. (This is good practice for Arm64 Architecture)

``` Bash
VBoxManage storagectl "$VM" \
  --name "VirtIO SCSI" \
  --add scsi \
  --controller VirtIO \
  --portcount 2 \
  --bootable on
```

``` Bash
VBoxManage storageattach "$VM" \
  --storagectl "VirtIO SCSI" \
  --port 0 \
  --device 0 \
  --type hdd \
  --medium "$VDI"
```

### 6. Rattach the virtual DVD drive to VirtIO, link the ISO file (OS).


**add path to ISO image.**
``` Bash
ISO=<PATH .iso>
```

**Attach the .iso to the virtuak DVD drive.**
``` Bash
VBoxManage storageattach "$VM" \
  --storagectl "VirtIO SCSI" \
  --port 1 \
  --device 0 \
  --type dvddrive \
  --medium "$ISO"
```


### On Apple Silicon / ARM host, VirtualBox supports VMSVGA only as the graphics controller.

**Change the graphics controller**
```
VBoxManage modifyvm "$VM" --graphicscontroller vmsvga
```

### Optional Configuration

**Enable I/O APIC for the motherboard of the VM.**
```
VBoxManage modifyvm $VM --ioapic on
```

**Configure the boot device order for the VM.**
```
VBoxManage modifyvm $VM --boot1 dvd --boot2 disk --boot3 none --boot4 none
```

**Allocate 8192 MB of RAM (8GB) and 128 MB of video RAM to the VM.**
```
VBoxManage modifyvm $VM --memory 8192 --vram 128
```
_You can define the virtual RAM (memory) and video ram (vram) size according to your needs._


**Specify the Unattended Installation parameters, and then install the OS.**

_Specify an Operating System ISO as the installation ISO. Specifiy a user name, full name, and password for a default user on the guest OS.
Specify that you want to install the VirtualBox Guest Additions on the VM. Sets the time zone for the guest OS to Central European Time (CET)._
```
VBoxManage unattended install $VM --iso=$ISO --user=<login> --full-user-name=<name> --user-password <password> --install-additions --time-zone=CET
```

### 7. Start the virtual machine.

The VM starts in headless mode, which means that it does not have a GUI.
```
VBoxManage startvm $VM --type headless
```

### General Instruction

**Show specific information on the VM.**
```
VBoxManage showvminfo "$VM" | grep -E "Memory size|Number of CPUs|CPU exec cap|Firmware|Graphic|Boot Device|State|Pointing Device|OHCI USB|EHCI USB|xHCI USB"
```

**Allow control from keyboard from the VM.**
```
VBoxManage modifyvm "$VM" --usb-xhci on --keyboard usb --mouse usbtablet
```

**You can also start the vm with a GUI.**
```
VBoxManage startvm "$VM" --type gui
```

**List all registered VM on the hardware.**
```
VBoxManage list vms
```

**To delete both the VM registration and its virtual disk/configuration files.**
```
VBoxManage unregistervm "$VM" --delete
```
