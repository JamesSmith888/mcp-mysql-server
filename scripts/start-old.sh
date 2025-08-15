#!/bin/bash
# Project Launcher with Auto JRE Download
# Supports macOS and Windows (Git Bash/MSYS2)
# Only downloads JRE (not full JDK) for smaller size

set -e

# Configuration
JAVA_VERSION=21
JRE_VENDOR="amazon-corretto"
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect OS and Architecture
detect_platform() {
    local os arch
    
    case "$(uname -s)" in
        Darwin*)
            os="mac"
            ;;
        CYGWIN*|MINGW*|MSYS*)
            os="windows"
            ;;
        Linux*)
            os="linux"
            ;;
        *)
            log_error "Unsupported operating system: $(uname -s)"
            exit 1
            ;;
    esac
    
    case "$(uname -m)" in
        x86_64|amd64)
            arch="x64"
            ;;
        aarch64|arm64)
            arch="aarch64"
            ;;
        *)
            log_error "Unsupported architecture: $(uname -m)"
            exit 1
            ;;
    esac
    
    echo "${os}-${arch}"
}

# Get JRE installation directory
get_jre_home() {
    local platform="$1"
    echo "${HOME}/.jres/${JRE_VENDOR}-jre-${JAVA_VERSION}-${platform}"
}

# Check if JRE is already installed and working
check_existing_jre() {
    local jre_home="$1"
    
    if [ ! -d "$jre_home" ]; then
        return 1
    fi
    
    local java_bin="$jre_home/bin/java"
    if [ ! -x "$java_bin" ]; then
        return 1
    fi
    
    # Test if Java works and has correct major version
    local java_version
    java_version=$("$java_bin" -version 2>&1 | head -n1)
    
    if echo "$java_version" | grep -q "version \"${JAVA_VERSION}"; then
        return 0
    elif echo "$java_version" | grep -q "version \"1\.${JAVA_VERSION}"; then
        # Handle old Java version format (1.8, etc)
        return 0
    else
        log_warn "Existing Java version mismatch: $java_version"
        log_warn "Expected version: $JAVA_VERSION"
        return 1
    fi
}

# Download and install JRE
download_jre() {
    local platform="$1"
    local jre_home="$2"
    local os="${platform%-*}"
    local arch="${platform#*-}"
    
    log_info "Downloading JRE ${JAVA_VERSION} for ${platform}..."
    
    # Create temp directory
    local tmp_dir
    tmp_dir=$(mktemp -d) || {
        log_error "Failed to create temporary directory"
        exit 1
    }
    
    # Cleanup on exit
    trap "rm -rf '$tmp_dir'" EXIT
    
    # Use Amazon Corretto which has reliable download URLs
    local download_url=""
    local archive_name=""
    
    case "$platform" in
        "mac-x64")
            download_url="https://corretto.aws/downloads/latest/amazon-corretto-${JAVA_VERSION}-x64-macos-jdk.tar.gz"
            archive_name="amazon-corretto-${JAVA_VERSION}-macos-x64.tar.gz"
            ;;
        "mac-aarch64")
            download_url="https://corretto.aws/downloads/latest/amazon-corretto-${JAVA_VERSION}-aarch64-macos-jdk.tar.gz"
            archive_name="amazon-corretto-${JAVA_VERSION}-macos-aarch64.tar.gz"
            ;;
        "windows-x64")
            download_url="https://corretto.aws/downloads/latest/amazon-corretto-${JAVA_VERSION}-x64-windows-jdk.zip"
            archive_name="amazon-corretto-${JAVA_VERSION}-windows-x64.zip"
            ;;
        "linux-x64")
            download_url="https://corretto.aws/downloads/latest/amazon-corretto-${JAVA_VERSION}-x64-linux-jdk.tar.gz"
            archive_name="amazon-corretto-${JAVA_VERSION}-linux-x64.tar.gz"
            ;;
        "linux-aarch64")
            download_url="https://corretto.aws/downloads/latest/amazon-corretto-${JAVA_VERSION}-aarch64-linux-jdk.tar.gz"
            archive_name="amazon-corretto-${JAVA_VERSION}-linux-aarch64.tar.gz"
            ;;
        *)
            log_error "Unsupported platform: $platform"
            exit 1
            ;;
    esac
    
    # Determine archive format
    local extract_cmd
    if [[ "$archive_name" == *.zip ]]; then
        extract_cmd="unzip -q"
    else
        extract_cmd="tar -xzf"
    fi
    
    local archive_path="$tmp_dir/$archive_name"
    
    # Download JRE with retry mechanism
    log_info "Downloading from: $download_url"
    
    local max_retries=3
    local retry_count=0
    
    while [ $retry_count -lt $max_retries ]; do
        retry_count=$((retry_count + 1))
        
        if [ $retry_count -gt 1 ]; then
            log_info "Retry attempt $retry_count of $max_retries..."
            sleep 2
        fi
        
        if command -v curl >/dev/null 2>&1; then
            if curl -L --fail --show-error --progress-bar --connect-timeout 30 --max-time 1800 -o "$archive_path" "$download_url"; then
                break
            fi
        elif command -v wget >/dev/null 2>&1; then
            if wget --progress=bar --timeout=30 --tries=1 -O "$archive_path" "$download_url"; then
                break
            fi
        else
            log_error "Neither curl nor wget is available for downloading JRE"
            exit 1
        fi
        
        if [ $retry_count -eq $max_retries ]; then
            log_error "Failed to download JRE after $max_retries attempts"
            log_info "You can manually download Java 21 from:"
            log_info "https://aws.amazon.com/corretto/"
            log_info "Or visit: https://adoptium.net/"
            exit 1
        fi
        
        log_warn "Download failed, retrying..."
        rm -f "$archive_path"
    done
    
    log_success "Download completed successfully"
    
    # Create JRE directory
    mkdir -p "$jre_home"
    
    # Extract JRE
    log_info "Extracting JRE to $jre_home..."
    
    if [[ "$archive_name" == *.zip ]]; then
        if ! command -v unzip >/dev/null 2>&1; then
            log_error "unzip command not found, required for Windows JRE extraction"
            exit 1
        fi
        unzip -q "$archive_path" -d "$tmp_dir"
    else
        tar -xzf "$archive_path" -C "$tmp_dir"
    fi
    
    # Find extracted directory and move contents
    local extracted_dir
    extracted_dir=$(find "$tmp_dir" -maxdepth 1 -type d -name "*corretto*" -o -name "*jdk*" -o -name "*jre*" | head -n1)
    
    if [ -z "$extracted_dir" ]; then
        log_error "Could not find extracted JRE directory"
        exit 1
    fi
    
    # Move contents to final location
    # For Amazon Corretto, we need the full JDK but we'll use it as JRE
    if [ -d "$extracted_dir/Contents/Home" ]; then
        # macOS .tar.gz format
        mv "$extracted_dir/Contents/Home"/* "$jre_home/"
    else
        # Standard format
        mv "$extracted_dir"/* "$jre_home/" 2>/dev/null || {
            cp -r "$extracted_dir"/* "$jre_home/" || {
                log_error "Failed to move JRE files to $jre_home"
                exit 1
            }
        }
    fi
    
    # Verify installation
    if [ ! -x "$jre_home/bin/java" ]; then
        log_error "JRE installation failed: java executable not found"
        exit 1
    fi
    
    log_success "JRE ${JAVA_VERSION} installed successfully"
}

# Check system Java first
check_system_java() {
    if command -v java >/dev/null 2>&1 && [ -n "${JAVA_HOME:-}" ]; then
        local java_version
        java_version=$(java -version 2>&1 | head -n1)
        
        # Extract major version number
        local major_version
        if echo "$java_version" | grep -q 'version "1\.'; then
            # Old format like "1.8.0_291"
            major_version=$(echo "$java_version" | sed 's/.*version "1\.\([0-9]*\).*/\1/')
        else
            # New format like "11.0.1", "17.0.1", "21.0.1"
            major_version=$(echo "$java_version" | sed 's/.*version "\([0-9]*\).*/\1/')
        fi
        
        # Check if major version is >= required version
        if [ -n "$major_version" ] && [ "$major_version" -ge "$JAVA_VERSION" ]; then
            log_success "Using system Java $major_version (meets requirement >= $JAVA_VERSION)"
            log_info "Java version: $java_version"
            return 0
        else
            log_info "System Java $major_version < required $JAVA_VERSION"
            return 1
        fi
    else
        log_info "No system Java found or JAVA_HOME not set"
        return 1
    fi
}

# Setup Java environment
setup_java() {
    # First check if system Java is suitable
    if check_system_java; then
        log_success "Java environment setup complete (using system Java)"
        return 0
    fi
    
    log_info "System Java not suitable, will download JRE ${JAVA_VERSION}"
    
    local platform
    platform=$(detect_platform)
    
    local jre_home
    jre_home=$(get_jre_home "$platform")
    
    log_info "Platform detected: $platform"
    log_info "JRE home: $jre_home"
    
    # Check if JRE is already installed
    if check_existing_jre "$jre_home"; then
        log_success "Using existing JRE at $jre_home"
    else
        # Remove corrupted installation if exists
        if [ -d "$jre_home" ]; then
            log_warn "Removing corrupted JRE installation"
            rm -rf "$jre_home"
        fi
        
        # Download and install JRE
        download_jre "$platform" "$jre_home"
    fi
    
    # Set JAVA_HOME for Maven
    export JAVA_HOME="$jre_home"
    
    # Add Java to PATH
    export PATH="$jre_home/bin:$PATH"
    
    # Verify Java installation
    log_info "Java version: $("$jre_home/bin/java" -version 2>&1 | head -n1)"
    log_success "Java environment setup complete"
}

# Main function
main() {
    log_info "Starting project launcher..."
    log_info "Required Java version: ${JAVA_VERSION}"
    
    # Setup Java environment
    setup_java
    
    # Check if mvnw exists
    local mvnw_script="$PROJECT_DIR/mvnw"
    if [ ! -f "$mvnw_script" ]; then
        log_error "Maven wrapper script not found: $mvnw_script"
        exit 1
    fi
    
    # Make mvnw executable if needed
    if [ ! -x "$mvnw_script" ]; then
        chmod +x "$mvnw_script"
    fi
    
    # Prepare Maven arguments with required parameters (hardcoded)
    local pom_file="$PROJECT_DIR/pom.xml"
    
    # Check if pom.xml exists
    if [ ! -f "$pom_file" ]; then
        log_error "pom.xml not found: $pom_file"
        exit 1
    fi
    
    # Build the complete Maven command with hardcoded parameters
    local maven_args=("-q" "-f" "$pom_file" "spring-boot:run")
    
    # Print the complete command that will be executed
    log_info "Executing command:"
    log_info "$mvnw_script -q -f $pom_file spring-boot:run"
    log_info "----------------------------------------"
    
    # Run Maven with hardcoded arguments
    exec "$mvnw_script" "${maven_args[@]}"
}

# Run main function (no arguments needed)
main
