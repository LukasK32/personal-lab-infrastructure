# See: https://www.richardslab.uk/building-an-ubuntu-22-04-vm-template-for-proxmox/
[Unit]
Description=Regenerate SSH host keys
Before=ssh.service
ConditionFileIsExecutable=/usr/bin/ssh-keygen

[Service]
Type=oneshot
ExecStartPre=-/bin/dd if=/dev/hwrng of=/dev/urandom count=1 bs=4096
ExecStartPre=-/bin/sh -c "/bin/rm -f -v /etc/ssh/ssh_host_*key*"
ExecStart=/bin/sh -c "ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N \"\" && ssh-keygen -t rsa -b 4096 -f /etc/ssh/ssh_host_rsa_key -N \"\""
ExecStartPost=/bin/systemctl disable reset_ssh_host_keys

[Install]
WantedBy=multi-user.target
