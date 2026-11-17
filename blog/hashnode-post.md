# Permission Drift Is Killing Your Automation — Building permguard for Fleet-Wide Script Hardening (OpenClaw AI Agents Included)

**Day 4 of 100 Days of DevOps**

Permission drift is the silent killer of production automation. You deploy a script with `chmod 755`, and three months later it's `000` or `777`. Your cron job fails at 2 AM, your CI pipeline breaks, and your AI agent can't execute its skills.

I built `permguard` to solve this. Here's the story.

---

## The Real Problem

Scripts lose execute permissions in ways you wouldn't expect:

- **rsync/scp transfers** — Often strip execute bits
- **Git pulls in CI/CD** — Lose executable flag on some filesystems
- **Docker volume mounts** — Container UIDs mismatch host
- **Ansible copy module** — Default mode doesn't preserve execute
- **Backup restores** — Often reset to 644 or 000

At scale across 100+ servers, this becomes impossible to track manually. And the consequences are real:

- **Failed cron jobs** — Nightly backups don't run
- **CI/CD failures** — Pipeline breaks on deployment
- **Security audit failures** — CIS 6.1, 6.2 violations
- **AI agent failures** — OpenClaw skills won't execute

I dealt with this on a fleet of 200+ servers. Manual `chmod 755` wasn't scalable. Blind `chmod -R 777` was a security disaster waiting to happen.

---

## Enter permguard

A zero-dependency Bash tool for auditing and enforcing script permissions across Linux fleets.

### Core Commands

```bash
# Scan for permission issues
permguard scan

# Dry-run before fixing
sudo permguard enforce /opt --dry-run

# Apply fixes
sudo permguard enforce /opt

# Generate compliance report
permguard report
```

### What It Detects

| Issue | Risk | Example |
|-------|------|---------|
| Dangerous 777 | Anyone can modify execute code | `chmod 777 backup.sh` |
| Missing execute (000) | Script can't run | `chmod 000 cron-job.sh` |
| World-writable | Unauthorized modification | `chmod 766 config.conf` |

### Smart Defaults

- **Scripts (.sh, .py, .rb)**: 755 (owner rwx, group/others rx)
- **Configs (.conf, .cfg)**: 644 (owner rw, group/others r)
- **Directories**: 755

This follows the **Principle of Least Privilege** — give only what's needed.

---

## OpenClaw AI Agent Integration

The trending AI agent space is exploding. **OpenClaw** lets you run local shell scripts/skills from chat apps. But here's the catch:

If your OpenClaw skills have wrong permissions, the agent fails silently.

permguard detects scripts in OpenClaw directories:
- `/opt/openclaw/skills`
- `~/openclaw/skills`
- Any path matching `*openclaw*`, `*skills*`, `*agents*`

```bash
# permguard automatically detects OpenClaw scripts
┌─ OpenClaw AI Agent Scripts ─────────────────────────────────┐
  ✓ Found 3 OpenClaw-related scripts
      ! /opt/openclaw/skills/deploy-agent.sh (perms: 776)
```

This ensures your AI automation runs reliably.

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
      when: "'!' in scan_result.stdout"
```

### Daily Compliance

```bash
# Cron for continuous monitoring
0 3 * * * permguard report && \
  scp /tmp/permguard-reports/*.html compliance@central:/evidence/
```

---

## CIS Benchmark Alignment

| Control | Description | permguard Coverage |
|---------|-------------|-------------------|
| CIS 6.1 | File permissions | Detects 744, 755, 644 violations |
| CIS 6.2 | World-writable files | Flags others >= 6 |
| CIS 6.3 | SUID/SGID files | Monitors for unnecessary bits |

The tool generates HTML compliance reports that satisfy auditors from SOC2, ISO27001, and PCI-DSS.

---

## Interactive Demo

Try the web simulator at **https://permguard.vercel.app** — no installation required.

**Visual identity note**: Day 1 (userctl) used cyan. Day 2 (expiry-guard) used amber. Day 3 (ssh-shield) used teal. Day 4 (permguard) uses crimson/magenta — a "security alert" aesthetic.

---

## Installation

```bash
curl -sL https://raw.githubusercontent.com/SaharshPamecha/permguard/main/install.sh | sudo bash
```

Or manual:

```bash
sudo curl -fsSL https://raw.githubusercontent.com/SaharshPamecha/permguard/main/cli/permguard \
  -o /usr/local/bin/permguard
sudo chmod +x /usr/local/bin/permguard
```

---

## The Bigger Picture

Four tools in, and the pattern is clear:

- **Day 1 (userctl)**: Service account lifecycle
- **Day 2 (expiry-guard)**: Temporary user expiry  
- **Day 3 (ssh-shield)**: SSH hardening
- **Day 4 (permguard)**: Script permission security

Together, they form a **Linux Security Toolkit** — each independent but composable. A sysadmin could install all four and have audit coverage for accounts, temporal access, SSH posture, and script permissions.

---

## What's Next

Four down, 96 to go. The complexity increases daily. Each tool solves a real infrastructure problem I've faced personally.

If permission drift is a pain point in your fleet, try permguard. File issues. This is production-grade open source — it gets better with real-world usage.

---

**Source Code**: https://github.com/SaharshPamecha/permguard

**Live Demo**: https://permguard.vercel.app

**License**: MIT

---

**About the Author**

Saharsh Pamecha is a Staff Engineer exploring the intersection of infrastructure automation and security. This post is part of a 100-day open-source DevOps journey. Follow on [X @SaharshPamecha1](https://x.com/SaharshPamecha1) and [LinkedIn](https://www.linkedin.com/in/saharsh-pamecha-6219961b7/) for daily updates.
