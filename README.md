# permguard

**Fleet script permission auditor & enforcer**

[![Version](https://img.shields.io/badge/version-1.0.0-red)](https://github.com/SaharshPamecha/permguard)
[![License](https://img.shields.io/badge/license-MIT-red)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Linux-red)](https://github.com/SaharshPamecha/permguard)

A production-grade CLI tool for auditing and enforcing script permissions across Linux fleets. Detects dangerous 777, missing execute bits, and supports OpenClaw AI agent script hardening.

**Live Demo**: https://permguard.vercel.app

---

## The Problem

Permission drift kills automation. Scripts lose execute bits during:
- `rsync` or `scp` transfers
- Git pulls in CI/CD pipelines
- Docker volume mounts
- Ansible `copy` modules
- Backup restores

**At scale**, this causes:
- Failed cron jobs at 2 AM
- CI/CD pipeline failures
- Security audit failures (CIS 6.1, 6.2 violations)
- AI agents like OpenClaw failing to execute skills

Manual `chmod 755` is tedious across 100+ servers. And blindly running `chmod -R 777` is a security disaster waiting to happen.

---

## Features

- **`scan`** — Detect permission issues (777, 000, world-writable)
- **`enforce`** — Fix permissions with safe defaults (755 for scripts, 644 for configs)
- **`report`** — Generate HTML compliance reports for auditors
- **OpenClaw Support** — Detect and harden AI agent scripts

### What It Detects

| Issue | Risk | Detection |
|-------|------|-----------|
| `777` permissions | Anyone can modify execute code | ✓ |
| `000` permissions | Script can't run at all | ✓ |
| World-writable | Unauthorized modification | ✓ |
| Missing execute on scripts | Automation failures | ✓ |

---

## Installation

```bash
curl -sL https://raw.githubusercontent.com/SaharshPamecha/permguard/main/install.sh | sudo bash
```

Or manual:

```bash
sudo curl -fsSL https://raw.githubusercontent.com/SaharshPamecha/permguard/main/cli/permguard -o /usr/local/bin/permguard
sudo chmod +x /usr/local/bin/permguard
```

---

## Usage

### Scan for Issues

```bash
permguard scan
```

Output includes:
- Files with dangerous 777 permissions
- Scripts missing execute bit (000)
- OpenClaw AI agent scripts detected
- Suggested fixes per file

### Dry Run Before Enforce

```bash
sudo permguard enforce /opt --dry-run
```

### Apply Fixes

```bash
sudo permguard enforce /opt
```

Safety features:
- Safe defaults: 755 for scripts, 644 for configs
- Preserves ownership
- Dry-run available before applying

### Generate Report

```bash
permguard report
```

Creates HTML compliance report at `/tmp/permguard-reports/`

---

## OpenClaw AI Agent Support

permguard detects scripts in OpenClaw skill directories:
- `/opt/openclaw/skills`
- `~/openclaw/skills`
- Any path matching `*openclaw*`, `*skills*`, `*agents*`

This ensures your AI automation scripts have correct permissions for agent execution.

---

## Real-World Usage

### Fleet-Wide Audit

```bash
# From jumphost, scan multiple servers
for server in app-01 app-02 app-03; do
    ssh $server "permguard scan /opt /scripts"
done
```

### Ansible Integration

```yaml
- name: Ensure script permissions
  hosts: all
  tasks:
    - name: Run permguard scan
      command: permguard scan /opt
      register: scan_result
      changed_when: false
    
    - name: Fix if issues found
      command: permguard enforce /opt
      when: "'✗' in scan_result.stdout"
```

### Daily Compliance

```bash
# Cron for continuous monitoring
0 3 * * * permguard report && scp /tmp/permguard-reports/*.html compliance@central:/evidence/
```

---

## Design Philosophy

- **Principle of Least Privilege**: 755 for executables, 644 for configs
- **Safety-first**: Dry-run before enforce, never blindly chmod 777
- **Audit-ready**: HTML reports satisfy CIS, SOC2, ISO27001
- **Zero dependencies**: Pure Bash, works on any Linux distro

---

## Interactive Demo

Try the web simulator:

**[Launch Interactive Demo: https://permguard.vercel.app](https://permguard.vercel.app)**

The web version demonstrates all `permguard` commands against a simulated environment with crimson/magenta theme (Day 4's visual identity).

---

## CIS Benchmark Alignment

| Control | permguard Check |
|---------|-----------------|
| CIS 6.1 | File permissions (744, 755, etc.) |
| CIS 6.2 | World-writable files detection |
| CIS 6.3 | Script execution permissions |

---

## Source Code

**Repository**: https://github.com/SaharshPamecha/permguard

```
permguard/
├── cli/
│   └── permguard          # Main Bash CLI
├── web/                   # Next.js demo website
├── examples/
│   └── ansible-playbook.yml
├── install.sh             # One-line installer
├── LICENSE                # MIT License
└── README.md
```

---

## Related Projects

- **Day 1 — userctl**: [github.com/SaharshPamecha/userctl](https://github.com/SaharshPamecha/userctl) — Service account auditor
- **Day 2 — expiry-guard**: [github.com/SaharshPamecha/expiry-guard](https://github.com/SaharshPamecha/expiry-guard) — Temporary user lifecycle
- **Day 3 — ssh-shield**: [github.com/SaharshPamecha/ssh-shield](https://github.com/SaharshPamecha/ssh-shield) — SSH hardening

---

## License

MIT License — See [LICENSE](LICENSE) for details.

Built by [Saharsh Pamecha](https://x.com/SaharshPamecha1) as part of a 100-day open-source DevOps journey.
