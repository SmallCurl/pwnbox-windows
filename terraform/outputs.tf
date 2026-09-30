output "addresses" {
  description = "Team slug to public IPv4."
  value = {
    for slug, srv in hcloud_server.pwnbox : slug => srv.ipv4_address
  }
}

output "teams" {
  description = "Web and RDP endpoints plus player passwords."
  sensitive   = true
  value = {
    for slug, srv in hcloud_server.pwnbox : slug => {
      ipv4     = srv.ipv4_address
      hostname = replace(slug, "_", "-")
      ssh      = "ssh root@${srv.ipv4_address}"
      players = {
        player1 = {
          os       = "linux"
          web      = "http://${srv.ipv4_address}:8006"
          password = random_password.player["${slug}-player1"].result
        }
        player2 = {
          os       = "linux"
          web      = "http://${srv.ipv4_address}:8007"
          password = random_password.player["${slug}-player2"].result
        }
        player3 = {
          os       = "windows"
          user     = "player3"
          web      = "http://${srv.ipv4_address}:8008"
          rdp      = "${srv.ipv4_address}:3389"
          password = random_password.player["${slug}-player3"].result
        }
      }
    }
  }
}
