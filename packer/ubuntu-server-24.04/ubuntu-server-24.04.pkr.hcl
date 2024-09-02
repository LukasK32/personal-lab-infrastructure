packer {
  required_plugins {
    proxmox = {
      version = "~> 1.1.8"
      source  = "github.com/hashicorp/proxmox"
    }

    ansible = {
      version = "~> 1.1.1"
      source = "github.com/hashicorp/ansible"
    }
  }
}

variable "proxmox_api_url" {
  type = string
}

variable "proxmox_api_token_id" {
  type = string
}

variable "proxmox_api_token_secret" {
  type      = string
  sensitive = true
}

variable "proxmox_node" {
  type = string
}

variable "proxmox_storage_iso" {
  type = string
}

variable "proxmox_storage_template" {
  type = string
}

variable "ssh_authorized_key" {
  type = string
}

source "proxmox-iso" "ubuntu-server" {
  # Connection to Proxmox
  proxmox_url = "${var.proxmox_api_url}"
  node        = "${var.proxmox_node}"
  username    = "${var.proxmox_api_token_id}"
  token       = "${var.proxmox_api_token_secret}"

  # VM Options
  template_name = "ubuntu-server-24.04"
  qemu_agent    = true
  cloud_init    = false

  cores           = "2"
  memory          = "4096"
  scsi_controller = "virtio-scsi-single"

  disks {
    storage_pool = "${var.proxmox_storage_template}"
    disk_size    = "16G"
    ssd          = true
    discard      = true
    cache_mode   = "none"
  }

  network_adapters {
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = "false"
  }

  # Installer's ISO
  iso_url          = "https://releases.ubuntu.com/24.04.1/ubuntu-24.04.1-live-server-amd64.iso"
  iso_checksum     = "sha256:e240e4b801f7bb68c20d1356b60968ad0c33a41d00d828e74ceb3364a0317be9"
  iso_storage_pool = "${var.proxmox_storage_iso}"
  iso_download_pve = true
  unmount_iso      = true

  # Auto-install via Cloud Init
  http_content = {
    "/meta-data" = templatefile("${path.root}/files/meta-data.pkrtpl.hcl", {})
    "/user-data" = templatefile("${path.root}/files/user-data.pkrtpl.hcl", {
      ssh_authorized_key = "${var.ssh_authorized_key}"
    })
  }

  boot_command = [
    "<esc><wait>",
    "e<wait>",
    "<down><down><down><end>",
    "<bs><bs><bs><bs><wait>",
    "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait>",
    "<f10><wait>"
  ]
  boot      = "c"
  boot_wait = "5s"

  # SSH
  ssh_agent_auth = true
  ssh_username   = "service"
  ssh_timeout    = "10m"
}

build {
  name    = "ubuntu-server-24.04"
  sources = ["source.proxmox-iso.ubuntu-server"]

  # Ensure cloud-init finished
  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 2; done",
    ]
  }

  # Configure with base playbook
  provisioner "ansible" {
    playbook_file = "../../playbook-ubuntu-server-24.04.yml"
    use_proxy = false
    groups = [
      "template",
    ]
  }

  // Ensure that SSH Host Keys are geerated on next boot
  provisioner "file" {
    content = templatefile("${path.root}/files/ssh_host_keys.service.pkrtpl.hcl", {})
    destination = "/home/service/reset_ssh_host_keys.service"
  }

  provisioner "shell" {
    inline = [
      "sudo mv /home/service/reset_ssh_host_keys.service /etc/systemd/system/reset_ssh_host_keys.service",
      "sudo chown root:root /etc/systemd/system/reset_ssh_host_keys.service",
      "sudo chmod 755 /etc/systemd/system/reset_ssh_host_keys.service",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable reset_ssh_host_keys",
      "sudo rm /etc/ssh/ssh_host_*key*",
    ]
  }

  // Ensure that Machine ID is generated on next boot
  provisioner "shell" {
    inline = [
      "sudo truncate -s 0 /etc/machine-id /var/lib/dbus/machine-id",
    ]
  }
}
