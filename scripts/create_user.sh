#!/bin/bash
# create_user.sh
# Purpose: Safely create a new LInux user account, with basic validation.

# Check 1: Must be run as root/sudo
if [ "$EUID" -ne 0 ]; then
	echo "This script must be run as root. Try: sudo ./script.sh"
	exit 1
fi

# Check 2: Make sure something was actually typed
read -p "Enter username to create: " username

if [ -z "$username" ]; then
	echo "Error: No username entered."
	exit 1
fi

# Check 3: Make sure the user doesn't already exist
if id "$username" &>/dev/null; then
	echo "Error: User '$username' already exists."
	exit 1
else
	adduser "$username"
	echo "User '$username' created successfully."
fi
