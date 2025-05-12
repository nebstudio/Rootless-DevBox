#!/usr/bin/env bash
set -euo pipefail

# Rootless-DevBox Installer
# 
# This script automates the installation of DevBox in a rootless environment
# using nix-user-chroot without requiring root privileges.
#
# Repository: https://github.com/nebstudio/Rootless-DevBox

# Color definitions
BOLD="\033[1m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
RESET="\033[0m"
GREY="\033[90m" # Added GREY color
CYAN="\033[0;36m" # Added CYAN color

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

# Print error message
print_error() {
  echo_color "$RED" "✗ $1"
  exit 1
}

# Check if the system supports user namespaces (required for nix-user-chroot)
check_user_namespace_support() {
  print_step "Checking system compatibility"
  echo "Verifying if your system supports unprivileged user namespaces (required for nix-user-chroot)..."
  
  if ! unshare --user --pid echo "YES" &>/dev/null; then
    print_error "Your system does not support unprivileged user namespaces, which is required for nix-user-chroot to work.

This can happen in:
- Older Linux kernels
- Systems with user namespaces disabled
- Containerized environments like Docker or GitHub Codespaces

Please run this script on a compatible Linux system, or use an alternative installation method.
For more information, see: https://github.com/nix-community/nix-user-chroot"
  fi
  print_success "System supports unprivileged user namespaces"
}

# Detect system architecture
get_architecture() {
  local arch=$(uname -m)
  
  case "$arch" in
    x86_64)
      echo "x86_64-unknown-linux-musl"
      ;;
    aarch64|arm64)
      echo "aarch64-unknown-linux-musl"
      ;;
    armv7*)
      echo "armv7-unknown-linux-musleabihf"
      ;;
    i686|i386)
      echo "i686-unknown-linux-musl"
      ;;
    *)
      print_error "Unsupported architecture: $arch"
      ;;
  esac
}

# Download a file with progress
download_file() {
  local url="$1"
  local output_file="$2"
  
  if command -v curl &>/dev/null; then
    curl -fsSL "$url" -o "$output_file" || return 1
  elif command -v wget &>/dev/null; then
    wget -q "$url" -O "$output_file" || return 1
  else
    print_error "Neither curl nor wget found. Please install one of them and try again."
  fi
}

# Create temporary directory for installation files
create_temp_dir() {
  mktemp -d 2>/dev/null || print_error "Failed to create temporary directory"
}

# Main installation process
main() {
  local local_bin_dir="${HOME}/.local/bin"
  local nix_dir="${HOME}/.nix"
  local nix_user_chroot_version="1.2.2"
  local arch=$(get_architecture)
  local temp_dir=$(create_temp_dir)
  
  echo_color "$BOLD" "Rootless-DevBox Installer"
  echo "This script will install DevBox in a rootless environment."
  echo "It will make changes only to your user environment and will not require root permissions."
  echo ""
  
  # Check if the system supports user namespaces (required for nix-user-chroot)
  check_user_namespace_support
  
  # Step 1: Create ~/.local/bin directory
  print_step "Creating local bin directory"
  if [ -d "$local_bin_dir" ]; then
    echo "Directory $local_bin_dir already exists."
  else
    mkdir -p "$local_bin_dir"
    print_success "Created directory $local_bin_dir"
  fi

  # Create Nix directory if it doesn't exist
  print_step "Creating Nix directory ${nix_dir}"
  if [ -d "$nix_dir" ]; then
    echo "Directory $nix_dir already exists."
  else
    mkdir -p "$nix_dir"
    print_success "Created directory $nix_dir"
  fi
  
  # Step 2: Download nix-user-chroot
  print_step "Downloading nix-user-chroot"
  local nix_user_chroot_filename="nix-user-chroot-bin-${nix_user_chroot_version}-${arch}"
  local nix_user_chroot_url="https://github.com/nix-community/nix-user-chroot/releases/download/${nix_user_chroot_version}/${nix_user_chroot_filename}"
  local nix_user_chroot_path="${local_bin_dir}/nix-user-chroot"
  
  echo "Architecture detected: ${arch}"
  echo "Downloading from: ${nix_user_chroot_url}"
  
  if ! download_file "$nix_user_chroot_url" "$nix_user_chroot_path"; then
    print_error "Failed to download nix-user-chroot. Please check your internet connection and try again."
  fi
  
  chmod +x "$nix_user_chroot_path"
  print_success "nix-user-chroot downloaded and made executable"
  
  # Step 3: Create nix-chroot script
  print_step "Installing nix-chroot script"
  local nix_chroot_path_in_bin="${local_bin_dir}/nix-chroot"
  
  cat > "$nix_chroot_path_in_bin" <<EOF
#!/bin/bash
exec \${HOME}/.local/bin/nix-user-chroot \${HOME}/.nix env NIX_CHROOT=1 bash -l
EOF
  
  chmod +x "$nix_chroot_path_in_bin"
  print_success "Created nix-chroot script at ${nix_chroot_path_in_bin}"
  
  # Step 4: Install DevBox (create install script)
  print_step "Preparing DevBox installation"
  
  local devbox_install_script="${temp_dir}/devbox_install_user.sh"
  
  cat > "$devbox_install_script" <<'EOF'
#!/bin/bash
#
# Install script
#
# Downloads and installs a binary from the given url.

set -euo pipefail

# ========================
# Customize install script
# ========================

readonly INSTALL_DIR="${HOME}/.local/bin"
readonly BIN="devbox"
readonly DOWNLOAD_URL="https://releases.jetify.com/devbox"

readonly TITLE="Devbox 📦 by Jetify (User Install)"
readonly DESCRIPTION=$(
    cat <<EOD
  Instant, easy and predictable development environments.

  This script downloads and installs the latest devbox binary to your user directory.
EOD
)
readonly DOCS_URL="https://github.com/jetify-com/devbox"
readonly COMMUNITY_URL="https://discord.gg/jetify"

FORCE="${FORCE:-0}"

parse_flags() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
        -f | --force)
            FORCE=1
            shift 1
            ;;
        *)
            error "Unknown option: $1"
            exit 1
            ;;
        esac
    done
}

readonly BOLD="$(tput bold 2>/dev/null || echo '')"
readonly GREY="$(tput setaf 8 2>/dev/null || echo '')"
readonly UNDERLINE="$(tput smul 2>/dev/null || echo '')"
readonly RED="$(tput setaf 1 2>/dev/null || echo '')"
readonly GREEN="$(tput setaf 2 2>/dev/null || echo '')"
readonly YELLOW="$(tput setaf 3 2>/dev/null || echo '')"
readonly BLUE="$(tput setaf 4 2>/dev/null || echo '')"
readonly MAGENTA="$(tput setaf 5 2>/dev/null || echo '')"
readonly CYAN="$(tput setaf 6 2>/dev/null || echo '')"
readonly NO_COLOR="$(tput sgr0 2>/dev/null || echo '')"
readonly CLEAR_LAST_MSG="\033[1F\033[0K"

title() {
    local -r text="$*"
    printf "%s\n" "${BOLD}${MAGENTA}${text}${NO_COLOR}"
}

header() {
    local -r text="$*"
    printf "%s\n" "${BOLD}${text}${NO_COLOR}"
}

plain() {
    local -r text="$*"
    printf "%s\n" "${text}"
}

info() {
    local -r text="$*"
    printf "%s\n" "${BOLD}${GREY}→${NO_COLOR} ${text}"
}

warn() {
    local -r text="$*"
    printf "%s\n" "${YELLOW}! $*${NO_COLOR}"
}

error() {
    local -r text="$*"
    printf "%s\n" "${RED}✘ ${text}${NO_COLOR}" >&2
}

success() {
    local -r text="$*"
    printf "%s\n" "${GREEN}✓${NO_COLOR} ${text}"
}

start_task() {
    local -r text="$*"
    printf "%s\n" "${BOLD}${GREY}→${NO_COLOR} ${text}..."
}

end_task() {
    local -r text="$*"
    printf "${CLEAR_LAST_MSG}%s\n" "${GREEN}✓${NO_COLOR} ${text}... [DONE]"
}

fail_task() {
    local -r text="$*"
    printf "${CLEAR_LAST_MSG}%s\n" "${RED}✘ ${text}... [FAILED]${NO_COLOR}" >&2
}

confirm() {
    if [ ${FORCE-} -ne 1 ]; then
        printf "%s " "${MAGENTA}?${NO_COLOR} $* ${BOLD}[Y/n]${NO_COLOR}"
        set +e
        read -r yn </dev/tty
        rc=$?
        set -e
        if [ $rc -ne 0 ]; then
            error "Error reading from prompt (re-run with '-f' flag to auto select Yes if running in a script)"
            exit 1
        fi
        if [ "$yn" != "y" ] && [ "$yn" != "Y" ] && [ "$yn" != "yes" ] && [ "$yn" != "" ]; then
            error 'Aborting (please answer "yes" to continue)'
            exit 1
        fi
    fi
}

delay() {
    sleep 0.3
}

has() {
    command -v "$1" 1>/dev/null 2>&1
}

download() {
    local -r url="$1"
    local -r file="$2"
    local cmd=""

    if has curl; then
        cmd="curl --fail --silent --location --output $file $url"
    elif has wget; then
        cmd="wget --quiet --output-document=$file $url"
    elif has fetch; then
        cmd="fetch --quiet --output=$file $url"
    else
        error "No program to download files found. Please install one of: curl, wget, fetch"
        error "Exiting..."
        return 1
    fi

    if [[ ${3:-} == "--fail" ]]; then
        $cmd && return 0 || rc=$?
        error "Command failed (exit code $rc): ${BLUE}${cmd}${NO_COLOR}"
        exit $rc
    fi

    $cmd && return 0 || rc=$?
    return $rc
}

intro_msg() {
    title "${TITLE}"
    plain "${DESCRIPTION}"
    printf "\n"
    header "Confirm Installation Details"
    plain "  Location:     ${GREEN}${INSTALL_DIR}/${BIN}${NO_COLOR}"
    plain "  Download URL: ${UNDERLINE}${BLUE}${DOWNLOAD_URL}${NO_COLOR}"
    printf "\n"
}

install_flow() {
    confirm "Install ${GREEN}${BIN}${NO_COLOR} to ${GREEN}${INSTALL_DIR}${NO_COLOR}?"
    printf "\n"
    header "Downloading and Installing"

    start_task "Downloading ${BIN} binary"
    local -r tmp_file=$(mktemp)
    download "${DOWNLOAD_URL}" "${tmp_file}" --fail
    delay
    end_task "Downloading ${BIN} binary"

    start_task "Installing in ${INSTALL_DIR}/${BIN}"
    chmod +x "${tmp_file}"
    mkdir -p "${INSTALL_DIR}"
    mv "${tmp_file}" "${INSTALL_DIR}/${BIN}"
    delay
    end_task "Installing in ${INSTALL_DIR}/${BIN}"
    delay

    success "${BOLD}Successfully installed ${GREEN}${BIN}${NO_COLOR}${BOLD}${NO_COLOR} 🚀"
    delay
    printf "\n"
    if [[ ":$PATH:" != *":${INSTALL_DIR}:"* ]]; then
        warn "NOTE: You may need to add ${INSTALL_DIR} to your PATH."
        plain "  You can do this by adding the following line to your shell configuration file (e.g., ~/.bashrc, ~/.zshrc):"
        plain "  export PATH=\"${INSTALL_DIR}:\$PATH\""
        plain "  Then, source the file (e.g., source ~/.bashrc) or open a new terminal."
        printf "\n"
    fi
}

next_steps_msg() {
    header "Next Steps"
    plain "  1. ${BOLD}Learn how to use ${BIN}${NO_COLOR}"
    plain "     ${GREY}Run ${CYAN}${BIN} help${GREY} or read the docs at ${UNDERLINE}${BLUE}${DOCS_URL}${NO_COLOR}"
    plain "  2. ${BOLD}Get help and give feedback${NO_COLOR}"
    plain "     ${GREY}Join our community at ${UNDERLINE}${BLUE}${COMMUNITY_URL}${NO_COLOR}"
}

main() {
    parse_flags "$@"
    intro_msg
    install_flow
    next_steps_msg
}

main "$@"
EOF
  
  chmod +x "$devbox_install_script"
  print_success "Created DevBox installation script: ${devbox_install_script}"
  
  echo ""
  echo_color "$BOLD" "Next: Activate Nix Environment and Install DevBox"
  echo "You now need to enter the nix-chroot environment and then run the DevBox installer script."
  echo "The commands are:"
  echo_color "$YELLOW" "    1. ${local_bin_dir}/nix-chroot"
  echo_color "$YELLOW" "    2. (Inside nix-chroot) ${devbox_install_script}"
  echo ""
  echo "Would you like this script to attempt to run '${local_bin_dir}/nix-chroot' for you now? [Y/n]"
  echo_color "$GREY" "(If you choose yes, after nix-chroot starts, you MUST MANUALLY run the second command: ${devbox_install_script})"
  read -r response
  response=${response:-y}
  
  if [[ "$response" =~ ^[Yy] ]]; then
    echo ""
    echo_color "$CYAN" "Attempting to start ${local_bin_dir}/nix-chroot..."
    echo "Once the new shell starts (you might see a prompt like '(nix-chroot) ...'),"
    echo "remember to run the following command MANUALLY:"
    echo_color "$YELLOW" "    ${devbox_install_script}"
    echo ""
    echo "Press Enter to continue and execute ${local_bin_dir}/nix-chroot..."
    read -r
    if [ ! -x "${local_bin_dir}/nix-chroot" ]; then
        print_error "${local_bin_dir}/nix-chroot not found or not executable. Please check previous steps."
    fi
    exec "${local_bin_dir}/nix-chroot" 
    print_error "Failed to execute ${local_bin_dir}/nix-chroot. Please run it manually as instructed above."
    exit 1 
  else
    echo ""
    echo_color "$YELLOW" "Okay, proceeding with manual installation guidance."
    echo "Please perform the following steps in your terminal:"
    echo "1. Run the nix-chroot environment. If '${local_bin_dir}' is not yet in your active PATH,"
    echo "   you can add it for your current session with 'export PATH=\"${local_bin_dir}:\$PATH\"' or use the full path:"
    echo_color "$CYAN" "     ${local_bin_dir}/nix-chroot"
    echo "2. Once inside the nix-chroot environment (e.g., you see '(nix-chroot)' in your prompt),"
    echo "   run the DevBox installer script:"
    echo_color "$CYAN" "     ${devbox_install_script}"
    echo ""
    echo "After you have successfully completed BOTH steps above, would you like this script"
    echo "to attempt to configure your ~/.bashrc for future use? (Adds ${local_bin_dir} to PATH and a prompt indicator) [y/N]"
    read -r configure_bashrc
    if [[ "$configure_bashrc" =~ ^[Yy] ]]; then
      print_step "Configuring environment variables in ~/.bashrc"
      
      local bashrc_modified_count=0
      if ! grep -qF 'export PATH="$HOME/.local/bin:$PATH" # Added by Rootless-DevBox' ~/.bashrc; then
        echo '' >> ~/.bashrc
        echo '# Added by Rootless-DevBox installer' >> ~/.bashrc
        echo 'export PATH="$HOME/.local/bin:$PATH" # Added by Rootless-DevBox' >> ~/.bashrc
        echo "Added ~/.local/bin to PATH in ~/.bashrc"
        ((bashrc_modified_count++))
      else
        echo "~/.local/bin PATH entry by Rootless-DevBox already in ~/.bashrc."
      fi
      
      if ! grep -qF '# Rootless-DevBox nix-chroot environment indicator' ~/.bashrc; then
        echo '' >> ~/.bashrc 
        cat >> ~/.bashrc <<EOF
# Rootless-DevBox nix-chroot environment indicator
if [ "\$NIX_CHROOT" = "1" ]; then
  PS1="(nix-chroot) \[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\\\$ "
fi
EOF
        echo "Added nix-chroot environment indicator to ~/.bashrc"
        ((bashrc_modified_count++))
      else
        echo "nix-chroot environment indicator already in ~/.bashrc."
      fi
      
      if [ "$bashrc_modified_count" -gt 0 ]; then
        print_success "Configuration changes applied to ~/.bashrc."
        echo "Please run 'source ~/.bashrc' or open a new terminal for these changes to take full effect."
      else
        print_success "~/.bashrc already contains the necessary configurations or no changes were made."
      fi
      echo ""
      echo_color "$GREEN" "DevBox setup process is complete!"
      echo "To use DevBox: "
      echo "1. Start the environment: '${local_bin_dir}/nix-chroot' (or 'nix-chroot' if PATH is set from new shell)"
      echo "2. Then use 'devbox' commands."
    else
      echo_color "$YELLOW" "Configuration of ~/.bashrc skipped as per your choice."
      echo "Please ensure '${local_bin_dir}' is in your PATH for 'nix-chroot' and 'devbox' to work easily."
      echo "You might want to manually add:"
      echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
      echo "to your ~/.bashrc (or equivalent shell configuration file)."
    fi
  fi
  
  echo ""
  echo "If you encounter any issues, please report them at: https://github.com/nebstudio/Rootless-DevBox/issues"
  echo "If this script was helpful, please consider giving a Star on GitHub! ⭐"
}

main "$@"
