check "team_total" {
  assert {
    condition     = var.stud_count + var.work_count >= 1
    error_message = "Create at least one student or work team."
  }
}

locals {
  stud_teams = [for i in range(1, var.stud_count + 1) : "stud_team${i}-pwnbox"]
  work_teams = [for i in range(1, var.work_count + 1) : "work_team${i}-pwnbox"]
  teams      = concat(local.stud_teams, local.work_teams)
  players    = ["player1", "player2", "player3"]
  player_keys = toset(flatten([
    for team in local.teams : [
      for player in local.players : "${team}-${player}"
    ]
  ]))
}

resource "random_password" "player" {
  for_each = local.player_keys
  length   = 20
  special  = false
}

resource "hcloud_ssh_key" "deployer" {
  name       = "gctf-windows-deployer"
  public_key = var.ssh_public_key
}

resource "hcloud_firewall" "dockur" {
  name = "gctf-windows"

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "22"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "8006-8008"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "3389"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  rule {
    direction  = "in"
    protocol   = "udp"
    port       = "3389"
    source_ips = ["0.0.0.0/0", "::/0"]
  }
}

resource "hcloud_server" "pwnbox" {
  for_each     = toset(local.teams)
  name         = replace(each.key, "_", "-")
  server_type  = var.server_type
  image        = var.image
  location     = var.location
  ssh_keys     = [hcloud_ssh_key.deployer.id]
  firewall_ids = [hcloud_firewall.dockur.id]

  labels = {
    role = "gctf-windows"
    slug = each.key
  }

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  user_data = templatefile("${path.module}/cloud-init.yaml.tftpl", {
    slug            = each.key
    hostname        = replace(each.key, "_", "-")
    linux_image     = var.linux_image
    linux_boot      = var.linux_boot
    windows_image   = var.windows_image
    windows_version = var.windows_version
    linux_ram       = var.linux_ram
    windows_ram     = var.windows_ram
    linux_cpus      = var.linux_cpus
    windows_cpus    = var.windows_cpus
    linux_disk      = var.linux_disk
    windows_disk    = var.windows_disk
    passwords = [
      for player in local.players : random_password.player["${each.key}-${player}"].result
    ]
  })
}
