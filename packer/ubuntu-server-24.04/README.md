# Proxmox template for Ubuntu Server 24.04

This is a Packer configuration that emits a Proxmox template for Ubuntu Server 24.04.

## Usage

1. Initialize Packer plugins:

    ```sh
    packer init ./template-ubuntu-server-24.04.pkr.hcl
    ```

1. Create a variables file:

    ```sh
    cp ./variables.example.pkr.hcl ./variables.pkr.hcl
    ```

1. Fill out `variables.pkr.hcl` file with values for your environment.

1. Run a build:

    ```sh
    packer build --var-file ./variables.pkr.hcl ./template-ubuntu-server-24.04.pkr.hcl
    ```
