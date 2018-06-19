Virtual Machine's Template Guide
================================

This guide gives hints and tips for templating VMs for virtual laboratory.


Simplest way to create Guest virtual machine is local VirtualBox installation.

1. Install guest operating system on local machine or using phpVirtualBox on server

1. Install packages and VirtualBox Guest Additions

1. Disable USB2, USB3 and 3D acceleration

1. Enable RDP

1. Enable external authentication for RDP

1. Export virtual machine to .ova

1. Copy .ova to server and import it using phpVirtualBox




GNU/Linux Ubuntu and other GNU Debian Linux based systems
---------------------------------------------------------

Choose right mirror 

Update local package repository cache
```bash
sudo apt-get update
```
Install acpid to ensure ACPI event handling in guests
```bash
sudo apt-get install acpid
```
Install Ruby package for LAB scripting
```bash
sudo apt-get install ruby
```

Cleanup and remove unnecessary packages
```bash
apt-get autoremove
apt-get clean
```

Install gnome-session-flashback because unity don't work well with no 3D graphics accelerator or Mate desktop and switch off client side acceleration.


TODO: disc scheduler to realtime

TODO: /etc/fstab noatime,nodiratime


TODO: zerofill and shrink disks


Install guest additions

In case KALI Linux the exec rights are disabled in case mounting cdrom (iso). Then installation of 
guest addidons can be done with remounting cdrom with exec options.

    mount -o remount,exec,ro /dev/cdrom



###Disable apport

On Ubuntu you can disable apport error lollecting and disable apport:

```bash
sed 's/enabled=1/enabled=0/' -i /etc/default/apport
```

###Optional packages and settings


```bash
sudo apt-get install htop links 
export LC_ALL=C >> .bashrc
```

Install curl and create keypair for VM modifications (Optional)
This is only needed if modifications in Guest OS' are needed per LAB execution
```bash
#In Host side
ssk-keygen
cp GENERATED_PUBLIC_KEY.pub to Rails_webapp_/public directory
#In Guest side
sudo apt-get install curl
sudo apt-get install ssh
sudo mkdir /root/.ssh
sudo chmod 700 /root/.ssh
curl --insecure https://YOUR_FQDN/GENERATED_PUBLIC_KEY.pub >> /root/.ssh/authorized_keys
```


Gnome flashback session
```
apt-get install gnome-session-fallback
```
Enable automatic shutdown when acpi power button is pressed
```
gsettings set org.gnome.settings-daemon.plugins.power button-power shutdown
```

disable automatic checking for updates.
install updates.


Writing LAB descriptions and materials
======================================
https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet

Tuning disk io for Ubuntu Guest
=================================

1. mount partitions with noatime,nodiratime mount options (replaze UUID=XXXX to your disk blkid or name)
UUID=XXXXXXX / ext4 defaults,noatime,nodiratime 0 1

1. change disk scheduler to noop

vim /etc/default/grub
GRUB_CMDLINE_LINUX_DEFAULT="elevator=noop quiet"

Tuning Host TODO
===================================
https://lonesysadmin.net/2013/12/22/better-linux-disk-caching-performance-vm-dirty_ratio/

vm.dirty_background_ratio = 1
vm.dirty_ratio = 80
