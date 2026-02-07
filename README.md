# orin-nano-support
Scripts and code to support the Orin Nano Developer kit

# NVIDIA Jetson Linux
The current release is [R36.5.0](https://developer.nvidia.com/embedded/jetson-linux-r365), which has a default Ubuntu 22.04 rootfs.


# Usage
The scripts in this repo were used on Ubuntu 24.04.
* Install the host dependencies
  * ```sudo apt install -y abootimg binfmt-support binutils cpio cpp device-tree-compiler dosfstools iproute2 iputils-ping lbzip2 libxml2-utils netcat nfs-kernel-server openssl python3-yaml qemu-user-static rsync sshpass udev uuid-runtime whois xmlstarlet zstd lz4```
* Make a copy of the release variables, and edit username and password.
  * Example: `cp r3643.sh myconfig.sh`
* Setup the rootfs and SDK with `nano-cli.py`
  * `bash nano-cli.sh --download --rootfs --config=myconfig.sh`
* Install your NVME ssd to the board. Disconnect display and any peripherals on the USB-A ports.
* Put the board into forced recovery and connect its USB-C port to the host.
* Check that `0955:7523 NVIDIA Corp. APX` appears, with `lsusb`
* Disconnect the jumper used to put the board into forced recovery mode.
* Flash the board.
  * `bash nano-cli.sh --flash --config=myconfig.sh`
* Something will probably go wrong, so continue on to troubleshooting below...

# Using the Jetson pypi index
NVIDIA publishes builds of various ML packages and depedencies. They are compatible with the
Jetson's system python interpreter.

When using this in the future, be sure to adjust the URL to match your cuda version,
for instance `jp6/cu126` for CUDA 12.6, `jp/cu122` for CUDA 12.2
```
export PIP_INDEX_URL=http://jetson.webredirect.org/jp6/cu126
export PIP_TRUSTED_HOST=jetson.webredirect.org

pip3 install torch torchvision torchaudio numpy==1.26.4
```
I set exact version for numpy as I otherwise get a warning when importing torch.

See [this forum post](https://forums.developer.nvidia.com/t/jetson-ai-lab-ml-devops-containers-core-inferencing/288235/3).

# Troubleshooting
Flashing the devkit can be kind of finicky, here are some workarounds for issues I've encountered.
To see what's wrong, you'll probably need a USB-UART at some point to plug into the board's debug console (under the module, same block where forced recovery jumper is)

### USB error
If flashing fails and you have a USB Error
```ERROR: might be timeout in USB write.```

Try disabling autosuspend on the host, AND replugging the Orin with the jumper set to put it in forced recovery. This change to the host is temporary, and lost after rebooting.
```
sudo -s
echo -1 > /sys/module/usbcore/parameters/autosuspend
```

Swapping the USB-C cable or host port may solve some other unexplained issues.
I tried several different USB-C cables before initrd flash worked, and switching to the motherboard's rear-io type-C port instead of the case header may have also made a difference.

### Initrd fails with something about not being able to reach the host NFS server
* Swap cables around as mentioned above
* Setup relies on NFS to transfer some files from the host after it reboots board. You may need to manually open the default port for NFS, or temporarily disable firewall.
* Make sure IPv6 is enabled. IIRC Older L4T releases used `192.168.55.1` for this purpose, but now the flasher uses `fc00:1:1::/48`

### Setup can't complete after board boots up.
* Make sure that you have removed the jumper for forced recovery, so that the board is trying to boot normally.

### Board never tries to boot, always enters forced recovery.
I got stuck in this state once, just try flashing again normally.
Not entirely sure what caused it but I possibly the bootloader was erased and flasher was interrupted before it was replaced.
