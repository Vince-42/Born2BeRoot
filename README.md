# Born2BeRoot

## Creating an ARM64 virtual machine with VirtualBox on an Apple Silicon Mac

This guide applies to Apple Silicon Macs using VirtualBox 7.2 and ARM64/AArch64 guest operating systems.

Note : It does not apply to Intel Macs or x86/x86_64 guest operating systems.

## Ressources 

Oracle VirtualBox User Manual  : __https://download.virtualbox.org/virtualbox/7.2.12/UserManual.pdf__

### Rocky Ressources

Rocky Linux Source code  : __https://dl.rockylinux.org__

Rocky Linux OS download : __https://rockylinux.org/sr-SP/download__

Rocky firewalld docs   : __https://docs.rockylinux.org/10/de/guides/security/firewalld-beginners/__

Rocky Permissions docs   : __https://docs.rockylinux.org/10/books/admin_guide/14-special-authority/__

Rocky User Management   : __https://docs.rockylinux.org/10/books/admin_guide/06-users/__

Password Config Management

__https://www.server-world.info/en/note?os=Rocky_Linux_10&p=pam&f=1__

__https://docs.rockylinux.org/10/guides/security/pam/__

### Debian Ressources

Debian OS (Minimal)      : __https://cdimage.debian.org/debian-cd/current/arm64/iso-cd/__

Debian OS (Full - DVD)   : __https://cdimage.debian.org/debian-cd/current/arm64/iso-dvd/__


## Instruction 

Source : _adapted from the Oracle VirtualBox User Manual._


***The following example uses various VBoxManage commands to create a VM on a Mac OS.***

### 1. Set a variable for the VM.

**Virtual Machine Name.**
``` bash
VM="vm name"
```

**Base Directory & VDI Path.**
```
BASE_DIR="$HOME/VirtualBox VMs"
VM_DIR="$BASE_DIR/$VM"
VDI="$VM_DIR/$VM.vdi"
```

### 2. Select an OS type.
   
List the available guest OS types.
``` Bash
VBoxManage list ostypes
```
Note the exact ID of the one you need. This is required
in VBoxManage commands. 

Example : The below OS work on Mac architecture, __arm64__.

***ID*** / Description: ***Debian_arm64*** -- Debian (ARM 64-bit)

Family:           Linux / Debian (Linux)

Architecture:     ARMv8 (64-bit)

``` Bash
OS="ostype ID"
```

### 3. Create the virtual machine.


``` Bash
VBoxManage createvm \
  --name "$VM" \
  --ostype "$OS" \
  --basefolder "$BASE_DIR" \
  --register
```
The VM has a unique UUID. An XML settings file is generated.


### 4. Create a 32768 MB (32GB) virtual hard disk for the VM.
   
   _You can define the virtual hard disk size according to your needs._
   
``` bash
VBoxManage createhd --filename "$VDI" --size 32768
```

### 5. Create storage devices for the VM.
   
Create a VirtIO SCSI controller and attach the virtual hard disk. (This is required for Arm64 Architecture)

``` Bash
VBoxManage storagectl "$VM" \
  --name "VirtIO SCSI" \
  --add virtio-scsi \
  --controller VirtIO \
  --portcount 2 \
  --bootable on
```
```Note: the 'scsi' controller depends on which OS you are running, you might have to update it according to your OS.```

``` Bash
VBoxManage storageattach "$VM" \
  --storagectl "VirtIO SCSI" \
  --port 0 \
  --device 0 \
  --type hdd \
  --medium "$VDI"
```

### 6. Attach the virtual DVD drive to VirtIO, link the ISO file (OS).


**add path to ISO image.**
``` Bash
ISO="PATH .iso"
```

**Attach the .iso to the virtual DVD drive.**
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
``` Bash
VBoxManage modifyvm "$VM" --graphicscontroller vmsvga
```

### Optional Configuration

**Configure the boot device order for the VM.**
``` Bash
VBoxManage modifyvm "$VM" --boot1 dvd --boot2 disk --boot3 none --boot4 none
```

**Allocate 4096 MB of RAM (4GB), 128 MB of video RAM & 2 CPUs to the VM.**
``` Bash
VBoxManage modifyvm "$VM" --memory 4096 --vram 128 --cpus 2
```
_You can define the virtual RAM (memory), video ram (vram) size and CPUs according to your needs._



### 7. Start the virtual machine.

The VM starts in GUI mode, you can also start in --headless mode, see instruction below.
``` Bash
VBoxManage startvm "$VM" --type gui
```

### General Instruction

**Show specific information on the VM.**
``` Bash
VBoxManage showvminfo "$VM" | grep -E "Memory size|Number of CPUs|CPU exec cap|Firmware|Graphic|Boot Device|State|Pointing Device|OHCI USB|EHCI USB|xHCI USB"
```

**Use a virtual USB keyboard and USB tablet if guest input is unreliable**
``` Bash
VBoxManage modifyvm "$VM" --usb-xhci on --keyboard usb --mouse usbtablet
```

**You can also start the vm headless (no GUI).**
``` Bash
VBoxManage startvm "$VM" --type headless
```

**List all registered VM on the hardware.**
``` Bash
VBoxManage list vms
```

### Shutdown and troubleshooting

***The VM must be powered off before deletion.***

**Safe shutdown from the Mac host**
``` Bash
VBoxManage controlvm "$VM" acpipowerbutton
```

**Startup-troubleshooting command**
``` Bash
VBoxManage showvminfo "$VM" --log 0 | tail -n 80
```

**Retrieve the VM signature ID.**
``` bash
VM="vm_name"
VDI="$HOME/VirtualBox VMs/$VM/$VM.vdi"
```
``` bash
VBoxManage showvminfo "$VM" | grep -i '^State'
shasum "$VDI"
```
```shasum "$VDI" return the signature.```


**To delete both the VM registration and its virtual disk/configuration files.**
``` Bash
VBoxManage unregistervm "$VM" --delete
```


## Instruction Inside VM

**Return the SELinux status.**
``` bash
sestatus
``` 

**Add a new user with defaults setting.**
``` bash
useradd -D <options> “login”
```

**Return the hostname.**
```bash
hostname
```

**Change the hostname.**
```bash
hostname “newhostname”
``` 

**MAN config sudo front end.**
``` bash
man sudo.conf
```

### SSH configuration

``` Bash
semanage port -l | grep ssh_port_t
```
```Note : For Rocky - if the command is not found, process to Instal semanage packages.```

**Instal semanage packages.**
``` Bash
dnf install -y policycoreutils-python-utils
```

**Allowing a new connection port.**
``` Bash
semanage port -a -t ssh_port_t -p tcp "add_new_port_number"
```
```note : verify that the tcp and NAT is configured on the VM```


### Password configuration


