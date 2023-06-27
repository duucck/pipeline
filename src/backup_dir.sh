#!/bin/bash

# Default values
backup_name=""
num_backups_to_keep=5

# Function to print script usage
print_usage() {
    echo "Usage: $0 -h remote_host -u remote_username [-p remote_password] -d remote_directory [--name backup_name] [-n num_backups_to_keep] local_directory"
    echo "Parameters:"
    echo "  -h remote_host          : The IP address or hostname of the remote host"
    echo "  -u remote_username      : The username for connecting to the remote host"
    echo "  -p remote_password      : [Optional] The password(Single quote wrapped) for connecting to the remote host. If not provided, it will be prompted interactively."
    echo "  -d remote_directory     : The directory on the remote host to backup"
    echo "  --name backup_name      : [Optional] The name of the backup file. If not provided, it will be generated based on the directory name and current date/time."
    echo "  -n num_backups_to_keep  : [Optional] The number of backups to keep. Default is 5."
    echo "  local_directory        : The local directory to store the backup file"
}

# Check if sshpass is installed and install it if missing
check_sshpass() {
    if [ -n "$remote_password" ] && ! command -v sshpass >/dev/null; then
        echo "sshpass is not installed."
        if [[ -x "$(command -v apt)" ]]; then
            echo "Installing sshpass..."
            sudo apt update
            sudo apt install -y sshpass
            echo "sshpass has been installed successfully."
        else
            echo "Please install sshpass manually or use this script without -p parameter."
            exit 1
        fi
    fi
}

# Parse command-line options
while getopts ":h:u:p:d:n:-:" opt; do
    case $opt in
        h)
            remote_host=$OPTARG
            ;;
        u)
            remote_username=$OPTARG
            ;;
        p)
            remote_password=$OPTARG
            ;;
        d)
            remote_directory=$OPTARG
            ;;
        -)
            case ${OPTARG} in
                name)
                    backup_name=$2
                    shift
                    ;;
                *)
                    print_usage
                    exit 1
                    ;;
            esac
            ;;
        n)
            num_backups_to_keep=$OPTARG
            ;;
        \?)
            print_usage
            exit 1
            ;;
    esac
done

# Shift the command-line options to process the local directory argument
shift $((OPTIND - 1))

# Check if all required parameters are provided
if [[ -z $remote_host || -z $remote_username || -z $remote_directory || -z $1 ]]; then
    print_usage
    exit 1
fi

local_directory=$1

# Function to perform the backup
perform_backup() {
    # Create a temporary directory to store the backup files
    tmp_directory=$(mktemp -d)

    # Generate backup name if not provided
    if [ -z "$backup_name" ]; then
        current_date=$(date +%Y-%m-%d_%H-%M-%S)
        directory_name=$(basename "$remote_directory")
        backup_name="${directory_name}_${current_date}.tar.gz"
    fi

    # Create the backup using tar and gzip
    if [ -z "$remote_password" ]; then
        ssh "$remote_username@$remote_host" "tar -czf - '$remote_directory'" | cat > "$tmp_directory/$backup_name"
    else
        sshpass -p "$remote_password" ssh "$remote_username@$remote_host" "tar -czf - '$remote_directory'" | cat > "$tmp_directory/$backup_name"
    fi

    # Create the local directory if it does not exist
    mkdir -p "$local_directory"
    # Move the backup file to the specified local directory
    mv "$tmp_directory/$backup_name" "$local_directory"

    # Clean up the temporary directory
    rm -rf "$tmp_directory"

    echo "Compressed DONE."
}

# Function to delete expired backup files
delete_expired_backups() {
    # Change to the backup directory
    cd "$local_directory" || exit 1

    # List all backup files in the directory, sorted by modification time in reverse order
    backup_files=($(ls -t *.tar.gz))

    # Delete all backup files except the latest n files
    for ((i = $num_backups_to_keep; i < ${#backup_files[@]}; i++)); do
        echo "delete ${backup_files[i]} (expired)"
        rm "${backup_files[i]}"
    done
}

# Main script

# Check if sshpass is installed
check_sshpass

# Perform the backup
perform_backup

# Delete expired backup files
delete_expired_backups
