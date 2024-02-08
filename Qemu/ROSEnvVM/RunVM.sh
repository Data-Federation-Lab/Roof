#!/bin/bash

# Define log function
log() {
    # ANSI green
    GREEN="\033[0;32m"
    # ANSI no color (reset)
    NC="\033[0m"
    echo -e "${GREEN}$1${NC}"
}

# Define log_error function
log_error() {
    # ANSI red
    RED="\033[0;31m"
    # ANSI no color (reset)
    NC="\033[0m"
    echo -e "${RED}$1${NC}"
}


# Function to check if QEMU is installed
check_qemu() {
    if ! command -v qemu-system-aarch64 &> /dev/null; then
        return 1
    else
        log "QEMU is installed."
        return 0
    fi
}

# Function to install QEMU
install_qemu() {
    log "QEMU is not installed. Attempting to install..."

    # Determine OS and install accordingly
    case "$(uname -s)" in
        Linux)
            sudo apt-get update && sudo apt-get install -y qemu qemu-user qemu-user-static || \
            sudo yum install -y qemu qemu-user qemu-user-static
            ;;
        Darwin)
            brew install qemu
            ;;
        *)
            log_error "Unsupported OS. Please install QEMU manually."
            exit 1
            ;;
    esac
}

# Function to download Raspberry Pi OS Lite if it doesn't exist
download_rpi_os_lite() {
    if [ ! -f "2023-12-11-raspios-bookworm-arm64-lite.img.xz" ]; then
        log "Raspberry Pi OS Lite image not found. Downloading..."
        curl -O https://downloads.raspberrypi.com/raspios_lite_arm64/images/raspios_lite_arm64-2023-12-11/2023-12-11-raspios-bookworm-arm64-lite.img.xz
    else
        log "Raspberry Pi OS Lite packed image found."
    fi
}

# Main script starts here

# Check for QEMU installation
check_qemu || install_qemu

# Download Raspberry Pi OS Lite if necessary
download_rpi_os_lite

# Extract the image
rpi_os_lite_unpacked="2023-12-11-raspios-bookworm-arm64-lite.img"
xz_file="${rpi_os_lite_unpacked}.xz"
# Check if the .img file already exists
if [ -f "$rpi_os_lite_unpacked" ]; then
    log "Raspberry Pi OS Lite unpacked image found."
else
    # Check if the .xz archive exists
    if [ -f "$xz_file" ]; then
        log "Extracting the Raspberry Pi OS Lite image..."
        unxz -k "$xz_file"
        log "Extraction complete."
        chmod 777 "$rpi_os_lite_unpacked"
    else
        log_error "The archive $xz_file does not exist. Please make sure the file is in the current directory."
    fi
fi

dtb_file="bcm2710-rpi-3-b.dtb"
kernel_file="kernel8.img"
mount_point="${PWD}/raspios" # Temporary mount directory

# Check if both files exist
if [[ -f "$dtb_file" && -f "$kernel_file" ]]; then
    log "$dtb_file and $kernel_file found."
else
    # Create mount point
    log "Creating mount point at $mount_point..."
    mkdir $mount_point

    # Mount the image
    log "Mounting $rpi_os_lite_unpacked..."
    #sudo mount -t vfat -o loop,offset=0 "$rpi_os_lite_unpacked" "$mount_point"
    image_FAT32_partition=$(sudo hdiutil attach -imagekey diskimage-class=CRawDiskImage -nomount $rpi_os_lite_unpacked | grep Windows_FAT_32 | awk '{print $1}')
    sudo mount -t msdos "$image_FAT32_partition" "$mount_point"

    # Check and copy files if they do not exist
    if [ ! -f "$dtb_file" ]; then
        if [ -f "$mount_point/$dtb_file" ]; then
            log "Copying $dtb_file..."
            sudo cp "$mount_point/$dtb_file" .
        else
            log_error "$dtb_file not found in the image."
        fi
    fi

    if [ ! -f "$kernel_file" ]; then
        if [ -f "$mount_point/$kernel_file" ]; then
            log "Copying $kernel_file..."
            sudo cp "$mount_point/$kernel_file" .
        else
            log_error "$kernel_file not found in the image."
        fi
    fi

    # Detach the FAT32 partition
    sudo hdiutil detach $image_FAT32_partition

    # Unmount the image
    log "Unmounting $image_FAT32_partition..."
    sudo umount $mount_point

    # Remove mount point
    log "Removing mount point at $mount_point..."
    rmdir $mount_point
fi

virtual_usb_file="10GB_USB.img"
# Check if the file exists
if [ -f "$virtual_usb_file" ]; then
    log "$virtual_usb_file found."
else
    log "Creating $virtual_usb_file..."
    qemu-img create -f qcow2 "$virtual_usb_file" 10G
    if [ -f "$virtual_usb_file" ]; then
        log "$virtual_usb_file created successfully."
    else
        log_error "Error: $virtual_usb_file was not created."
    fi
fi

# Check if the file exists
if [ -f "$rpi_os_lite_unpacked" ]; then
    # Get the current file size in bytes
    current_size=$(stat -c %s "$rpi_os_lite_unpacked" 2>/dev/null || stat -f %z "$rpi_os_lite_unpacked" 2>/dev/null)
    
    # Define the threshold in bytes for 32GB, directly for comparison
    threshold=$((32 * 1024**3)) # 32GB in bytes

    # Compare the current file size with the 32GB threshold
    if [ "$current_size" -lt "$threshold" ]; then
        log "Resizing $rpi_os_lite_unpacked to 32G..."
        qemu-img resize "$rpi_os_lite_unpacked" 32G
        log "$rpi_os_lite_unpacked resized successfully to 32G."
    else
        log "$rpi_os_lite_unpacked is already at or exceeds the required size of 32G. No resizing needed."
    fi
else
    log_error "File $rpi_os_lite_unpacked does not exist."
fi

# Run QEMU VM
log "Starting the ROS Environment VM..."

qemu-system-aarch64 \
    -M raspi3b \
    -cpu cortex-a53 \
    -smp 4 \
    -m 1G \
    -kernel kernel8.img \
    -dtb bcm2710-rpi-3-b.dtb \
    -sd 2023-12-11-raspios-bookworm-arm64-lite.img \
    -append "root=/dev/mmcblk0p2 rw rootwait rootfstype=ext4 mem=512M" \
    -usbdevice keyboard \
    -device usb-net,netdev=net0 \
    -netdev user,id=net0,hostfwd=tcp::5022-:22 \
    -drive if=none,id=stick,format=qcow2,file=10GB_USB.img \
    -device usb-storage,drive=stick
