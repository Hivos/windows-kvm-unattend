# Unattended install of Windows Server on KVM Host
Sripts and howto for unattended windows server installs on kvm platform

## Procedure for creating a VM

Logon to virtualization01, then first create the disks

```bash
lvcreate --name sr3-disk1 --size 60G lvm1-vol
lvcreate --name sr3-disk2 --size 40G lvm1-vol
lvcreate --name sr3-disk3 --size 75G lvm1-vol
```

### Windows Server 2012 R2 VM (manual)

Here we install a server 2012 r2 machine with 8 vpcus, 16 GB of RAM, the os-variant is win2k8, because that's the most recent windows server variant the kvm version on debian "supports", for a list of supported variants use the command:

```bash
virt-install --os-variant list|grep win
```


```bash
virt-install \
--connect qemu:///system \
--hvm \
--virt-type kvm \
--network=bridge:br1,model=virtio \
--noautoconsole \
--name sr4.example.com \
--disk path=/dev/lvm1-vol/sr4-disk1,bus=virtio,cache=none \
--disk path=/dev/lvm1-vol/sr4-disk2,bus=virtio,cache=none \
--ram 16384 \
--vcpus=8 \
--vnc \
--os-type windows \
--os-variant win2k8 \
--disk path= /images/virtio-win-0.1.96.iso,device=cdrom \
--cdrom /images/ SW_DVD5_Windows_Svr_Std_and_DataCtr_2012_R2_64Bit_English_Core_MLF_X19-05182.ISO \
--livecd
```


Install Windows via console, make all customizations, install updates  etc. and then shutdown the VM, after shutdown undefine the VM


```bash
virsh -c qemu:///system undefine sr4.example.com
````

### Windows Server 2012 R2 VM (semi-unattended)

This method uses a virtual floppy drive containing the virtio drivers and a Autounattend.xml file. When Windows setup detects that a floppy is connected with such an xml file on it, it will start auto installing Windows

- Download the stable floppy image file (*.vfd) from https://fedoraproject.org/wiki/Windows_Virtio_Drivers 
- Mount the floppy image [root@kvmtest tmp]# mount -o loop /var/lib/libvirt/images/virtio-win.vfd /mnt/fdv/
- Copy the Autounattend.xml (or edit it directly if it's an already existing floppy image) to /mnt/fdv/, make sure that the <Computername> tags contain the name of the new VM, NOT the name of an already existing Windows VM!
- Optionally edit the start.ps1 script, which runs after Windows is installed.
- Unmount the floppy image
- The floppy image can now be used for installs

```bash
 virt-install \
 --connect qemu:///system \
 --hvm --virt-type kvm \
 --network=bridge:br1,model=virtio \
 --noautoconsole \
 --name sr3.hivos.nl \
 --disk path=/dev/lvm1-vol/sr3-disk1,bus=virtio,cache=none \
 --disk path=/dev/lvm1-vol/sr3-disk2,bus=virtio,cache=none \
 --disk path=/dev/lvm1-vol/sr3-disk3,bus=virtio,cache=none \
 --ram 4096 \
 --vcpus=2 \
 --vnc \
 --os-type windows \
 --os-variant win2k8 \
 --disk path=/images/virtio-win.iso,device=cdrom \
 --disk path=/images/virtio-win.vfd,device=floppy \
 --cdrom /images/SW_DVD5_Windows_Svr_Std_and_DataCtr_2012_R2_64Bit_English_Core_MLF_X19-05182.ISO \
 --livecd

 
Currenty the virtio balloon drivers are not automatically installed with the floppy process, so these need to be manually installed after the install is finished.

## Finishing touches after installation


Now reinstall the VM

```bash
virt-install \
  --connect qemu:///system \
  --hvm \
  --virt-type kvm \
  --network=bridge:br1,model=virtio,mac=AA:BB:CC:DD:EE:FF \
  --noautoconsole \
  --name sr3.hivos.nl \
  --disk path=/dev/lvm1-vol/sr3-disk1,bus=virtio,cache=none \
  --disk path=/dev/lvm1-vol/sr3-disk2,bus=virtio,cache=none \
  --disk path=/dev/lvm1-vol/sr3-disk3,bus=virtio,cache=none \
  --ram 16384 \
  --vcpus=4 \
  --vnc \
  --os-type windows \
  --os-variant win2k8 \
  --import
```

Run the checkout script, modify setup-swayne-elayna-lvm.txt & setup-swayne-elayna-virt-instal.txt accordingly => run commit script

## More info

https://untitledfinale.wordpress.com/2007/10/09/create-mount-and-copy-floppy-disks-images-under-linux/
