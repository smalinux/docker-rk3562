
Minimal yocto image for rk3562


HOWTo use this repo:

Build:
```
	git clone --recursive https://https://github.com/smalinux/docker-rk3562
	cd docker-rk3562
	./buildScript.sh
```

Deploy file:
```
	cd docker-rk3562/build/tmp/deploy/
	sudo bmaptool copy core-image-minimal-kickpi-k3.rootfs.wic /dev/sdX
```
