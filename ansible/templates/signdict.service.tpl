[Unit]
Description=SignDict systemd service.
After=network.target

[Service]
WorkingDirectory=/var/signdict
EnvironmentFile=/etc/environment
ExecStart=/var/signdict/bin/sign_dict start
ExecStop=/var/signdict/bin/sign_dict stop
User=bodo
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target