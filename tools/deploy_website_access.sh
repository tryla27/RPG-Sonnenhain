set -euo pipefail
umask 077
install -d -m 700 "$HOME/.ssh"
trap 'rm -f "$HOME/.ssh/manitu_deploy" "$HOME/.ssh/manitu_deploy.pub"' EXIT
python3 - <<'PY'
import base64
import os
from pathlib import Path

raw = os.environ["MANITU_SSH_KEY"].replace("\r", "").strip()
if "BEGIN OPENSSH PRIVATE KEY" in raw:
    key = raw.replace("\\n", "\n")
else:
    try:
        decoded = base64.b64decode("".join(raw.split()), validate=True)
        key = decoded.decode("utf-8").replace("\r", "").strip()
    except Exception as exc:
        raise SystemExit("MANITU_SSH_KEY is neither a valid OpenSSH private key nor valid Base64: %s" % exc)

if "BEGIN OPENSSH PRIVATE KEY" not in key or "END OPENSSH PRIVATE KEY" not in key:
    raise SystemExit("Decoded MANITU_SSH_KEY does not contain a complete OpenSSH private key")

Path.home().joinpath(".ssh/manitu_deploy").write_text(key.strip() + "\n", encoding="utf-8")
PY
chmod 600 "$HOME/.ssh/manitu_deploy"
ssh-keygen -y -f "$HOME/.ssh/manitu_deploy" > "$HOME/.ssh/manitu_deploy.pub"
echo "Deploy key fingerprint:"
ssh-keygen -lf "$HOME/.ssh/manitu_deploy.pub"
echo "Deploy public key (safe to copy to Manitu):"
cat "$HOME/.ssh/manitu_deploy.pub"

ssh -4 -i "$HOME/.ssh/manitu_deploy" -p 22 \
  -o IdentitiesOnly=yes -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=12 \
  ssh300011111@ngcobalt378.manitu.net \
  'echo "SSH OK"; id; uname -a; printf "systemctl="; command -v systemctl || true; printf "nohup="; command -v nohup || true; printf "python3="; command -v python3 || true'

target=/home/sites/site100047525/web/htdocs/sonnenhainrpg.de
ssh -4 -i "$HOME/.ssh/manitu_deploy" -p 22 \
  -o IdentitiesOnly=yes -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=12 \
  ssh300011111@ngcobalt378.manitu.net "mkdir -p '$target' /home/sites/site100047525/web/sonnenhain-access-data; chmod 770 /home/sites/site100047525/web/sonnenhain-access-data"

access_file=/home/sites/site100047525/web/sonnenhain-access.htpasswd
if [ -n "${SONNENHAIN_ACCESS_HTPASSWD:-}" ]; then
  entry="$SONNENHAIN_ACCESS_HTPASSWD"
  if [[ "$entry" != *:* ]]; then
    entry="sonnenhain:$entry"
  fi
  printf '%s\n' "$entry" > /tmp/sonnenhain-access.htpasswd
  chmod 600 /tmp/sonnenhain-access.htpasswd
  scp -4 -i "$HOME/.ssh/manitu_deploy" -o IdentitiesOnly=yes -o BatchMode=yes -o StrictHostKeyChecking=accept-new /tmp/sonnenhain-access.htpasswd ssh300011111@ngcobalt378.manitu.net:"$access_file"
  rm -f /tmp/sonnenhain-access.htpasswd
else
  # Normal deploys must never reset the live password to the repository fixture.
  ssh -4 -i "$HOME/.ssh/manitu_deploy" -o IdentitiesOnly=yes -o BatchMode=yes -o StrictHostKeyChecking=accept-new ssh300011111@ngcobalt378.manitu.net "test -s '$access_file'"
fi
ssh -4 -i "$HOME/.ssh/manitu_deploy" -o IdentitiesOnly=yes -o BatchMode=yes -o StrictHostKeyChecking=accept-new ssh300011111@ngcobalt378.manitu.net "chmod 640 '$access_file'"


scp -4 -i "$HOME/.ssh/manitu_deploy" -o IdentitiesOnly=yes -o BatchMode=yes -o StrictHostKeyChecking=accept-new website/access/access.php ssh300011111@ngcobalt378.manitu.net:"$target/access.php"
scp -4 -i "$HOME/.ssh/manitu_deploy" -o IdentitiesOnly=yes -o BatchMode=yes -o StrictHostKeyChecking=accept-new website/access/site.htaccess ssh300011111@ngcobalt378.manitu.net:"$target/.htaccess"
ssh -4 -i "$HOME/.ssh/manitu_deploy" -o IdentitiesOnly=yes -o BatchMode=yes -o StrictHostKeyChecking=accept-new ssh300011111@ngcobalt378.manitu.net "chmod 660 '$target/access.php' '$target/.htaccess'"
