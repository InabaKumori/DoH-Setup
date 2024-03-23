# DoH (DNS over HTTPS) Setup Script

This script automates the setup and management of a DNS over HTTPS (DoH) service on your system. It installs and configures the necessary components, including `https_dns_proxy` and `dnsmasq`, to enable secure and private DNS resolution using popular DoH providers.

## Features

- Automatically installs and compiles `https_dns_proxy` from source
- Installs `dnsmasq` and configures it to work with `https_dns_proxy`
- Supports multiple DoH providers: Cloudflare DNS, Google DNS, Tencent Cloud DoH, and Alibaba Cloud DoH
- Provides an interactive menu to enable/disable DoH, show service status, test functionality, and verify components
- Includes a DoH verification script to ensure proper functioning of the DoH service

## Compatibility

This script has been successfully tested on the following operating systems:
- Linux (Ubuntu)

## Prerequisites

Before running the script, ensure that your system meets the following requirements:

- `git` is installed
- `cmake`, `libc-ares-dev`, `libcurl4-openssl-dev`, `libev-dev`, and `build-essential` packages are available (for Linux)
- `net-tools` package is installed (for Linux)

## Installation

1. Clone this repository to your local machine:

   ```bash
   git clone https://github.com/inabakumori/doh-setup.git
   ```

2. Navigate to the cloned directory:

   ```bash
   cd doh-setup
   ```

3. Make the script executable:

   ```bash
   chmod +x doh-setup.sh
   ```

4. Run the script with sudo privileges:

   ```bash
   sudo ./doh-setup.sh
   ```

   The script will automatically install and configure the necessary components.

## Usage

After running the script, you will be presented with an interactive menu:

```
Setup Information:
-------------------
Current DNS/DoH Servers:
- Cloudflare DNS (port 5053)
- Google DNS (port 5054)
- Tencent Cloud DoH (port 5055)
- Alibaba Cloud DoH (port 5056)

Options:
1. Enable DoH
2. Disable DoH
3. Show DoH service status
4. Test DoH functionality
5. Verify DoH components

Enter your choice (1-5):
```

Choose an option by entering the corresponding number:

1. **Enable DoH**: Starts the `https_dns_proxy` instances and restarts `dnsmasq` to enable DoH.
2. **Disable DoH**: Stops the `https_dns_proxy` instances and restarts `dnsmasq` to disable DoH.
3. **Show DoH service status**: Displays the status of the `https_dns_proxy` instances.
4. **Test DoH functionality**: Runs the DoH verification script to test DNS resolution using the configured DoH servers.
5. **Verify DoH components**: Checks if all the required DoH components are present on the system.

## DoH Verification

The script includes a DoH verification script located at `/usr/local/bin/doh-verification`. This script tests the DNS resolution functionality of the configured DoH servers by resolving a set of test domains. It logs the results to `/var/log/doh-verification.log`.

To manually run the DoH verification script, execute the following command:

```bash
sudo /usr/local/bin/doh-verification
```

The script will test DNS resolution for each configured DoH server and display the results.

## Troubleshooting

If you encounter any issues while using this script, consider the following troubleshooting steps:

1. Verify that all the required components are installed correctly by choosing option 5 from the menu.
2. Check the log files for any error messages:
   - `https_dns_proxy` logs are located at `/var/log/https_dns_proxy_<port>.log`
   - DoH verification log is located at `/var/log/doh-verification.log`
3. Ensure that the script has been executed with sudo privileges.
4. Make sure that your system meets the prerequisites mentioned in the "Prerequisites" section.
5. If the issue persists, please open an issue on the GitHub repository with detailed information about the problem.

## Configuration

The script configures the following DoH servers by default:

- Cloudflare DNS (port 5053)
- Google DNS (port 5054)
- Tencent Cloud DoH (port 5055)
- Alibaba Cloud DoH (port 5056)

If you wish to modify the DoH servers or add new ones, you can edit the `start_https_dns_proxy` function in the script. Each `https_dns_proxy` instance is started with specific parameters:

- `-a`: IP address to listen on (default: 127.0.0.1)
- `-p`: Port to listen on (unique for each instance)
- `-b`: Bootstrap DNS servers (comma-separated list)
- `-r`: DoH resolver URL

Make sure to update the corresponding `server` lines in the `/etc/dnsmasq.conf` file if you modify the ports.

## Contributing

Contributions to this project are welcome! If you find any bugs, have suggestions for improvements, or want to add new features, please open an issue or submit a pull request on the GitHub repository.

When contributing, please ensure that your code follows the existing style and conventions used in the project. Also, make sure to test your changes thoroughly before submitting a pull request.

## License

This project is licensed under the GNU General Public License v3.0. See the [LICENSE](LICENSE) file for more information.

## Acknowledgements

This script utilizes the following open-source projects:

- [https_dns_proxy](https://github.com/aarond10/https_dns_proxy) by aarond10
- [dnsmasq](http://www.thekelleys.org.uk/dnsmasq/doc.html)

We would like to express our gratitude to the developers and contributors of these projects for their valuable work.

## Disclaimer

This script is provided as-is, without any warranty or guarantee of its functionality or suitability for your specific use case. The author and contributors of this project shall not be held liable for any damages or losses arising from the use of this script.

Please use this script responsibly and ensure that you have the necessary permissions and legal rights to use the DoH servers configured in the script.

## Contact

If you have any questions, suggestions, or feedback regarding this project, please feel free to contact the maintainer:

- Name: InabaKumori
- GitHub: [inabakumori](https://github.com/inabakumori)

We appreciate your interest in this project and look forward to your contributions and feedback!
