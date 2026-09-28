#!/usr/bin/env bash
set -euo pipefail

BUCKET_NAME="${BUCKET_NAME:?set BUCKET_NAME to a globally unique lowercase name}"
SA_NAME="${SA_NAME:-bulletins-s3}"
FOLDER_ID="$(yc config get folder-id)"

if ! yc iam service-account get --name "$SA_NAME" >/dev/null 2>&1; then
  yc iam service-account create --name "$SA_NAME"
fi
SA_ID="$(yc iam service-account get --name "$SA_NAME" --format json | python3 -c 'import json,sys; print(json.load(sys.stdin)["id"])')"

if ! yc storage bucket get --name "$BUCKET_NAME" >/dev/null 2>&1; then
  yc storage bucket create --name "$BUCKET_NAME"
fi

yc resource-manager folder add-access-binding "$FOLDER_ID" \
  --role storage.editor \
  --subject "serviceAccount:${SA_ID}"

echo "Service account and bucket are ready."
echo "Create the static key manually (the secret is shown only once):"
echo "  yc iam access-key create --service-account-name ${SA_NAME}"
