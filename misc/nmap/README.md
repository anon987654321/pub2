# Nmap Network Scanner

A simple wrapper script for the nmap network scanner tool.

## Features

- Port scanning with specific ports or ranges
- Service detection
- Verbose output options
- Network discovery

## Usage

```bash
./nmap.sh [options] target
```

### Options

- `-p PORT` - Scan specific port
- `-r RANGE` - Scan port range (e.g., 1-1000)
- `-s` - Enable service detection
- `-v` - Verbose output
- `-h` - Show help

### Examples

```bash
# Basic host scan
./nmap.sh 192.168.1.1

# Scan specific port
./nmap.sh -p 80 example.com

# Scan port range with service detection
./nmap.sh -r 1-1000 -s 192.168.1.0/24

# Verbose scan
./nmap.sh -v -s target.com
```

## Requirements

- nmap must be installed
- On OpenBSD: `pkg_add nmap`

## Security Notes

- Only scan networks you own or have permission to scan
- Network scanning may be detected by intrusion detection systems
- Use responsibly and in accordance with local laws