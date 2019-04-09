clear
echo "####################"
echo "####################"
echo "####  Firewall #####"
echo "####################"
echo "####################"
sleep 1
iptables -F
iptables -X
iptables -Z

clear
read -p "Desea tocar las politicas del firewall" p
if [ "$p" == "si" ]
then 
read -p " Escriba la politica que desea usar " P

#Politica

iptables -P INPUT $P
iptables -P OUTPUT $P
iptables -P FORWARD $P
sleep 2

iptables -L
sleep 1
clear

read -p "¿ Esta bien ?" C
if [ "$C" == "si" ]
then
 echo "Perfecto"
else
 read -p "Cual es la que desea cambiar ?" CH
 case $CH in
  "INPUT")
	read -p "que politica desea usar ?" PL
	iptables -P INPUT $PL
	iptables -L
	sleep 2
	clear;;
  "OUTPUT")
	read -p "que politica desea usar ?" PL
        iptables -P OUTPUT $PL
        iptables -L
        sleep 2
        clear;;
  "FORWARD")
	read -p "que politica desea usar ?" PL
        iptables -P FORWARD $PL
        iptables -L
        sleep 2
        clear;;
       "*")
        read -p "que politica desea usar ?" PL
        iptables -P INPUT $PL
        iptables -P OUTPUT $PL
	iptables -P FORWARD $PL
        iptables -L
	sleep 2
        clear;;
  esac
fi
read -p "¿Dar acceso a las redes DMZ y la red interna?" NET
if [ "$NET" == "si" ]
then
echo 1 > /proc/sys/net/ipv4/ip_forward
#Red interna
iptables -t nat -A POSTROUTING -s 192.168.0.200 -o enp0s3 -j MASQUERADE
#Red DMZ
iptables -t nat -A POSTROUTING -s 192.168.0.100 -o enp0s3 -j MASQUERADE
echo "Red dada a las otras redes "
else
 echo "Se quedan sin red"
fi

else
read -p "¿Dar acceso a las redes DMZ y la red interna?" NET
if [ "$NET" == "si" ]
then
echo 1 > /proc/sys/net/ipv4/ip_forward
#Red interna
iptables -t nat -A POSTROUTING -s 192.168.0.200 -o enp0s3 -j MASQUERADE
#Red DMZ
iptables -t nat -A POSTROUTING -s 192.168.0.100 -o enp0s3 -j MASQUERADE
echo "Red dada a las otras redes "
else
 echo "Se quedan sin red"
fi
fi
###############
## Servicios ##
###############

clear
#ssh
read -p "¿Acceso a los servidores de la DMZ por ssh ?" S
if [ "$S" == "si" ]
then
iptables -A OUTPUT -s 192.168.200.252 -o enp0s8 -j ACCEPT
else
echo "como desees"
fi
#DNS
read -p "¿Acceso a la web  para la red interna ?" D
if [ "$D" == "si" ]
then
iptables -A FORWARD -s 192.168.200.0/24 -p tcp --dport 53 -i enp0s9 -o enp0s3 -j ACCEPT
iptables -A FORWARD -d 192.168.200.0/24 -p tcp --sport 53 -i enp0s3 -o enp0s9 -j ACCEPT
iptables -A FORWARD -s 192.168.200.0/24 -p tcp --dport 80 -i enp0s9 -o enp0s3 -j ACCEPT
iptables -A FORWARD -d 192.168.200.0/24 -p tcp --sport 80 -i enp0s3 -o enp0s9 -j ACCEPT
iptables -A FORWARD -s 192.168.200.0/24 -p tcp --dport 443 -i enp0s9 -o enp0s3 -j ACCEPT
iptables -A FORWARD -d 192.168.200.0/24 -p tcp --sport 443 -i enp0s3 -o enp0s9 -j ACCEPT
else
echo "como desees"
fi
sleep 1
clear
read -p "¿Vas a usar un proxy para la red interna?" proxy
if [ "$proxy" == "si" ]
then
iptables -A INPUT -s 8.8.8.8 -p tcp --sport 53 -i enp0s3 -j ACCEPT
iptables -A INPUT -s 192.168.200.0/24 -p tcp --dport 53 -i enp0s9 -j ACCEPT
iptables -A OUTPUT -s 192.168.200.0/24 -p tcp --sport 53 -o enp0s9 -j ACCEPT
iptables -A OUTPUT -d 8.8.8.8 -p tcp --dport 53 -o enp0s3 -j ACCEPT
iptables -t nat -A PREROUTING -p tcp -i enp0s9 --dport 80 -j DNAT --to 192.168.200.252:3128
iptables -t nat -A PREROUTING -p tcp -i enp0s9 --dport 443 -j DNAT --to 192.168.200.252:3128
iptables -t nat -A PREROUTING -p tcp -s 192.168.200.0/24 --dport 80 -j REDIRECT --to-port 3128
iptables -t nat -A PREROUTING -p tcp -s 192.168.200.0/24 --dport 443 -j REDIRECT --to-port 3128
iptables -t nat -A POSTROUTING -s 192.168.200.0/24 -d 0.0.0.0/24 -o enp0s3 -j MASQUERADE
else
echo "perfecto prigao"
fi
