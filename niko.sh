#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/bin:/sbin
export PATH

which yum >/dev/null 2>/dev/null
if [ $? -ne 0 ]; then
    Main=apt-get
else
    Main=yum
fi

function ssr(){
    echo " "
    echo -e "\033[42;37m 请输入节点编号 \033[0m"
    read port
    echo " "
    
    docker version > /dev/null || curl -fsSL get.docker.com | bash
    service docker restart

    docker run -d --name=ssrmu -e NODE_ID=$port -e API_INTERFACE=glzjinmod -e MYSQL_HOST=ssr0.52node.xyz -e MYSQL_USER=span -e MYSQL_DB=span -e MYSQL_PASS=Lh7rFrLFirysbKxJ --network=host --log-opt max-size=50m --log-opt max-file=3 --restart=always fanvinga/docker-ssrmu
}

function gost_opt(){
    echo -e "\033[42;37m 选择gost服务器类型 \033[0m"
    echo -e "\033[37m [1] 服务端 \033[0m"
    echo -e "\033[37m [2] 客户端 \033[0m"
    echo -e "\033[37m [3] 一键服务端 \033[0m"
    echo -e "\033[37m [4] 一键客户端 \033[0m"
    echo -e "\033[41;33m 输入1-2进行选择: \033[0m"

    read opt
    echo " "
    echo "---------------------------------------------------------------------------"

    if [ "$opt"x = "1"x ]; then
    gost-server

    elif [ "$opt"x = "2"x ]; then
    gost-client

    else
        echo -e "\033[41;33m 输入错误 \033[0m"
        bash ./node.sh
    fi
}

function gost-server(){
	echo -e "\033[42;37m 正在检测docker运行状态 \033[0m"
    	docker version > /dev/null || curl -fsSL get.docker.com | bash
    	service docker restart
	echo -e "\033[42;37m gost-server配置 \033[0m"
	echo "---------------------------------------------------------------------------"

	echo " "
	echo -e "\033[42;37m 请输入docker容器名 \033[0m 参考格式 gost-server"
	read name
	echo " "
		
	echo " "
	echo -e "\033[42;37m 请输入监听端口 \033[0m 参考格式 443"
	read listen_port
	echo " "

    echo " "
	echo -e "\033[42;37m 请输入后端端口 \033[0m 参考格式 443"
	read down_port
	echo " "
		
	docker run -d --name=$name \
	--restart unless-stopped \
	--log-opt max-size=10m \
	--network=host \
	ginuerzh/gost -L=relay+tls://:$listen_port/127.0.0.1:$down_port
		
}

function gost-client(){
	echo -e "\033[42;37m 正在检测docker运行状态 \033[0m"
    	docker version > /dev/null || curl -fsSL get.docker.com | bash
    	service docker restart
	echo -e "\033[42;37m gost-client配置(请保持与gost-server对应) \033[0m"
    echo "---------------------------------------------------------------------------"
	
	echo " "
	echo -e "\033[42;37m 请输入docker容器名 \033[0m 参考格式 gost-client"
	read name
	echo " "
	
	echo " "
	echo -e "\033[42;37m 请输入中转端口 \033[0m 参考格式 10000"
	read listen_port
	echo " "

    echo " "
	echo -e "\033[42;37m 请输入落地ip \033[0m 参考格式 8.8.8.8"
	read host
	echo " "
	
	echo " "
	echo -e "\033[42;37m 请输入落地端口 \033[0m 参考格式 443"
	read forward_port
	echo " "
	
	docker run -d --name=$name \
	--restart unless-stopped \
	--log-opt max-size=10m \
	--network=host \
	ginuerzh/gost -L=tcp://:$listen_port -L=udp://:$listen_port -F=relay+tls://$host:$forward_port
}

function self-gost-server(){
	echo -e "\033[42;37m self-gost-server配置 \033[0m"
	echo "---------------------------------------------------------------------------"
	
	echo " "
	echo -e "\033[42;37m 请输入分配的域前缀 \033[0m 参考格式 jp1"
	read prefix
	echo " "
		
	mv ~/.acme.sh ~/acme
	cp /root/acme/$prefix.xmum.cloud/fullchain.cer /root/cert.pem
	cp /root/acme/$prefix.xmum.cloud/$prefix.xmum.cloud.key /root/key.pem
	
	wget -N --no-check-certificate https://nite.studio/download/scripts/gost && chmod +x gost && nohup ./gost -L=tls://:443?cert=/root/cert.pem&key=/root/key.pem &
}

function self-gost-client(){
    echo -e "\033[42;37m self-gost-server配置 \033[0m"
	echo "---------------------------------------------------------------------------"
	
	echo " "
	echo -e "\033[42;37m 请输入分配的域前缀 \033[0m 参考格式 jp1"
	read prefix
	echo " "
		
	mv ~/.acme.sh ~/acme
	cp /root/acme/$prefix.xmum.cloud/fullchain.cer /root/cert.pem
	cp /root/acme/$prefix.xmum.cloud/$prefix.xmum.cloud.key /root/key.pem
    wget -N --no-check-certificate https://nite.studio/download/scripts/gost && chmod +x gost && nohup ./gost -L=tls://:443?secure=true &
}

function v2ray_opt(){
    echo -e "\033[42;37m 选择v2ray安装版本 \033[0m"
    echo -e "\033[37m [1] bash版v2ray \033[0m"
    echo -e "\033[37m [2] rico授权破解版v2ray \033[0m"
    echo -e "\033[41;33m 输入1或2进行选择: \033[0m"

    read opt
    echo " "
    echo "---------------------------------------------------------------------------"

    if [ "$opt"x = "1"x ]; then
    v2ray

    elif [ "$opt"x = "2"x ]; then
    v2rico

    else
        echo -e "\033[41;33m 输入错误 \033[0m"
        bash ./node.sh
    fi
}

function v2ray(){
    echo "###   v2ray后端一键对接脚本v1.0   ###"
    echo "###         By NikoBlack       ###"
    echo "###     Update: 2020-06-30      ###"

    echo " "
    echo -e "\033[41;33m 本功能仅支持Debian 9，请勿在其他系统中运行 \033[0m"
    echo " "
    echo "---------------------------------------------------------------------------"
    echo " "

    echo " "
    echo -e "\033[42;37m 请输入对接域名 \033[0m 参考格式 http://sspanel.com"
    read host
    echo " "

    echo " "
    echo -e "\033[42;37m 请输入muKey \033[0m 参考格式 sspanel"
    read muKey
    echo " "

    echo " "
    echo -e "\033[42;37m 请输入节点ID \033[0m 参考格式 42"
    read nodeid
    echo " "

    echo " "
    echo "---------------------------------------------------------------------------"
    echo -e "\033[41;33m 请确认下列信息无误，任何失误需要重置操作系统！\033[0m"
    echo -e "\033[42;37m 对接域名 \033[0m $host"
    echo -e "\033[42;37m muKey \033[0m $muKey"
    echo -e "\033[42;37m 节点ID \033[0m $nodeid"
    echo " "
    echo -e "\033[41;33m 回车以继续，ctrl+C退出 \033[0m"
    echo " "
    echo "---------------------------------------------------------------------------"

    read -n 1
    apt-get update -y
    apt-get install curl -y
    bash <(curl -L -s  https://raw.githubusercontent.com/linux-terminal/v2ray-sspanel-v3-mod_Uim-plugin-1/master/install-release.sh) \
    --panelurl $host --panelkey $muKey --nodeid $nodeid \
    --downwithpanel 1 --speedtestrate 6 --paneltype 0 --usemysql 0
    systemctl start v2ray.service
    echo " "
    echo " "
    echo -e "\033[42;37m 安装完成 \033[0m"
}

function v2rico(){
    echo -e "\033[42;37m 正在检测docker运行状态 \033[0m"
    docker version > /dev/null || curl -fsSL get.docker.com | bash
    service docker restart

    echo "###   v2ray rico授权破解版一键安装(4.22.1)   ###"
    echo "###         By NikoBlack       ###"
    echo "###     Update: 2020-06-30      ###"
    echo " "
    echo "---------------------------------------------------------------------------"
    echo " "

    echo " "
    echo -e "\033[42;37m 请输入docker容器名 \033[0m 参考格式 v2ray"
    read name
    echo " "

    echo " "
    echo -e "\033[42;37m 请输入对接域名 \033[0m 参考格式 http://sspanel.com"
    read host
    echo " "

    echo " "
    echo -e "\033[42;37m 请输入muKey \033[0m 参考格式 sspanel"
    read muKey
    echo " "

    echo " "
    echo -e "\033[42;37m 请输入节点ID \033[0m 参考格式 42"
    read nodeid
    echo " "

    echo " "
    echo "---------------------------------------------------------------------------"
    echo -e "\033[41;33m 请确认下列信息无误 \033[0m"
    echo -e "\033[41;33m docker容器名 \033[0m $name"
    echo -e "\033[42;37m 对接域名 \033[0m $host"
    echo -e "\033[42;37m muKey \033[0m $muKey"
    echo -e "\033[42;37m 节点ID \033[0m $nodeid"
    echo " "
    echo -e "\033[41;33m 回车以继续，ctrl+C退出 \033[0m"
    echo " "
    echo "---------------------------------------------------------------------------"

    read -n 1
    docker run -d --name=$name \
    -e speedtest=0  -e api_port=2333 -e usemysql=0 -e downWithPanel=0 \
    -e node_id=$nodeid -e sspanel_url=$host -e key=$muKey \
    --log-opt max-size=10m --log-opt max-file=5 \
    --network=host --restart=always \
    niteko/image:v2ray

    echo " "
    echo " "
    echo -e "\033[42;37m 安装完成 \033[0m"

}

function bbr(){
    wget -N --no-check-certificate "https://github.com/ylx2016/Linux-NetSpeed/releases/download/sh/tcp.sh" && chmod +x tcp.sh && ./tcp.sh
}

function iptables(){
	wget -N --no-check-certificate "https://raw.githubusercontent.com/NikoBlack/xmuc_node/master/iptables-pf.sh" && chmod +x iptables-pf.sh && ./iptables-pf.sh
}

function blockip(){
    echo -e "\033[42;37m 选择blockip类型 \033[0m"
    echo -e "\033[37m [1] 自用blockip \033[0m"
    echo -e "\033[37m [2] 自定义blockip \033[0m"
    echo -e "\033[41;33m 输入1-2进行选择: \033[0m"

    read opt
    echo " "
    echo "---------------------------------------------------------------------------"

    if [ "$opt"x = "1"x ]; then
    	echo " "
    	echo -e "\033[42;37m 请输入分配域名前缀 \033[0m 参考格式 42"
    	read prefix
    	echo " "
	
    	apt-get install ufw -y
	ufw defualt deny
	ufw allow 22
	ufw allow 443
	TMPSTR=`ping ${prefix}.xmum.cloud -c 1 | sed '1{s/[^(]*(//;s/).*//;q}'`
	ufw allow from $TMPSTR
	ufw --force enable

    elif [ "$opt"x = "2"x ]; then
	wget -N --no-check-certificate "https://raw.githubusercontent.com/NikoBlack/xmuc_node/master/blockip.sh" && chmod +x blockip.sh && ./blockip.sh
    
    else
        echo -e "\033[41;33m 输入错误 \033[0m"
        bash ./node.sh
    fi	
}

function brook(){
    wget -N --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubiBackup/doubi/master/brook-pf.sh && chmod +x brook-pf.sh && bash brook-pf.sh
}

function dd(){
    echo -e "\033[41;33m 请选择需要安装的操作系统 \033[0m"
    echo -e "\033[42;37m [1] \033[0m Debian"
    echo -e "\033[42;37m [2] \033[0m Ubuntu"
    echo -e "\033[42;37m [3] \033[0m Cent OS"
    echo -e "\033[37m 请选择 \033[0m"
    os=null
    read opt
    if [ "$opt"x = "1"x ]; then
        os=d
    
    elif [ "$opt"x = "2"x ]; then
        os=u
    
    elif [ "$opt"x = "3"x ]; then
        os=c
    
     else
        echo -e "\033[41;33m 输入错误 \033[0m"
        bash ./node.sh

    fi
    echo " "

    echo " "
    echo -e "\033[41;33m 输入发行版本 \033[0m"
    echo -e "\033[37m 例如：Debian [9] Cent OS [7] \033[0m"
    read v
    echo " "

    echo " "
    echo -e "\033[41;33m 镜像类型 \033[0m"
    echo -e "\033[42;37m [1] \033[0m 32位"
    echo -e "\033[42;37m [2] \033[0m 64位"
    opt=0
    read opt
    if [ "$opt"x = "1"x ]; then
        type=32
    
    elif [ "$opt"x = "2"x ]; then
        type=64
    else
        echo -e "\033[41;33m 输入错误 \033[0m"
        bash ./node.sh
    fi
    echo " "

    echo " "
    echo -e "\033[41;33m 请输入root密码 \033[0m"
    read password
    echo " "

    echo " "
    echo "---------------------------------------------------------------------------"
    echo -e "\033[41;33m 请确认下列信息无误，任何失误需要重置操作系统！\033[0m"
    echo -e "\033[42;37m 操作系统 \033[0m $os"
    echo -e "\033[42;37m 发行版本 \033[0m $v"
    echo -e "\033[42;37m 镜像类型 \033[0m $type 位"
    echo -e "\033[42;37m root密码 \033[0m $password"
    echo " "
    echo -e "\033[41;33m 回车以继续，ctrl+C退出 \033[0m"
    echo " "
    echo "---------------------------------------------------------------------------"
    read -n 1
    echo " "
    echo  -e "\033[37m 开始安装，请静候10min！ \033[0m"

    bash <(wget --no-check-certificate -qO- 'https://moeclub.org/attachment/LinuxShell/InstallNET.sh') -$os $v -v $type -a -p $password
}

function dns(){
    echo -e "\033[41;33m 请选择需要安装的内容 \033[0m"
    echo -e "\033[42;37m [1] \033[0m 配置Dnsmasq"
    echo -e "\033[42;37m [2] \033[0m 配置DNS"
    echo -e "\033[37m 请选择 \033[0m"
    echo " "
    read opt

    if [ "$opt"x = "1"x ]; then
    echo "\033[42;37m [1] \033[0m 安装Dnsmasq"
    echo "\033[42;37m [2] \033[0m 卸载Dnsmasq"
    read opt

        if [ "$opt"x = "1"x ]; then
            wget --no-check-certificate -O dnsmasq_sniproxy.sh https://github.com/myxuchangbin/dnsmasq_sniproxy_install/raw/master/dnsmasq_sniproxy.sh && bash dnsmasq_sniproxy.sh -i
        elif [ "$opt"x = "2"x ]; then
            wget --no-check-certificate -O dnsmasq_sniproxy.sh https://github.com/myxuchangbin/dnsmasq_sniproxy_install/raw/master/dnsmasq_sniproxy.sh && bash dnsmasq_sniproxy.sh -u
        else
            echo -e "\033[41;33m 输入错误 \033[0m"
            bash ./node.sh
        fi
    elif [ "$opt"x = "2"x ]; then
        echo -e "\033[41;33m 输入DNS服务器IP \033[0m"
        read unlock_ip
        chattr -i /etc/resolv.conf && echo -e "nameserver $unlock_ip" > /etc/resolv.conf && chattr +i /etc/resolv.conf && systemd-resolve --flush-caches
        echo "---------------------------------------------------------------------------"
        echo -e "\033[41;33m 请确认下列信息无误，任何失误需要重置操作系统！\033[0m"
        echo " "
        echo -e "\033[42;37m DNS服务器IP \033[0m $unlock_ip"
        echo -e "\033[41;33m 回车以继续，ctrl+C退出 \033[0m"
        echo " "
        echo "---------------------------------------------------------------------------"
        
        echo " "
        read -n 1

        echo " "
        echo -e "\033[41;33m 配置成功，需要重启服务器，是否继续？(Y/n) \033[0m"
        read opt
            if [ "$opt"x = "Y"x ]; then
                reboot
            else
                bash ./node.sh
            fi
    fi
}

function swap(){
    wget https://www.moerats.com/usr/shell/swap.sh && bash swap.sh
}

function TLS(){
    echo " "
    echo -e "\033[42;37m 请输入分配的域名前缀 \033[0m 参考格式 jp1"
    read prefix
    echo " "
   
    $Main install socat -y
    curl  https://get.acme.sh | sh
    ~/.acme.sh/acme.sh  --issue -d $prefix.xmum.cloud   --standalone
}

function menu(){
    echo "###       node tool v2.0       ###"
    echo "###        By NikoBlack        ###"
    echo "###    Update: 2020-08-24      ###"
    echo ""
    echo -e "\033[41;33m 适用环境 Debian/Ubuntu/Cent OS \033[0m"
    echo "---------------------------------------------------------------------------"

    echo -e "\033[42;37m [0] \033[0m 安装环境(新机器请先做这一步)"
    echo -e "\033[42;37m [1] \033[0m 安装SSR后端"
    echo -e "\033[42;37m [2] \033[0m 安装gost转发"
    echo -e "\033[42;37m [3] \033[0m 安装v2ray后端"
    echo -e "\033[42;37m [4] \033[0m 安装iptables转发脚本"
    echo -e "\033[42;37m [5] \033[0m 安装brook中转后端"
    echo -e "\033[42;37m [6] \033[0m 安装bbr加速"
    echo -e "\033[42;37m [7] \033[0m 一键屏蔽指定国家ip访问"	
    echo -e "\033[42;37m [8] \033[0m 一键重装纯净系统"
    echo -e "\033[42;37m [9] \033[0m 一键配置DNS解锁"
    echo -e "\033[42;37m [10] \033[0m 一键设置swap"
    echo -e "\033[42;37m [11] \033[0m 一键获取TLS证书"
    echo -e "\033[41;33m 请输入选项以继续，ctrl+C退出 \033[0m"
	
    opt=0
    read opt
	if [ "$opt"x = "0"x ]; then
	
		$Main update -y
		$Main install curl -y
		$Main install screen -y
		bash ./node.sh
	
    elif [ "$opt"x = "1"x ]; then
        ssr
		
    elif [ "$opt"x = "2"x ]; then
        gost_opt		

    elif [ "$opt"x = "3"x ]; then
        v2ray_opt
	
	elif [ "$opt"x = "4"x ]; then
		iptables

    elif [ "$opt"x = "5"x ]; then
        brook
    
    elif [ "$opt"x = "6"x ]; then
        bbr
    
	elif [ "$opt"x = "7"x ]; then
        blockip
	
    elif [ "$opt"x = "8"x ]; then
        dd

    elif [ "$opt"x = "9"x ]; then
        dns

    elif [ "$opt"x = "10"x ]; then
        swap
	
    elif [ "$opt"x = "11"x ]; then
        TLS
    
    else
        echo -e "\033[41;33m 输入错误 \033[0m"
        bash ./node.sh
    fi
}

menu
