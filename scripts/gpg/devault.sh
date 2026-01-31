#!/bin/bash
set -euo pipefail

print_usage() {
	cat <<EOF
Usage: $0 <command> [args]

Commands:
	install                 Install GnuPG if not present
	encrypt <in> [out] [recipient]
						Encrypt file. If recipient is provided uses public-key
						encryption, otherwise uses symmetric encryption.
	decrypt <in> [out]      Decrypt file to output path (defaults to <in>.decrypted)
	import-key <keyfile>    Import a private OpenPGP key (armored PEM) into the local GPG keyring
						Accepts files containing a "BEGIN PGP PRIVATE KEY BLOCK" and runs `gpg --import`.
						If the file is a raw PEM RSA/PKCS key (BEGIN RSA PRIVATE KEY / BEGIN PRIVATE KEY)
						the script will not convert it; see comments in the script for guidance.
	help                    Show this message
EOF
}

install_gpg() {
	if command -v gpg >/dev/null 2>&1; then
		echo "gpg is already installed: $(gpg --version | head -n1)"
		return 0
	fi

	if command -v brew >/dev/null 2>&1; then
		echo "Installing gnupg via brew..."
		brew install gnupg
	elif command -v apt-get >/dev/null 2>&1; then
		echo "Installing gnupg via apt-get..."
		sudo apt-get update && sudo apt-get install -y gnupg
	elif command -v yum >/dev/null 2>&1; then
		echo "Installing gnupg via yum..."
		sudo yum install -y gnupg
	else
		echo "Could not find a supported package manager. Please install GnuPG manually: https://gnupg.org" >&2
		return 1
	fi

	echo "GnuPG Version:"
	gpg --version
}

encrypt_file() {
	local infile="$1"
	local outfile="${2:-}" 
	local recipient="${3:-}"

	if [ ! -f "$infile" ]; then
		echo "Input file not found: $infile" >&2
		return 2
	fi

	if [ -z "$outfile" ]; then
		outfile="${infile}.gpg"
	fi

	if [ -n "$recipient" ]; then
		echo "Encrypting $infile for recipient '$recipient' -> $outfile"
		gpg --output "$outfile" --encrypt --recipient "$recipient" "$infile"
	else
		echo "Symmetric encrypting $infile -> $outfile"
		gpg --output "$outfile" --symmetric "$infile"
	fi

	echo "Encrypted: $outfile"
}

import_private_key() {
	local keyfile="$1"

	if [ ! -f "$keyfile" ]; then
		echo "Key file not found: $keyfile" >&2
		return 2
	fi

	if grep -q "BEGIN PGP PRIVATE KEY BLOCK" "$keyfile" 2>/dev/null; then
		echo "Importing OpenPGP private key from $keyfile"
		gpg --import "$keyfile"
		echo "Import complete. To set trust: gpg --edit-key <keyid> trust quit"
		return 0
	fi

	if grep -q "BEGIN RSA PRIVATE KEY" "$keyfile" 2>/dev/null || grep -q "BEGIN PRIVATE KEY" "$keyfile" 2>/dev/null; then
		echo "The file appears to be a raw PEM (RSA/PKCS) private key, not an OpenPGP key." >&2
		echo "Automatic conversion to OpenPGP format is not supported by this script." >&2
		echo "If you have an OpenPGP-armored key, re-run with that file. Otherwise create an OpenPGP key pair with gpg and import or use tools to wrap the key appropriately." >&2
		return 3
	fi

	echo "Unrecognized key format in $keyfile" >&2
	return 4
}

decrypt_file() {
	local infile="$1"
	local outfile="${2:-}"

	if [ ! -f "$infile" ]; then
		echo "Encrypted file not found: $infile" >&2
		return 2
	fi

	if [ -z "$outfile" ]; then
		# default to stripping .gpg or appending .decrypted
		if [[ "$infile" == *.gpg ]]; then
			outfile="${infile%.gpg}"
		else
			outfile="${infile}.decrypted"
		fi
	fi

	echo "Decrypting $infile -> $outfile"
	gpg --output "$outfile" --decrypt "$infile"

	echo "Decrypted: $outfile"
}

if [ ${#@} -eq 0 ]; then
	print_usage
	exit 1
fi

cmd="$1"; shift || true

case "$cmd" in
	install)
		install_gpg
		;;
	encrypt)
		if [ ${#@} -lt 1 ]; then
			echo "encrypt requires at least an input file" >&2
			print_usage
			exit 1
		fi
		encrypt_file "$@"
		;;
	decrypt)
		if [ ${#@} -lt 1 ]; then
			echo "decrypt requires at least an input file" >&2
			print_usage
			exit 1
		fi
		decrypt_file "$@"
		;;
    import-key)
        if [ ${#@} -lt 1 ]; then
            echo "import-key requires a key file path" >&2
            print_usage
            exit 1
        fi
        import_private_key "$@"
        ;;
	help|-h|--help)
		print_usage
		;;
	*)
		echo "Unknown command: $cmd" >&2
		print_usage
		exit 2
		;;
esac
