# Rootless-DevBox

A simple, automated solution for installing Devbox in a rootless environment without requiring sudo or root privileges.

![GitHub](https://img.shields.io/github/license/nebstudio/Rootless-DevBox)
![GitHub stars](https://img.shields.io/github/stars/nebstudio/Rootless-DevBox)
![GitHub issues](https://img.shields.io/github/issues/nebstudio/Rootless-DevBox)

## What is Rootless-DevBox?

Rootless-DevBox is a project that enables users to install and use [Devbox](https://github.com/jetify-com/devbox) in environments where they don't have root access, such as shared hosting, university systems, or corporate environments with restricted permissions. It leverages [nix-user-chroot](https://github.com/nix-community/nix-user-chroot) to create a containerized environment where Nix and Devbox can run without requiring elevated privileges.

## Features

- 🛡️ **No Root Required**: Install and use Devbox without sudo or root privileges
- 🔄 **Isolated Environment**: Run packages in a contained environment without affecting the system
- 🚀 **Easy Setup**: One script to set up everything automatically
- 💻 **Cross-Platform**: Works on various Linux distributions and architectures
- 🔒 **Safe**: Only modifies your user environment, not system files

## Quick Start

Simply run this command in your terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/nebstudio/Rootless-DevBox/main/install.sh | bash
```

Or download and run manually:

```bash
# Download the installer
curl -o rootless-devbox-installer.sh https://raw.githubusercontent.com/nebstudio/Rootless-DevBox/main/install.sh

# Make it executable
chmod +x rootless-devbox-installer.sh

# Run the installer
./rootless-devbox-installer.sh
```

## How it Works

Rootless-DevBox sets up your environment in 3 main steps:

1. **Install nix-user-chroot**: Downloads and configures a tool that creates a userspace chroot environment
2. **Create nix environment**: Sets up a containerized Nix environment in your user directory
3. **Install Devbox**: Installs Devbox within this environment so you can use it without root

After installation, you'll access your development environment using the `nix-chroot` command, which activates the isolated environment where Devbox is available.

## Usage

### Entering the Nix Environment

After installation, enter the Nix environment by running:

```bash
nix-chroot
```

You'll see your prompt change to indicate you're in the nix-chroot environment:

```
(nix-chroot) user@hostname:~$
```

### Using Devbox

Once inside the nix-chroot environment, you can use Devbox normally:

```bash
# Show help
devbox help

# Initialize a new project
devbox init

# Add packages
devbox add nodejs python

# Start a shell with your development environment
devbox shell
```

### Exiting the Environment

To exit the nix-chroot environment:

```bash
exit
```

## Requirements

- Linux-based operating system
- Bash shell
- Internet connection
- No root access needed!

## Supported Architectures

- x86_64
- aarch64/arm64
- armv7
- i686/i386

## Troubleshooting

### Common Issues

**Q: I get "command not found" when trying to use nix-chroot.**  
A: Make sure `~/.local/bin` is in your PATH. Try running `source ~/.bashrc` or restarting your terminal.

**Q: Installation fails when downloading nix-user-chroot.**  
A: Check your internet connection. If the issue persists, try manually downloading the appropriate binary from [the releases page](https://github.com/nix-community/nix-user-chroot/releases).

**Q: I can't install packages in the nix environment.**  
A: Some systems have quotas or disk space limitations. Check your available space with `df -h ~`.

For more troubleshooting help, please [open an issue](https://github.com/nebstudio/Rootless-DevBox/issues).

## Uninstalling

If you need to remove Rootless-DevBox from your system, you have two options:

### Option 1: Using the Uninstall Script

We provide an uninstall script that can remove most components:

```bash
# Download the uninstaller
curl -o rootless-devbox-uninstaller.sh https://raw.githubusercontent.com/nebstudio/Rootless-DevBox/main/uninstall.sh

# Make it executable
chmod +x rootless-devbox-uninstaller.sh

# Run the uninstaller
./rootless-devbox-uninstaller.sh
```

### Option 2: Manual Uninstallation (Recommended)

For more control over the uninstallation process, you can manually remove components:

1. **Remove the installed binaries**:
   ```bash
   rm -f ~/.local/bin/devbox
   rm -f ~/.local/bin/nix-chroot
   rm -f ~/.local/bin/nix-user-chroot
   ```

2. **Clean up the Nix directory** (optional, removes all Nix packages):
   ```bash
   rm -rf ~/.nix
   ```

3. **⚠️ IMPORTANT: Edit your shell configuration file** (`~/.bashrc`, `~/.zshrc`, etc.):
   
   **Strongly recommended**: Manually inspect and remove the following additions rather than relying on automated cleanup:
   
   - Remove the PATH modification line:
     ```bash
     export PATH="$HOME/.local/bin:$PATH" # Added by Rootless-DevBox
     ```
   
   - Remove the PS1 prompt modification block:
     ```bash
     # Rootless-DevBox nix-chroot environment indicator
     if [ "$NIX_CHROOT" = "1" ]; then
       PS1="(nix-chroot) \[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "
     fi
     ```

   After editing, apply the changes:
   ```bash
   source ~/.bashrc  # or your specific shell config file
   ```

> **Note**: While the uninstall script attempts to safely edit your shell configuration file, **manually inspecting and removing the specific lines** is safest to prevent unintended modifications to your environment variables.

After uninstallation, you may need to open a new terminal session for all changes to take effect.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add some amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

## Acknowledgements

This project wouldn't be possible without these amazing projects:

- [nix-user-chroot](https://github.com/nix-community/nix-user-chroot) - For providing the ability to run Nix as a non-root user
- [Devbox](https://github.com/jetify-com/devbox) - For creating an excellent development environment tool
- [Nix](https://nixos.org/) - For the powerful package management system underlying it all

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Security Considerations

Rootless-DevBox only modifies files within your user's home directory and doesn't require or use root privileges. It's designed to be safe to use even in restricted environments.

---

⭐ If this project helped you, please consider giving it a star on GitHub! ⭐

Created with ❤️ by [nebstudio](https://github.com/nebstudio)