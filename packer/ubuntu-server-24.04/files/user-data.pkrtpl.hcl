#cloud-config
autoinstall:
  version: 1
  refresh-installer:
   update: false
  source:
    id: "ubuntu-server"
    search_drivers: false
  timezone: "Etc/UTC"
  locale: "en_US.UTF-8"
  keyboard:
    layout: "us"
  storage:
    swap:
      size: 0
    config:
      - id: "disk-sda"
        type: "disk"
        path: "/dev/sda"
        ptable: "gpt"
        preserve: false
        grub_device: true
      - id: "sda1"
        type: "partition"
        device: "disk-sda"
        number: 1
        preserve: false
        grub_device: false
        size: 1048576
        flag: "bios_grub"
        offset: 1048576
      - id: "sda2"
        type: "partition"
        device: "disk-sda"
        number: 2
        preserve: false
        grub_device: false
        size: -1
        wipe: "superblock"
        offset: 2097152
      - id: "format-0"
        type: "format"
        volume: "sda2"
        fstype: "xfs"
        preserve: false
      - id: "mount-0"
        type: "mount"
        device: "format-0"
        path: /
  updates: "all"
  codecs:
    install: false
  drivers:
    install: false
  oem:
    install: false
  packages:
    - "qemu-guest-agent"
  user-data:
    users:
      - name: "service"
        groups: ["adm", "sudo"]
        lock_passwd: true
        sudo: "ALL=(ALL) NOPASSWD:ALL"
        shell: "/bin/bash"
        ssh_authorized_keys:
          - "${ssh_authorized_key}"
  ssh:
    install-server: true
    allow-pw: false
