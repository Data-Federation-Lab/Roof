# Setup Guide for RoofCompileEnvVM

This README provides step-by-step instructions for setting up a virtual machine environment tailored for development with Debian, .NET, GCC, and Git. It includes setting up SSH keys for GitHub to work with the Roof repository.

## Prerequisites
- Internet connection for downloading necessary software and packages.

## Installation Steps

### 1. Install the Operating System

1. Open your terminal.
2. Navigate to the directory containing `RunVM.sh`.
3. Execute the script to install the OS (this may take approximately 30 minutes):
    ```bash
    ./RunVM.sh install
    ```

### 2. Boot the Virtual Machine

After installation, run the following command to start the VM:
```bash
./RunVM.sh
```

### 3. Configure Boot Loader

Once the VM starts, follow these instructions to configure the boot loader for Debian:
```bash
fs0:
cd EFI
mkdir BOOT
cd debian 
cp grubaa64.efi fs0:\EFI\BOOT\BOOTAA64.EFI
reset
```

### 4. Install .NET SDK

To install the .NET SDK, execute the following commands:
```bash
wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh
chmod +x ./dotnet-install.sh
./dotnet-install.sh
```

Set the .NET environment variables:
```bash
export DOTNET_ROOT=$HOME/.dotnet
export PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools
```

### 5. Install Additional Tools

Switch to root and install GCC and zlib:
```bash
su root
apt-get install gcc && apt-get install zlib1g-dev
```

Clean up installation scripts:
```bash
rm dotnet-install.sh
```

Update and install Git:
```bash
apt update && apt upgrade && apt install git --yes
```

### 6. Configure Git

Set your Git user name and email:
```bash
git config --global user.name "Your Name"
git config --global user.email "youremail@example.com"
```

### 7. Setup SSH Keys for GitHub

Generate a new SSH key:
```bash
ssh-keygen -t ed25519 -C "youremail@example.com"
```

Start the SSH agent and add your SSH key:
```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

### 8. Add SSH Key to GitHub

1. Copy your SSH public key:
    ```bash
    cat ~/.ssh/id_ed25519.pub
    ```
2. Navigate to [GitHub SSH settings](https://github.com/settings/ssh/new) and add your new SSH key with the title `RoofCompileEnvVM`.

### 9. Verify SSH Connection to GitHub

Test your SSH connection:
```bash
ssh -T git@github.com
```

### 10. Clone and Setup the Roof Repository

Fork the Roof repository by navigating to [Roof repository](https://github.com/Data-Federation-Lab/Roof/fork).

Clone your forked repository:
```bash
git clone git@github.com:YourUsername/Roof.git
```

Navigate to the Roof directory:
```bash
cd Roof
```

You are now set up and ready to compile the Roof and RApps!

---

Remember to replace placeholders like `"Your Name"`, `"youremail@example.com"`, and `"YourUsername"` with your actual GitHub username, email, and other personal information. This guide aims to be straightforward, ensuring users can follow along without prior knowledge of the tools and processes described.