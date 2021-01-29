#! /bin/bash
# help function
function usage {
  cat <<EOM
Usage: $(basename "$0") [OPTION]...
  -h          Display help
  -p VALUE    Set password
  -n   Configure doesn't install browser
EOM

  exit 2
}

# Set default configurations
while getopts p:n:h: o
do
  case $o in
    p) password=$OPTARG;;
    n) BROWSER=0;;
    '-h'|'--help'|* )
      usage
      ;;
  esac
done
if [ -z "$password" ]; then
    echo "set password by environment variable or options"
    exit 0
fi
VNCPASS=$password
BROWSER=1

# Install mate desktop
sudo yum update -y
sudo amazon-linux-extras install -y mate-desktop1.x
sudo bash -c 'echo PREFERRED=/usr/bin/mate-session > /etc/sysconfig/desktop'
# Install vnc
sudo yum -y install tigervnc-server
# You can write password here!
sudo yum install -y expect
expect -c "
    set timeout 3
    spawn vncpasswd
    expect \"Password:\"
    send \"$VNCPASS\n\"
    expect \"Verify\"
    send \"$VNCPASS\n\"
    expect \"Would you like to enter a view-only password (y/n)?\"
    send n\n
    interact
"

vncserver :1 
# Setup systemd for VNC
sudo cp /lib/systemd/system/vncserver@.service /etc/systemd/system/vncserver@.service
sudo sed -i 's/<USER>/ec2-user/' /etc/systemd/system/vncserver@.service
sudo systemctl daemon-reload
sudo systemctl enable vncserver@:1
sudo systemctl start vncserver@:1
# (Option) Install Chrome
if [ BROWSER = 1 ]; then
    sudo amazon-linux-extras install -y epel
    sudo yum install -y chromium
fi

# Need reboot for using GUI
sudo reboot
