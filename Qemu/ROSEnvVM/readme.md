# ROSEnvVM Setup Guide

This guide outlines the process of setting up a virtual machine (VM) that emulates the Raspberry Pi Zero 2 W hardware. This environment is ideal for testing Roof and RApps without needing the physical hardware. Follow the steps below to configure your VM from scratch, install Raspberry Pi OS, resize the file system, format and mount a virtual USB drive, and set up Git for version control.

## Prerequisites
- Internet connection.

## Step 1: Start the VM and Install Raspberry Pi OS
1. Run `./RunVM.sh` from your terminal to start the VM.
2. After the GUI loads, press `Alt+X` or `Option+X` to clear terminal logs.
3. Install Raspberry Pi OS following the on-screen instructions.

## Step 2: Resizing the Partition
After the Raspberry Pi OS installation:

1. Boot into Raspberry Pi OS.
2. Open a terminal and execute `sudo raspi-config`.
3. Navigate to **Advanced Options** > **Expand File System**.
4. Select it and reboot your VM when prompted.

## Step 3: Formatting and Mounting the Virtual USB Drive
1. Open a terminal and run `sudo mkfs.ext4 /dev/sda` to format the USB drive with the ext4 filesystem.
2. Confirm the operation by pressing `Enter`.
3. Create a mount point with `sudo mkdir /mnt/usb`.
4. Mount the virtual USB drive using `sudo mount /dev/sda /mnt/usb`.
5. Verify the drive is mounted correctly with `df -h`.

## Step 4: Git Installation
Install Git using `sudo apt install git --yes`.

## Step 5: Git Configuration and SSH Key Setup
1. Configure Git with your username and email:

   ```sh
   git config --global user.name "Your Name"
   git config --global user.email "youremail@example.com"
   ```

2. Generate a new SSH key for GitHub:

   ```sh
   ssh-keygen -t ed25519 -C "youremail@example.com"
   ```

3. Start the SSH agent and add your SSH key:

   ```sh
   eval "$(ssh-agent -s)"
   ssh-add ~/.ssh/id_ed25519
   ```

4. Display your public SSH key:

   ```sh
   cat ~/.ssh/id_ed25519.pub
   ```

5. Copy the terminal output (SSH key).

## Step 6: Adding SSH Key to GitHub
1. Navigate to [GitHub SSH settings](https://github.com/settings/ssh/new).
2. Click **New SSH key** and title it **ROSEnvVM**.
3. Paste your SSH key and click **Add SSH key**.

## Step 7: Testing SSH Connection and Cloning Your Repo
1. Test your SSH connection to GitHub:

   ```sh
   ssh -T git@github.com
   ```

2. Clone your repository:

   ```sh
   git clone git@github.com:YourUsername/YourCompiledAppRepoName.git
   ```

3. Change directory to your cloned repo:
   ```sh
   cd YourCompiledAppRepoName
   ```

## Conclusion
You've successfully set up a VM that emulates a Raspberry Pi Zero 2 W, installed and configured Raspberry Pi OS, and prepared your development environment for testing Roof and RApps. This setup allows for a flexible and efficient development workflow, enabling you to develop and test applications in a simulated Raspberry Pi environment.

--- 

Replace placeholders like "Your Name", "youremail@example.com", and "YourUsername/YourCompiledAppRepoName.git" with your actual GitHub name, email, and repository details. This guide assumes that you are familiar with navigating GitHub and managing SSH keys.