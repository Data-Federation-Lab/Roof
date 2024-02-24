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

# Function to download Debian OS image if it doesn't exist
download_debian_bookworm_os_image() {
    if [ ! -f "debian-12.4.0-arm64-netinst.iso" ]; then
        log "Debian OS image not found. Downloading..."
        curl -L -O https://cdimage.debian.org/debian-cd/current/arm64/iso-cd/debian-12.4.0-arm64-netinst.iso || { log_error "Download failed"; exit 1; }
        chmod 777 debian-12.4.0-arm64-netinst.iso
    else
        log "Debian OS image found."
    fi
}

download_qemu_efi_firmware() {
    if [ ! -f "QEMU_EFI.fd" ]; then
        log "QEMU EFI firmware not found. Downloading..."
        curl -L -O https://releases.linaro.org/components/kernel/uefi-linaro/16.02/release/qemu64/QEMU_EFI.fd
    else
        log "QEMU EFI firmware found."
    fi
}

# Main script starts here

# Check for QEMU installation
check_qemu || install_qemu

download_qemu_efi_firmware

download_debian_bookworm_os_image

virtual_hard_disk_file="CompileEnvVM.qcow2"
# Check if the file exists
if [ -f "$virtual_hard_disk_file" ]; then
    log "$virtual_hard_disk_file found."
else
    log "Creating $virtual_hard_disk_file..."
    qemu-img create -f qcow2 "$virtual_hard_disk_file" 10G
    if [ -f "$virtual_hard_disk_file" ]; then
        log "$virtual_hard_disk_file created successfully."
    else
        log_error "Error: $virtual_hard_disk_file was not created."
    fi
fi

log "Starting the Compile Environment VM..."

if [ "$1" == "install" ]; then
    log "Installing Debian OS..."
    qemu-system-aarch64 \
        -M virt \
        -cpu cortex-a53 \
        -smp 4 \
        -m 2048 \
        -drive file=$virtual_hard_disk_file,if=virtio \
        -net nic \
        -net user \
        -bios QEMU_EFI.fd \
        -cdrom debian-12.4.0-arm64-netinst.iso \
        -boot d \
        -nographic
else
    log "Booting from existing Debian OS..."
    qemu-system-aarch64 \
        -M virt \
        -cpu cortex-a53 \
        -smp 4 \
        -m 2048 \
        -drive file=$virtual_hard_disk_file,if=virtio \
        -netdev user,id=net0,hostfwd=tcp::5023-:22 \
        -device virtio-net,netdev=net0 \
        -boot d \
        -bios QEMU_EFI.fd \
        -nographic
fi