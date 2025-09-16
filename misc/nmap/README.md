# Network Security Assessment Tool (nmap.sh)

## Overview

The `nmap.sh` script is a cognitive-aware network security assessment tool designed specifically for OpenBSD environments. It replaces the existing `deep_nmap_scan.sh` with improved error handling,
cognitive load management,
and professional reporting capabilities.

## Key Features

### Cognitive Architecture
- **7±2 Memory Management**: Implements working memory constraints based on cognitive science
- **Progressive Complexity Disclosure**: Breaks down scanning into manageable phases
- **Cognitive Load Monitoring**: Tracks and manages cognitive overload
- **Context Switch Minimization**: Reduces mental overhead during long scans
- **Recovery Protocols**: Implements cognitive state restoration

### Technical Capabilities
- **Multi-method DNS Resolution**: Falls back through drill → dig → host → nslookup
- **Comprehensive Dependency Validation**: Checks for required tools with helpful error messages
- **Progressive Scanning Phases**: Seven distinct phases with clear progress indicators
- **Robust Error Handling**: Graceful degradation with actionable suggestions
- **Structured Output**: Professional reporting with executive summaries
- **POSIX Compliance**: Works with OpenBSD's native ksh and other POSIX shells

### OpenBSD Integration
- **Native Tool Preferences**: Uses drill over dig, respects OpenBSD conventions
- **doas Integration**: Proper privilege handling for OpenBSD
- **Security-First Design**: Follows OpenBSD security principles
- **PF Firewall Awareness**: Considers firewall implications in scanning

## Usage

### Basic Usage
```bash
doas sh nmap.sh <target>
```

### Examples
```bash
# Scan a domain
doas sh nmap.sh example.com

# Scan an IP address
doas sh nmap.sh 192.168.1.1

# Scan with verbose output
doas sh nmap.sh example.com 2>&1 | tee scan.log
```

## Prerequisites

### Required Dependencies
- `nmap` - Network scanning tool
- `doas` - OpenBSD privilege escalation (configured in /etc/doas.conf)

### Optional Dependencies (with fallbacks)
- `drill` (preferred) or `dig` or `host` - DNS resolution tools
- Standard POSIX utilities: `awk`, `grep`, `cut`, `paste`, `sort`, `find`

### System Requirements
- OpenBSD (primary target) or any POSIX-compliant system
- Root privileges (via doas)
- Network connectivity for target resolution

## Scanning Phases

The tool implements seven distinct cognitive phases:

### Phase 1: Dependency Validation
- Verifies required tools are installed
- Checks privilege level
- Provides installation guidance for missing tools

### Phase 2: DNS Resolution
- Multi-method DNS resolution with fallbacks
- Validates target accessibility
- Supports both domain names and IP addresses

### Phase 3: Host Discovery
- Multiple discovery techniques for resilience
- Adapts to firewall configurations
- Minimal network footprint options

### Phase 4: Port Discovery
- TCP SYN scanning (stealth mode)
- TCP Connect fallback for compatibility
- UDP scanning for comprehensive coverage

### Phase 5: Service Analysis
- Service version detection
- Operating system fingerprinting
- Focused scanning on discovered ports

### Phase 6: Vulnerability Assessment
- Safe vulnerability scripts only
- Web-specific vulnerability scanning
- Timeout protection for long assessments

### Phase 7: Report Generation
- Executive summary creation
- Risk assessment with actionable insights
- Structured file organization

## Output Structure

```
nmap_scan_<target>_<timestamp>/
├── raw/                    # Raw nmap output files
│   ├── host_discovery_*.txt
│   ├── tcp_syn.txt
│   ├── udp_scan.txt
│   ├── service_detection.txt
│   ├── os_detection.txt
│   ├── vulnerabilities.*
│   └── web_vulnerabilities.txt
├── processed/              # Processed data (future use)
├── reports/                # Additional reports (future use)
├── executive_summary.txt   # Executive summary
└── index.md               # Results index
```

## Error Handling

The tool implements comprehensive error handling with graceful degradation:

### Dependency Errors
- **DEPENDENCY_MISSING**: Provides installation commands
- **PERMISSION_DENIED**: Explains doas requirements

### Network Errors
- **DNS_RESOLUTION_FAILED**: Suggests connectivity checks
- Timeout handling for unresponsive targets
- Firewall adaptation strategies

### Graceful Degradation
- Continues with reduced functionality when non-critical errors occur
- Provides alternative scanning methods
- Clear indication of degraded capabilities

## Cognitive Load Management

### Memory Chunking
- Maintains 7±2 information chunks in working memory
- Automatic chunk compression when limits exceeded
- Context preservation across phases

### Progress Feedback
- Real-time progress indicators
- Phase completion notifications
- Time estimation for remaining work

### Recovery Protocols
- Cognitive load monitoring
- Automatic recovery when overload detected
- Context switching delays for mental processing

## Security Considerations

### Privilege Management
- Requires root privileges for low-level network access
- Proper doas configuration recommended
- Minimal privilege principle applied

### Network Ethics
- Designed for authorized security assessments only
- Rate limiting to prevent network abuse
- Respectful scanning techniques

### Data Protection
- Local output storage only
- No data transmission to external services
- Secure file permissions on results

## Configuration

### doas Configuration
Add to `/etc/doas.conf`:
```
permit nopass <username> as root cmd nmap
permit nopass <username> as root cmd /path/to/nmap.sh
```

### Firewall Considerations
Ensure outbound connectivity for:
- DNS resolution (port 53)
- Target scanning (various ports)
- Optional: ICMP for ping-based discovery

## Troubleshooting

### Common Issues

**"Command not found" errors**
- Install missing packages: `pkg_add nmap drill`
- Verify PATH includes tool locations

**"Permission denied" errors**
- Configure doas properly
- Run with: `doas sh nmap.sh <target>`

**DNS resolution failures**
- Check network connectivity
- Verify DNS server configuration
- Try IP address instead of domain name

**Slow scanning**
- Normal for comprehensive assessments
- Use -T4 timing (already included)
- Consider target network conditions

### Debug Mode
For detailed debugging, run with explicit shell output:
```bash
sh -x nmap.sh example.com
```

## Comparison with deep_nmap_scan.sh

| Feature | deep_nmap_scan.sh | nmap.sh |
|---------|-------------------|---------|
| Shell Compatibility | zsh only | POSIX (ksh, bash, sh) |
| Error Handling | Basic | Comprehensive with fallbacks |
| Progress Feedback | Minimal | Real-time with cognitive load management |
| Dependency Checking | None | Comprehensive validation |
| Output Structure | Basic | Professional with executive summary |
| Cognitive Architecture | None | Full 7±2 memory management |
| Language | Norwegian comments | English documentation |
| OpenBSD Integration | Partial | Native with security focus |

## Performance Characteristics

- **Startup Time**: ~2-5 seconds for validation
- **DNS Resolution**: ~1-3 seconds with fallbacks
- **Port Scanning**: Varies by target (minutes to hours)
- **Memory Usage**: Minimal (<10MB)
- **Network Impact**: Respectful rate limiting

## Contributing

When modifying this tool:

1. Maintain POSIX compliance
2. Preserve cognitive architecture principles
3. Test with various targets and network conditions
4. Update documentation for new features
5. Validate with shellcheck and test_nmap.sh

## License

This tool is part of the pubhealthcare repository and follows the same licensing terms. Use responsibly and only on networks you own or have explicit permission to test.