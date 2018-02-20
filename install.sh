#!/bin/bash

cd
whoami=`whoami`
clear
# declare STRING variable
STRING1="Make sure you double check before pressing enter! One chance at this only!"
STRING2="If you found this useful, please consider a small donation to DIN Donation: "
STRING3="DH2EYCRPeLrMqGNiEoDEh14dnNKxzRYE5C"
STRING4="Updating system and installing required packages."
STRING5="Switching to Aptitude"
STRING6="Some optional installs"
STRING7="Starting your masternode"
STRING8="Now, you need to finally start your masternode in the following order:"
STRING9="Go to your windows/mac wallet and modify masternode.conf as required, then restart and from the Control wallet debug console please enter"
STRING10="masternode start-alias <mymnalias>"
STRING11="where <mymnalias> is the name of your masternode alias (without brackets)"
STRING12="once completed please return to VPS and press the space bar"
STRING13=""

#print variable on a screen
echo $STRING1 

    read -e -p "Server IP Address : " ip
    read -e -p "Masternode Private Key (e.g. 7sQ27dGdwwEGrAPHmfghBBfWZnC6K1rDATNvm986dDfsaw3Wws4 # THE KEY YOU GENERATED EARLIER) : " key
    read -e -p "Install Fail2ban? [Y/n] : " install_fail2ban
    read -e -p "Install UFW and configure ports? [Y/n] : " UFW

    clear
 echo $STRING2
 echo $STRING13
 echo $STRING3 
 echo $STRING13
 echo $STRING4    
    sleep 2

# update package and upgrade Ubuntu
    sudo apt-get -y update
    sudo apt-get -y upgrade
    sudo apt-get -y autoremove
    sudo apt-get install wget nano htop -y
    clear
echo $STRING5
    sudo apt-get -y install aptitude

#Generating Random Passwords
    password=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`
    password2=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`

echo $STRING6
    if [[ ("$install_fail2ban" == "y" || "$install_fail2ban" == "Y" || "$install_fail2ban" == "") ]]; then
    cd ~
    sudo aptitude -y install fail2ban
    cd && awk '{ printf "# "; print; }' /etc/fail2ban/jail.conf | sudo tee /etc/fail2ban/jail.local
    cd /etc/fail2ban/
    sed -i 's/bantime  = 600/bantime  = 10000/1' jail.conf
    sed -i 's/findtime  = 600/findtime  = 10000 /1' jail.conf
    sudo service fail2ban restart 
    fi
    if [[ ("$UFW" == "y" || "$UFW" == "Y" || "$UFW" == "") ]]; then
    sudo apt-get install ufw
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    sudo ufw allow ssh
    sudo ufw allow 26285/tcp
    sudo ufw --force enable
    fi


#Create dinero.conf

sudo mkdir .dinerocore
echo '
rpcuser='$password'
rpcpassword='$password2'
rpcallowip=127.0.0.1
listen=1
server=1
daemon=1
maxconnections=256
masternode=1
masternodeprivkey='$key'
externalip='$ip'

' | sudo -E tee ~/.dinerocore/dinero.conf >/dev/null 2>&1
    sudo chmod 0755 ~/.dinerocore/dinero.conf

echo 'dinero.conf created'

sleep 4

    clear
 echo $STRING2
 echo $STRING13
 echo $STRING4    

#Install Dinero Daemon
    wget https://github.com/dinerocoin/dinero/releases/download/v1.0.0.7/dinerocore-1.0.0.7-linux64.tar.gz
    sudo tar -xzvf dinerocore-1.0.0.7-linux64.tar.gz
    sudo rm dinerocore-1.0.0.7-linux64.tar.gz
    sudo chown -R $whoami:$whoami dinerocore-1.0.0/
    sudo chmod -R 0755 dinerocore-1.0.0/
    dinerocore-1.0.0/bin/dinerod -daemon
    clear
 
 sleep 3

#Setting up coin
    clear
echo $STRING2
echo $STRING13
echo $STRING13
echo $STRING4
sleep 3

#Install Sentinel
cd /root/.dinerocore
sudo apt-get install -y git python-virtualenv
sudo git clone https://github.com/dinerocoin/sentinel.git
cd sentinel
export LC_ALL=C
sudo apt-get install -y virtualenv
virtualenv venv
venv/bin/pip install -r requirements.txt

#Confirm permissions are squared away
cd
sudo chown -R $whoami:$whoami dinercore-1.0.0/
sudo chown -R $whoami:$whoami sentinel/
sudo chown -R $whoami:$whoami .dinerocore/
sudo chmod -R 0755 dinerocore-1.0.0/
sudo chmod -R 0755 sentinel/
sudo chmod -R 0755 .dinerocore/

dinerocore-1.0.0/bin/dinero-cli stop
sleep 10s
dinerocore-1.0.0/bin/dinerod -daemon

#Starting coin
    (crontab -l 2>/dev/null; echo '@reboot sleep 30 && cd /root/dinerocore-1.0.0/bin/dinerod -daemon -shrinkdebugfile') | crontab
    (crontab -l 2>/dev/null; echo '* * * * * cd /root/.dinerocore/sentinel && ./venv/bin/python bin/sentinel.py >/$') | crontab


    clear
echo $STRING2
echo $STRING13
echo $STRING3
echo $STRING13
echo $STRING4
    sleep 3
echo $STRING7
echo $STRING13
echo $STRING8 
echo $STRING13
echo $STRING9 
echo $STRING13
echo $STRING10
echo $STRING13
echo $STRING11
echo $STRING13
echo $STRING12
    sleep 120

cd
    clear
 echo $STRING2
 echo $STRING13
 echo $STRING13
 echo $STRING4    

read -p "(this message will remain for at least 120 seconds) Then press any key to continue... " -n1 -s
dinerocore-1.0.0/bin/dinero-cli getinfo
