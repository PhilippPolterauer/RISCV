# Simple RISCV Busybox example
This repository contains a Docker Container and a readme showing how to build the linux kernel and busybox for the RISCV architecture.
The result is tested using qemu RISCV emulation.

The project was done to learn more about building a custom minimal linux and using qemu to emulate different architectures.
Important topics:
- cross compiling from x86 (windows) to RISCV
- machine (ISA) emulation using qemu
- linux kernel compilation

References:
- RISCV
    - [homepage](https://riscv.org/])
    - [wikipedia](https://en.wikipedia.org/wiki/RISC-V)
    - [docs](https://risc-v-getting-started-guide.readthedocs.io/en/latest/index.html)
- QEMU
    - [homepage](https://www.qemu.org/)
- busybox
    - [homepage](https://busybox.net/)


## TLDR

0) On Windows start wsl2 and navigate to a wsl2 folder (for performance reasons)

1) clone the repository and open VSCODE from within wsl2 
```bash
# from a normal terminal start wsl
wsl
# change to a local folder (!important for performance)
cd
# clone repository
git clone https://github.com/PhilippPolterauer/RISCV.git
# OPEN it in vscode
cd RISCV && code .
```

2) start the docker 
    - either through VSCode (open inside devcontainer)
    - or manually
```bash
# build container with tag riscv
docker build .devcontainer/Dockerfile -t riscv
# run image
docker run riscv
```
3) run the main script
```bash
# Run all
./scripts/run_all.sh
```
4) copy files to host and start qemu with the kernel and initramfs
```bash
# on windows (the following commandos copy everything to the home folder)
#    inside terminal
wsl # start wsl2
cp ~/RISCV/build/linux/arch/riscv/boot/Image .
cp ~/RISCV/build/initramfs.cpio.gz .
# CTRL+D to close wsl2

# run qemu on pwershell or cmd
qemu-system-riscv64 -machine virt -kernel Image -initrd initramfs.cpio.gz -nographic -append "console=ttyS0"
```
```bash
# or on linux
cd ~/RISCV
qemu-system-riscv64 -kernel ./build/linux/arch/riscv/boot/Image -initrd ./build/initramfs.cpio.gz -nographic -append "console=ttyS0"
```

# Detailed Instructions
## Prequisites
- Install qemu from [here](https://www.qemu.org/download/)
- I suggest useing vscode and start the devcontainer

## Suggested Tools
- WSL2
- docker
- vscode

## Get Sources
we use linux kernel v5.17 and busybox 1.35.0

```bash
# prepare source folder
export SRC_FOLDER=/workspaces/RISCV/source
mkdir -p $SRC_FOLDER
cd $SRC_FOLDER

# if git is available
git clone https://github.com/torvalds/linux/ -b v5.17 --single-branch --depth 1
git clone https://git.busybox.net/busybox -b 1_35_0 --single-branch --depth 1

# or otherwise download tarballs
wget https://github.com/torvalds/linux/archive/refs/tags/v5.17.tar.gz 
wget https://git.busybox.net/busybox/snapshot/busybox-1_35_0.tar.bz2

# and unpack the files
tar -xvf v5.17.tar.gz 
tar -xvfj busybox-1_35_0.tar.bz2 
```

prepare build folder
```bash
export BUILD_FOLDER=/workspaces/RISCV/build
mkdir -p $BUILD_FOLDER/{busybox,linux,intitramfs}
```

## Building Linux with default configuration
```bash
cd $SRC_FOLDER/linux/
mkdir -p $BUILD_FOLDER/linux
# configure make all default
make O=$BUILD_FOLDER/linux/ defconfig
# build linux 
make O=$BUILD_FOLDER/linux/ -j8
```

## Building Busybox with minimal configuration
```bash
mkdir -p $BUILD_FOLDER/busybox
cd $SRC_FOLDER/busybox
make O=$BUILD_FOLDER/busybox/ defconfig
```
configure static linking of busybox either manually using menuconfig 

```bash
make O=$BUILD_FOLDER/busybox/ menuconfig 
# check the build option under
# -> Settings
# --- Build Options
#   -> [*] Build static binary (no shared libs)   
```
or with the following command
```bash
sed -i 's/# CONFIG_STATIC is not set/CONFIG_STATIC=y/g' $BUILD_FOLDER/busybox/.config
```
```bash
# build busybox with 8 cores
make O=$BUILD_FOLDER/busybox/ -j8
# this copies everything to _install folder 
make O=$BUILD_FOLDER/busybox/ install
```


## makeing an initramfs file containing the busybox files
```bash
# clean folder
rm -r $BUILD_FOLDER/initramfs/*
# start new
cd $BUILD_FOLDER/initramfs
# setup basic filesystem
mkdir -pv {bin,sbin,etc,proc,sys,usr/{bin,sbin}}
# copy all of busybox installation files
cp -av $BUILD_FOLDER/busybox/_install/* .
# setup basic init executable
printf "#!/bin/sh\nexec /bin/sh" >> init
chmod +x init # make sure the init file is executable
# generate intramfs file
find . -print0 | cpio --null -ov --format=newc | gzip -9 > $BUILD_FOLDER/initramfs.cpio.gz
```

## launch qemu with kernel and initramfs
use the following command from within the native (windows) terminal where qemu shall be installed
```
qemu-system-riscv64 -kernel .\build\linux\arch\riscv\boot\Image -initrd .\build\initramfs.cpio.gz -nographic -append "console=ttyS0"
```
# Expected Output
if everything works the output should look like the following 
```powershell
PS C:\Users\Philipp> qemu-system-riscv64 -machine virt -kernel Image -initrd initramfs.cpio.gz -nographic -append "console=ttyS0"

OpenSBI v0.9
   ____                    _____ ____ _____
  / __ \                  / ____|  _ \_   _|
 | |  | |_ __   ___ _ __ | (___ | |_) || |
 | |  | | '_ \ / _ \ '_ \ \___ \|  _ < | |
 | |__| | |_) |  __/ | | |____) | |_) || |_
  \____/| .__/ \___|_| |_|_____/|____/_____|
        | |
        |_|

Platform Name             : riscv-virtio,qemu
Platform Features         : timer,mfdeleg
Platform HART Count       : 1
Firmware Base             : 0x80000000
Firmware Size             : 100 KB
Runtime SBI Version       : 0.2

Domain0 Name              : root
Domain0 Boot HART         : 0
Domain0 HARTs             : 0*
Domain0 Region00          : 0x0000000080000000-0x000000008001ffff ()
Domain0 Region01          : 0x0000000000000000-0xffffffffffffffff (R,W,X)
Domain0 Next Address      : 0x0000000080200000
Domain0 Next Arg1         : 0x0000000087000000
Domain0 Next Mode         : S-mode
Domain0 SysReset          : yes

Boot HART ID              : 0
Boot HART Domain          : root
Boot HART ISA             : rv64imafdcsu
Boot HART Features        : scounteren,mcounteren,time
Boot HART PMP Count       : 16
Boot HART PMP Granularity : 4
Boot HART PMP Address Bits: 54
Boot HART MHPM Count      : 0
Boot HART MHPM Count      : 0
Boot HART MIDELEG         : 0x0000000000000222
Boot HART MEDELEG         : 0x000000000000b109
[    0.000000] Linux version 5.17.0 (root@463837ef6698) (riscv64-buildroot-linux-gnu-gcc.br_real (Buildroot toolchains.bootlin.com-2021.11-1) 10.3.0, GNU ld (GNU Binutils) 2.36.1) #1 SMP Fri Apr 22 22:30:31 CEST 2022
[    0.000000] OF: fdt: Ignoring memory range 0x80000000 - 0x80200000
[    0.000000] Machine model: riscv-virtio,qemu
[    0.000000] efi: UEFI not found.
[    0.000000] Zone ranges:
[    0.000000]   DMA32    [mem 0x0000000080200000-0x0000000087ffffff]
[    0.000000]   Normal   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000080200000-0x0000000087ffffff]
[    0.000000] Initmem setup node 0 [mem 0x0000000080200000-0x0000000087ffffff]
[    0.000000] SBI specification v0.2 detected
[    0.000000] SBI implementation ID=0x1 Version=0x9
[    0.000000] SBI TIME extension detected
[    0.000000] SBI IPI extension detected
[    0.000000] SBI RFENCE extension detected
[    0.000000] SBI HSM extension detected
[    0.000000] riscv: ISA extensions acdfimsu
[    0.000000] riscv: ELF capabilities acdfim
[    0.000000] percpu: Embedded 17 pages/cpu s30824 r8192 d30616 u69632
[    0.000000] Built 1 zonelists, mobility grouping on.  Total pages: 31815
[    0.000000] Kernel command line: console=ttyS0
[    0.000000] Dentry cache hash table entries: 16384 (order: 5, 131072 bytes, linear)
[    0.000000] Inode-cache hash table entries: 8192 (order: 4, 65536 bytes, linear)
[    0.000000] mem auto-init: stack:off, heap alloc:off, heap free:off
[    0.000000] Virtual kernel memory layout:
[    0.000000]       fixmap : 0xffff8d7ffee00000 - 0xffff8d7fff000000   (2048 kB)
[    0.000000]       pci io : 0xffff8d7fff000000 - 0xffff8d8000000000   (  16 MB)
[    0.000000]      vmemmap : 0xffff8d8000000000 - 0xffff8f8000000000   (2097152 MB)
[    0.000000]      vmalloc : 0xffff8f8000000000 - 0xffffaf8000000000   (33554432 MB)
[    0.000000]       lowmem : 0xffffaf8000000000 - 0xffffaf8007e00000   ( 126 MB)
[    0.000000]       kernel : 0xffffffff80000000 - 0xffffffffffffffff   (2047 MB)
[    0.000000] Memory: 107284K/129024K available (6199K kernel code, 4861K rwdata, 2048K rodata, 2154K init, 326K bss, 21740K reserved, 0K cma-reserved)
[    0.000000] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=1, Nodes=1
[    0.000000] rcu: Hierarchical RCU implementation.
[    0.000000] rcu:     RCU restricting CPUs from NR_CPUS=8 to nr_cpu_ids=1.
[    0.000000] rcu:     RCU debug extended QS entry/exit.
[    0.000000]  Tracing variant of Tasks RCU enabled.
[    0.000000] rcu: RCU calculated value of scheduler-enlistment delay is 25 jiffies.
[    0.000000] rcu: Adjusting geometry for rcu_fanout_leaf=16, nr_cpu_ids=1
[    0.000000] NR_IRQS: 64, nr_irqs: 64, preallocated irqs: 0
[    0.000000] riscv-intc: 64 local interrupts mapped
[    0.000000] plic: plic@c000000: mapped 53 interrupts with 1 handlers for 2 contexts.
[    0.000000] random: get_random_bytes called from start_kernel+0x4c8/0x6f4 with crng_init=0
[    0.000000] riscv_timer_init_dt: Registering clocksource cpuid [0] hartid [0]
[    0.000000] clocksource: riscv_clocksource: mask: 0xffffffffffffffff max_cycles: 0x24e6a1710, max_idle_ns: 440795202120 ns
[    0.000086] sched_clock: 64 bits at 10MHz, resolution 100ns, wraps every 4398046511100ns
[    0.003393] Console: colour dummy device 80x25
[    0.004960] Calibrating delay loop (skipped), value calculated using timer frequency.. 20.00 BogoMIPS (lpj=40000)
[    0.005108] pid_max: default: 32768 minimum: 301
[    0.006240] Mount-cache hash table entries: 512 (order: 0, 4096 bytes, linear)
[    0.006271] Mountpoint-cache hash table entries: 512 (order: 0, 4096 bytes, linear)
[    0.033228] cblist_init_generic: Setting adjustable number of callback queues.
[    0.033373] cblist_init_generic: Setting shift to 0 and lim to 1.
[    0.033976] ASID allocator using 16 bits (65536 entries)
[    0.034909] rcu: Hierarchical SRCU implementation.
[    0.036587] EFI services will not be available.
[    0.038696] smp: Bringing up secondary CPUs ...
[    0.038785] smp: Brought up 1 node, 1 CPU
[    0.047391] devtmpfs: initialized
[    0.053939] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 7645041785100000 ns
[    0.054203] futex hash table entries: 256 (order: 2, 16384 bytes, linear)
[    0.058936] NET: Registered PF_NETLINK/PF_ROUTE protocol family
[    0.087744] iommu: Default domain type: Translated
[    0.087782] iommu: DMA domain TLB invalidation policy: strict mode
[    0.090345] vgaarb: loaded
[    0.091781] SCSI subsystem initialized
[    0.093532] usbcore: registered new interface driver usbfs
[    0.093795] usbcore: registered new interface driver hub
[    0.093919] usbcore: registered new device driver usb
[    0.102906] clocksource: Switched to clocksource riscv_clocksource
[    0.114429] NET: Registered PF_INET protocol family
[    0.115882] IP idents hash table entries: 2048 (order: 2, 16384 bytes, linear)
[    0.119850] tcp_listen_portaddr_hash hash table entries: 128 (order: 0, 5120 bytes, linear)
[    0.119945] TCP established hash table entries: 1024 (order: 1, 8192 bytes, linear)
[    0.120157] TCP bind hash table entries: 1024 (order: 3, 32768 bytes, linear)
[    0.120300] TCP: Hash tables configured (established 1024 bind 1024)
[    0.121672] UDP hash table entries: 256 (order: 2, 24576 bytes, linear)
[    0.121945] UDP-Lite hash table entries: 256 (order: 2, 24576 bytes, linear)
[    0.123029] NET: Registered PF_UNIX/PF_LOCAL protocol family
[    0.125534] RPC: Registered named UNIX socket transport module.
[    0.125584] RPC: Registered udp transport module.
[    0.125597] RPC: Registered tcp transport module.
[    0.125611] RPC: Registered tcp NFSv4.1 backchannel transport module.
[    0.125742] PCI: CLS 0 bytes, default 64
[    0.130799] Unpacking initramfs...
[    0.133683] workingset: timestamp_bits=62 max_order=15 bucket_order=0
[    0.152965] NFS: Registering the id_resolver key type
[    0.153868] Key type id_resolver registered
[    0.153910] Key type id_legacy registered
[    0.154232] nfs4filelayout_init: NFSv4 File Layout Driver Registering...
[    0.154329] nfs4flexfilelayout_init: NFSv4 Flexfile Layout Driver Registering...
[    0.158901] 9p: Installing v9fs 9p2000 file system support
[    0.160193] NET: Registered PF_ALG protocol family
[    0.160654] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 251)
[    0.160780] io scheduler mq-deadline registered
[    0.160849] io scheduler kyber registered
[    0.173800] pci-host-generic 30000000.pci: host bridge /soc/pci@30000000 ranges:
[    0.174589] pci-host-generic 30000000.pci:       IO 0x0003000000..0x000300ffff -> 0x0000000000
[    0.175016] pci-host-generic 30000000.pci:      MEM 0x0040000000..0x007fffffff -> 0x0040000000
[    0.175070] pci-host-generic 30000000.pci:      MEM 0x0400000000..0x07ffffffff -> 0x0400000000
[    0.175576] pci-host-generic 30000000.pci: Memory resource size exceeds max for 32 bits
[    0.176669] pci-host-generic 30000000.pci: ECAM at [mem 0x30000000-0x3fffffff] for [bus 00-ff]
[    0.177757] pci-host-generic 30000000.pci: PCI host bridge to bus 0000:00
[    0.177980] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.178059] pci_bus 0000:00: root bus resource [io  0x0000-0xffff]
[    0.178120] pci_bus 0000:00: root bus resource [mem 0x40000000-0x7fffffff]
[    0.178134] pci_bus 0000:00: root bus resource [mem 0x400000000-0x7ffffffff]
[    0.179321] pci 0000:00:00.0: [1b36:0008] type 00 class 0x060000
[    0.249045] Freeing initrd memory: 1200K
[    0.260678] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[    0.266375] printk: console [ttyS0] disabled
[    0.268045] 10000000.uart: ttyS0 at MMIO 0x10000000 (irq = 2, base_baud = 230400) is a 16550A
[    0.424466] printk: console [ttyS0] enabled
[    0.438031] loop: module loaded
[    0.442280] e1000e: Intel(R) PRO/1000 Network Driver
[    0.443467] e1000e: Copyright(c) 1999 - 2015 Intel Corporation.
[    0.445211] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    0.446776] ehci-pci: EHCI PCI platform driver
[    0.447966] ehci-platform: EHCI generic platform driver
[    0.449285] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[    0.450751] ohci-pci: OHCI PCI platform driver
[    0.451965] ohci-platform: OHCI generic platform driver
[    0.454118] usbcore: registered new interface driver uas
[    0.455478] usbcore: registered new interface driver usb-storage
[    0.457643] mousedev: PS/2 mouse device common for all mice
[    0.461777] goldfish_rtc 101000.rtc: registered as rtc0
[    0.463562] goldfish_rtc 101000.rtc: setting system clock to 2022-04-23T11:03:31 UTC (1650711811)
[    0.468228] sdhci: Secure Digital Host Controller Interface driver
[    0.469544] sdhci: Copyright(c) Pierre Ossman
[    0.470634] sdhci-pltfm: SDHCI platform and OF driver helper
[    0.472599] usbcore: registered new interface driver usbhid
[    0.473439] usbhid: USB HID core driver
[    0.476096] NET: Registered PF_INET6 protocol family
[    0.483021] Segment Routing with IPv6
[    0.484023] In-situ OAM (IOAM) with IPv6
[    0.484978] sit: IPv6, IPv4 and MPLS over IPv4 tunneling driver
[    0.488376] NET: Registered PF_PACKET protocol family
[    0.490567] 9pnet: Installing 9P2000 support
[    0.491812] Key type dns_resolver registered
[    0.495583] debug_vm_pgtable: [debug_vm_pgtable         ]: Validating architecture page table helpers
[    0.531253] Freeing unused kernel image (initmem) memory: 2152K
[    0.537076] Run /init as init process

Boot took 0.59 seconds

/bin/sh: can't access tty; job control turned off
/ #
```

