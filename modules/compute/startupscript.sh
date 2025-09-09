#!/bin/bash

apt-get update
apt-get -y install apache2

systemctl enable apache2
systemctl start apache2

export HOSTNAME=$(hostname)
export IP_ADDR=$(hostname -I)

cat <<EOT > /var/www/html/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Basic Website</title>
    <style>
        body { font-family: Arial, sans-serif; margin:0; padding:0; }
        header { background-color:#4CAF50; color:white; padding:20px; text-align:center; }
        nav { background-color:#333; }
        nav a { color:white; padding:14px 20px; display:inline-block; text-decoration:none; }
        nav a:hover { background-color:#575757; }
        main { padding:20px; }
        footer { background-color:#f1f1f1; text-align:center; padding:10px; margin-top:20px; }
    </style>
</head>
<body>
    <header>
        <h1>Welcome to Apache Website</h1>
        <p>Your hostname is: <strong>$HOSTNAME</strong></p>
        <p>Your IP is: <strong>$IP_ADDR</strong></p>
    </header>
</body>
</html>
EOT