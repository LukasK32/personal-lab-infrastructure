# Ansible Playbooks for Ubuntu 24.04LTS

This repository contains Ansible playbooks and Packer configurations for Ubuntu Server 24.04 that I use in my personal lab.

## Ansible Playbooks

* [`ubuntu-server-24.04`](./playbook-ubuntu-server-24.04.yml) - Ubuntu Server 24.04LTS configuration for general use in the lab.
* [`proxmox`](./playbook-proxmox.yml) - Proxmox configuration for the host on which the lab is ran.
    * Note that this playbook is wildly incomplete and is used mainly to run some roles form the [`ubuntu-server-24.04`](./playbook-ubuntu-server-24.04.yml) for reusability.

## Packer configurations

* [`ubuntu-server-24.04`](./packer/ubuntu-server-24.04) - ready-to-clone Proxmox template based on the [`ubuntu-server-24.04`](./playbook-ubuntu-server-24.04.yml) Ansible playbook.
