#!/bin/bash
# Check if required components are installed
if ! command -v https_dns_proxy &> /dev/null || ! command -v dnsmasq &> /dev/null || ! command -v dig &> /dev/null; then
    # Create a directory for the project
    mkdir -p ~/doh-project
    cd ~/doh-project
    # Clone and compile https-dns-proxy
    git clone https://github.com/aarond10/https_dns_proxy.git
    sudo apt-get update
    sudo apt-get install cmake libc-ares-dev libcurl4-openssl-dev libev-dev build-essential net-tools
    cd https_dns_proxy
    cmake .
    make
    sudo make install
    cd ..
    # Install dnsmasq
    sudo apt-get install -y dnsmasq
fi
# Stop and disable systemd-resolved
sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved
# Modify /etc/dnsmasq.conf
if ! grep -q "^server=127.0.0.1#5053\|^server=127.0.0.1#5054\|^server=127.0.0.1#5055\|^server=127.0.0.1#5056" /etc/dnsmasq.conf; then
    sudo sed -i '1s/^/server=127.0.0.1#5053\nserver=127.0.0.1#5054\nserver=127.0.0.1#5055\nserver=127.0.0.1#5056\n/' /etc/dnsmasq.conf
    sudo sed -i '/^server=127.0.0.1#5056/a dns-forward-max=1000' /etc/dnsmasq.conf

# Uncomment the following rules after the DoH setup.
    # sudo sed -i '/^dns-forward-max=1000/a no-resolv' /etc/dnsmasq.conf
    # sudo sed -i '/^no-resolv /a no-poll' /etc/dnsmasq.conf
fi
# Create a function to start the https-dns-proxy instances
start_https_dns_proxy_proxy () {
    sudo https_dns_proxy -a 127.0.0.1 -p 5054 -b "119.29.29.29,223.6.6.6,8.8.8.8" -r "https://cloudflare-dns.com/dns-query" -d -u nobody -g nogroup -v >> /var/log/https_dns_proxy_5054.log 2>&1 &
    sudo https_dns_proxy -a 127.0.0.1 -p 5053 -b "119.29.29.29,223.6.6.6,8.8.8.8" -r "https://dns.google/dns-query" -d -u nobody -g nogroup -v >> /var/log/https_dns_proxy_5053.log 2>&1 &
    # ali-dns may require manual intervention
}

# Create a function to start the https-dns-proxy instances
start_https_dns_proxy_direct () {
    sudo https_dns_proxy -a 127.0.0.1 -p 5055 -b "119.29.29.29,223.6.6.6,8.8.8.8" -r "https://doh.pub/dns-query" -d -u nobody -g nogroup -v >> /var/log/https_dns_proxy_5055.log 2>&1 &
    sudo https_dns_proxy -a 127.0.0.1 -p 5056 -b "119.29.29.29,223.6.6.6,8.8.8.8" -r "https://******.alidns.com/dns-query" -d -u nobody -g nogroup -v >> /var/log/https_dns_proxy_5056.log 2>&1 &
    # ali-dns may require manual intervention
}

# Create a function to start the https-dns-proxy instances
start_https_dns_proxy() {
    sudo https_dns_proxy -a 127.0.0.1 -p 5054 -b "119.29.29.29,223.6.6.6,8.8.8.8" -r "https://cloudflare-dns.com/dns-query" -d -u nobody -g nogroup -v >> /var/log/https_dns_proxy_5054.log 2>&1 &
    sudo https_dns_proxy -a 127.0.0.1 -p 5053 -b "119.29.29.29,223.6.6.6,8.8.8.8" -r "https://dns.google/dns-query" -d -u nobody -g nogroup -v >> /var/log/https_dns_proxy_5053.log 2>&1 &
    sudo https_dns_proxy -a 127.0.0.1 -p 5055 -b "119.29.29.29,223.6.6.6,8.8.8.8" -r "https://doh.pub/dns-query" -d -u nobody -g nogroup -v >> /var/log/https_dns_proxy_5055.log 2>&1 &
    sudo https_dns_proxy -a 127.0.0.1 -p 5056 -b "119.29.29.29,223.6.6.6,8.8.8.8" -r "https://******.dns.alidns.com/dns-query" -d -u nobody -g nogroup -v >> /var/log/https_dns_proxy_5056.log 2>&1 &
    # ali-dns may require manual intervention
}

# Create a function to stop the https-dns-proxy instances
stop_https_dns_proxy() {
    sudo pkill -f https_dns
}
# Create the DoH verification script
sudo tee /usr/local/bin/doh-verification > /dev/null <<EOT
#!/bin/bash
LOG_FILE="/var/log/doh-verification.log"
log_message() {
    echo "\$(date +'%Y-%m-%d %H:%M:%S') - \$1" | tee -a "\$LOG_FILE"
}
test_dns_resolution() {
    local test_domain=\$1
    local resolver_ip=\$2
    local resolver_port=\$3
    log_message "Testing DNS resolution for \$test_domain via \$resolver_ip:\$resolver_port..."
    
    if dig @\$resolver_ip -p \$resolver_port \$test_domain | grep -q "NOERROR"; then
        log_message "Successfully resolved \$test_domain."
    else
        log_message "Failed to resolve \$test_domain. Check your DoH setup."
        return 1
    fi
}
verify_doh_service() {
    local resolver_ip="127.0.0.1"
    local resolver_ports=("5053" "5054" "5055" "5056")
    
    local domains=("google.com" "openwrt.org" "github.com")
    for port in "\${resolver_ports[@]}"; do
        for domain in "\${domains[@]}"; do
            if ! test_dns_resolution "\$domain" "\$resolver_ip" "\$port"; then
                log_message "Verification failed for \$domain on port \$port."
                return 1
            fi
        done
    done
    log_message "All tests passed. DoH service is functioning correctly."
}
log_message "Starting DoH service verification..."
verify_doh_service
exit 0
EOT
sudo chmod +x /usr/local/bin/doh-verification
# Display the setup information
echo "Setup Information:"
echo "-------------------"
echo "Current DNS/DoH Servers:"
echo "- Cloudflare DNS (port 5053)"
echo "- Google DNS (port 5054)"
echo "- Tencent Cloud DoH (port 5055)"
echo "- Alibaba Cloud DoH (port 5056)"
echo ""
echo "Options:"
echo "1. Enable DoH"
echo "2. Disable DoH"
echo "3. Show DoH service status"
echo "4. Test DoH functionality"
echo "5. Verify DoH components"
echo "6. Enable DoH Proxy (Advanced Use Only)"
echo "7. Enable DoH Direct (Advanced Use Only)"
echo "8. Disable DoH (without restarting dnsmasq)"
echo ""
read -p "Enter your choice (1-8): " choice
case $choice in
    1)
        start_https_dns_proxy
        sudo systemctl restart dnsmasq
        echo "DoH enabled. Wait..."
        sleep 2
        stty sane
        ;;
    2)
        stop_https_dns_proxy
        stop_https_dns_proxy
        stop_https_dns_proxy
        stop_https_dns_proxy
        stop_https_dns_proxy
        sudo systemctl restart dnsmasq
        echo "DoH disabled."
        ;;
    3)
        echo "https-dns-proxy instances status:"
        netstat -tulpn | grep -E ":(5053|5054|5055|5056)"
        ;;
    4)
        sudo /usr/local/bin/doh-verification
        ;;
    5)
        if command -v https_dns_proxy &> /dev/null && command -v dnsmasq &> /dev/null && command -v dig &> /dev/null; then
            echo "All DoH components are present."
        else
            echo "Some DoH components are missing. Please check the installation."
        fi
        ;;
    6)
        start_https_dns_proxy_proxy
        echo "DoH Proxy enabled. Wait..."
        sleep 2
        stty sane
        ;;
    7)
        start_https_dns_proxy_direct
        echo "DoH Direct enabled. Wait..."
        sleep 2
        stty sane
        ;;
    8)
        stop_https_dns_proxy
        stop_https_dns_proxy
        stop_https_dns_proxy
        stop_https_dns_proxy
        stop_https_dns_proxy
        echo "DoH disabled."
        ;;
    *)
        echo "Invalid choice. Exiting."
        ;;
esac
