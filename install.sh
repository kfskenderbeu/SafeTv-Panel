#!/usr/bin/env bash
# SafeTV panel - online installer. This repository holds only this installer; the programs are downloaded from its Releases (compiled, licensed).
#
#   curl -fsSL https://raw.githubusercontent.com/kfskenderbeu/SafeTv-Panel/main/install.sh | sudo bash -s -- --public-host YOUR.IP.OR.DOMAIN
#   ./install.sh --remote root@HOST --public-host HOST          (installs on another server over SSH)
#
# Options of its own:  --version X.Y.Z (default: latest)   --repo OWNER/NAME   --package FILE|URL (use this tarball instead of downloading)
# Every other option goes to the package installer (admin user/pass, ports, database, --ffmpeg, --no-service ...): run with --help after download to see them.
set -euo pipefail
REPO="${SAFETV_REPO:-kfskenderbeu/SafeTv-Panel}"; VERSION=latest; PACKAGE=""; REMOTE=""; PASS=(); SSH_OPTS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --version) VERSION="$2"; shift 2 ;; --repo) REPO="$2"; shift 2 ;; --package) PACKAGE="$2"; shift 2 ;;
    --remote|--ssh-port|--ssh-key) PASS+=("$1" "$2"); shift 2 ;;
    --no-db-install|--ffmpeg|--no-service|--no-start|--dry-run) PASS+=("$1"); shift ;;
    -h|--help) PASS+=("$1"); shift ;;
    *) PASS+=("$1" "$2"); shift 2 ;;
  esac
done
command -v curl >/dev/null || { echo "error: curl is needed" >&2; exit 1; }
W="$(mktemp -d)"; trap 'rm -rf "$W"' EXIT
if [[ -z "$PACKAGE" ]]; then
  if [[ "$VERSION" == latest ]]; then BASE="https://github.com/$REPO/releases/latest/download"; else BASE="https://github.com/$REPO/releases/download/v${VERSION#v}"; fi
  echo "==> downloading $BASE/safetv-linux-x86_64.tar.gz"
  curl -fL --retry 3 -o "$W/p.tar.gz" "$BASE/safetv-linux-x86_64.tar.gz" || { echo "error: download failed (is there a release in $REPO?)" >&2; exit 1; }
  curl -fsL -o "$W/p.sha256" "$BASE/safetv-linux-x86_64.tar.gz.sha256" || { echo "error: checksum file missing" >&2; exit 1; }
  [[ "$(sha256sum "$W/p.tar.gz" | cut -d' ' -f1)" == "$(cut -d' ' -f1 "$W/p.sha256")" ]] || { echo "error: checksum mismatch" >&2; exit 1; }
elif [[ "$PACKAGE" == http* ]]; then curl -fL -o "$W/p.tar.gz" "$PACKAGE"
else cp "$PACKAGE" "$W/p.tar.gz"; fi
mkdir "$W/x"; tar xzf "$W/p.tar.gz" -C "$W/x" --strip-components=1
exec bash "$W/x/install.sh" "${PASS[@]}"
