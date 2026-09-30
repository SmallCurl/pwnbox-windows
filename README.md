# Dockur desktops on Hetzner

22 team servers. Every server is the same: two Linux desktops and one Windows desktop.

| Players | Desktop | Image |
|---|---|---|
| player1, player2 | Ubuntu Desktop | `qemux/qemu` (Dockur Linux, `dockur/qemu`) |
| player3 | Windows 11 | `dockurr/windows` |

There is no `dockurr/linux` image. Linux uses the Dockur QEMU container, which downloads Ubuntu and opens a web viewer. Windows installs itself.

## Team names

| Group | Count | Slug |
|---|---|---|
| Student | 10 | `stud_team1-pwnbox` … `stud_team10-pwnbox` |
| Work | 12 | `work_team1-pwnbox` … `work_team12-pwnbox` |

Hetzner server names cannot contain `_`, so the cloud name is the slug with hyphens: `stud-team1-pwnbox`. The login sheet keeps the underscore slug.

## Setup

```bash
export HCLOUD_TOKEN='hetzner-read-write-token'
cd final-windows
```

The deploy script uses `~/.ssh/id_ed25519.pub` (or `id_rsa.pub`). Override with `SSH_PUBLIC_KEY_FILE`.

## Create the 22 teams

```bash
./scripts/deploy.sh          # plan only
./scripts/deploy.sh --yes    # create 10 student + 12 work servers
```

A smaller trial:

```bash
STUD_COUNT=1 WORK_COUNT=1 ./scripts/deploy.sh --yes
```

`cx52` (32 GB RAM, 320 GB disk) is the default. Each server keeps three 64 GB disks plus the Ubuntu and Windows downloads. Nested virtualization must be available (`/dev/kvm`).

First boot takes a while. Windows finishes on its own. Ubuntu waits in the web viewer for the installer.

```bash
./scripts/status.sh
./scripts/show-logins.sh
```

## How a player connects

| Player | Open | Login |
|---|---|---|
| player1 | `http://<ip>:8006` | Type the generated password during Ubuntu setup |
| player2 | `http://<ip>:8007` | Type the generated password during Ubuntu setup |
| player3 | `http://<ip>:8008` or RDP `<ip>:3389` | User `player3` and the generated password |

`show-logins.sh` writes the same list to `out/logins.txt`.

Shared files on the server live in `/opt/team-share`. Windows shows that folder as `Shared`.

## Ports

| Port | Use |
|---|---|
| 22 | SSH as root |
| 8006 | player1 Linux web viewer |
| 8007 | player2 Linux web viewer |
| 8008 | player3 Windows web viewer |
| 3389 | player3 Windows RDP |

## Tear down

```bash
export HCLOUD_TOKEN='...'
./scripts/destroy.sh --yes
```
