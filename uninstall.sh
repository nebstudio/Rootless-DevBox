#!/usr/bin/env bash
set -uo pipefail # -e is removed to allow checking command results without exiting immediately

# Rootless-DevBox Uninstaller
#
# This script removes DevBox and related configurations installed by Rootless-DevBox install.sh.
# Repository: https://github.com/nebstudio/Rootless-DevBox

# Color definitions
BOLD="\033[1m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
RESET="\033[0m"
GREY="\033[90m"
CYAN="\033[0;36m"

# Echo with color
echo_color() {
  local color="$1"
  local text="$2"
  echo -e "${color}${text}${RESET}"
}

# Print a step header
print_step() {
  echo_color "$BLUE" "\n=> $1"
}

# Print success message
print_success() {
  echo_color "$GREEN" "✓ $1"
}

# Print warning message
print_warning() {
  echo_color "$YELLOW" "⚠ $1"
}

# Print error message (does not exit by default, caller decides)
print_error_msg() {
  echo_color "$RED" "✗ $1"
}

# Confirm action
confirm_action() {
  local prompt_message="$1"
  local response
  # Correctly use echo -n with color codes directly
  echo -e -n "${YELLOW}${prompt_message} [y/N]: ${RESET}"
  read -r response
  if [[ "$response" =~ ^[Yy]$ ]]; then
    return 0 # Yes
  else
    return 1 # No or anything else
  fi
}

remove_file_if_exists() {
  local file_path="$1"
  local file_description="$2"
  if [ -f "$file_path" ]; then
    if rm -f "$file_path"; then
      print_success "Removed $file_description: $file_path"
    else
      print_error_msg "Failed to remove $file_description: $file_path"
    fi
  else
    echo "$file_description not found at $file_path. Skipping."
  fi
}

main() {
  local local_bin_dir="${HOME}/.local/bin"
  local nix_dir="${HOME}/.nix"
  local bashrc_file="${HOME}/.bashrc"

  echo_color "$BOLD" "Rootless-DevBox Uninstaller"
  echo "This script will attempt to remove DevBox and related components"
  echo "installed by the Rootless-DevBox installer."
  echo "It will target files in '${local_bin_dir}' and configurations in '${bashrc_file}'."
  echo "The directory '${local_bin_dir}' itself will NOT be removed."
  echo ""

  if ! confirm_action "Are you sure you want to proceed with uninstallation?"; then
    echo_color "$YELLOW" "Uninstallation aborted by user."
    exit 0
  fi

  print_step "Removing installed files"
  remove_file_if_exists "${local_bin_dir}/devbox" "DevBox binary"
  remove_file_if_exists "${local_bin_dir}/nix-chroot" "nix-chroot script"
  remove_file_if_exists "${local_bin_dir}/nix-user-chroot" "nix-user-chroot binary"

  print_step "Processing ~/.bashrc configurations"
  if [ ! -f "$bashrc_file" ]; then
    print_warning "${bashrc_file} not found. Skipping .bashrc modifications."
  else
    # Check if any of our known lines/blocks exist before attempting modification
    if grep -qE '(# Added by Rootless-DevBox installer|export PATH="\$HOME/\.local/bin:\$PATH" # Added by Rootless-DevBox|# Rootless-DevBox nix-chroot environment indicator)' "$bashrc_file"; then
      local bashrc_backup="${HOME}/.bashrc.devbox_uninstall_$(date +%Y%m%d%H%M%S).bak"
      echo "Modifying ${bashrc_file} to remove Rootless-DevBox configurations."
      echo "Backing up current ${bashrc_file} to ${bashrc_backup}"
      if cp "${bashrc_file}" "${bashrc_backup}"; then
        print_success "Backup created: ${bashrc_backup}"

        # Use awk to remove the specific lines and blocks in a single pass
        # This reads from the backup and writes to the original .bashrc file
        awk '
        BEGIN {
            lines_to_skip = 0
        }
        # Rule for PATH comment
        /# Added by Rootless-DevBox installer/ { next }
        # Rule for PATH export
        /export PATH="\$HOME\/\.local\/bin:\$PATH" # Added by Rootless-DevBox/ { next }

        # Rule for PS1 block start
        /# Rootless-DevBox nix-chroot environment indicator/ {
            # This is the start of the 4-line block we want to remove,
            # matching how install.sh adds it.
            lines_to_skip = 4
        }

        # If we are skipping lines for the PS1 block
        lines_to_skip > 0 {
            lines_to_skip--
            next
        }

        # Default action: print the line
        { print }
        ' "${bashrc_backup}" > "${bashrc_file}"

        print_success "${bashrc_file} has been processed."
        echo "Please review ${bashrc_file} to ensure changes are correct."
        echo "If anything went wrong, the backup is available at: ${bashrc_backup}"
        echo "You may need to run 'source ${bashrc_file}' or open a new terminal for changes to take effect."
      else
        print_error_msg "Failed to create backup of ${bashrc_file}. Skipping .bashrc modifications."
      fi
    else
      echo "No Rootless-DevBox specific configurations found in ${bashrc_file}."
    fi
  fi

  print_step "Optionally removing Nix directory"
  if [ -d "$nix_dir" ]; then
    echo "The directory ${nix_dir} was used by Rootless-DevBox for Nix."
    echo "This directory may contain cached Nix derivations and other Nix-related data."
    if confirm_action "Do you want to remove the directory ${nix_dir}?"; then
      if rm -rf "${nix_dir}"; then
        print_success "Removed directory: ${nix_dir}"
      else
        print_error_msg "Failed to remove directory: ${nix_dir}. Please remove it manually if desired."
      fi
    else
      echo "Skipped removal of ${nix_dir}."
    fi
  else
    echo "Nix directory ${nix_dir} not found. Skipping."
  fi

  echo ""
  print_success "Rootless-DevBox uninstallation process complete."
  echo "Please check any output above for details or manual steps required."
  echo "If you had sourced changes from ~/.bashrc, you might need to open a new terminal"
  echo "or re-source your ~/.bashrc for all changes to fully apply."
}

# Run the main function
main "$@"
exit 0