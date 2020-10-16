cp project-spec/configs/rootfs_config project-spec/configs/rootfs_config.old

sed -i 's/# CONFIG_dnf is not set/CONFIG_dnf=y/g' project-spec/configs/rootfs_config
sed -i 's/# CONFIG_e2fsprogs-resize2fs is not set/CONFIG_e2fsprogs-resize2fs=y/g' project-spec/configs/rootfs_config
sed -i 's/# CONFIG_parted is not set/CONFIG_parted=y/g' project-spec/configs/rootfs_config
sed -i 's/# CONFIG_xrt-dev is not set/CONFIG_xrt-dev=y/g' project-spec/configs/rootfs_config
sed -i 's/# CONFIG_mesa-megadriver is not set/CONFIG_mesa-megadriver=y/g' project-spec/configs/rootfs_config
sed -i 's/# CONFIG_packagegroup-petalinux-matchbox is not set/CONFIG_packagegroup-petalinux-matchbox=y/g' project-spec/configs/rootfs_config
sed -i 's/# CONFIG_packagegroup-petalinux-opencv is not set/CONFIG_packagegroup-petalinux-opencv=y/g' project-spec/configs/rootfs_config
sed -i 's/# CONFIG_packagegroup-petalinux-opencv-dev is not set/CONFIG_packagegroup-petalinux-opencv-dev=y/g' project-spec/configs/rootfs_config
sed -i 's/# CONFIG_packagegroup-petalinux-self-hosted is not set/CONFIG_packagegroup-petalinux-self-hosted=y/g' project-spec/configs/rootfs_config
sed -i 's/# CONFIG_packagegroup-petalinux-v4lutils is not set/CONFIG_packagegroup-petalinux-v4lutils=y/g' project-spec/configs/rootfs_config
sed -i 's/# CONFIG_packagegroup-petalinux-vitisai is not set/CONFIG_packagegroup-petalinux-vitisai=y/g' project-spec/configs/rootfs_config
sed -i 's/# CONFIG_packagegroup-petalinux-vitisai-dev is not set/CONFIG_packagegroup-petalinux-vitisai-dev=y/g' project-spec/configs/rootfs_config
sed -i 's/# CONFIG_packagegroup-petalinux-x11 is not set/CONFIG_packagegroup-petalinux-x11=y/g' project-spec/configs/rootfs_config
sed -i 's/# CONFIG_packagegroup-petalinux-xrt is not set/CONFIG_packagegroup-petalinux-xrt=y/g' project-spec/configs/rootfs_config
#sed -i 's/# CONFIG_cmake is not set/CONFIG_cmake=y/g' project-spec/configs/rootfs_config
#sed -i 's/# CONFIG_opencl-clhpp-dev is not set/CONFIG_opencl-clhpp-dev=y/g' project-spec/configs/rootfs_config
#sed -i 's/# CONFIG_opencl-headers-dev is not set/CONFIG_opencl-headers-dev=y/g' project-spec/configs/rootfs_config
echo 'CONFIG_cmake=y' >> project-spec/configs/rootfs_config
echo 'CONFIG_opencl-clhpp-dev=y' >> project-spec/configs/rootfs_config
echo 'CONFIG_opencl-headers-dev=y' >> project-spec/configs/rootfs_config

