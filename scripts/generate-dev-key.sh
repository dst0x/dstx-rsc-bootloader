#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
PROJECT_DIR=$(dirname -- "$SCRIPT_DIR")
PRIVATE_KEY="$PROJECT_DIR/keys/dev-signing-private.pem"
PUBLIC_KEY="$PROJECT_DIR/keys/dev-signing-public.pem"

: "${RSC_BOOT_PYTHON:?RSC_BOOT_PYTHON is required}"
: "${RSC_BOOT_IMGTOOL:?RSC_BOOT_IMGTOOL is required}"

if [ -f "$PRIVATE_KEY" ] && [ -f "$PUBLIC_KEY" ]; then
	exit 0
fi

if [ -e "$PRIVATE_KEY" ] || [ -e "$PUBLIC_KEY" ]; then
	echo "Refusing to overwrite an incomplete development key pair." >&2
	exit 1
fi

mkdir -p "$PROJECT_DIR/keys"
"$RSC_BOOT_PYTHON" "$RSC_BOOT_IMGTOOL" keygen \
	-k "$PRIVATE_KEY" -t ecdsa-p256
"$RSC_BOOT_PYTHON" "$RSC_BOOT_IMGTOOL" getpub \
	-k "$PRIVATE_KEY" -e pem -o "$PUBLIC_KEY"
chmod 600 "$PRIVATE_KEY"
echo "Generated development signing key pair."

