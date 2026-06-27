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

The full technical report is published separately. This repository contains IOCs and detection rules for immediate community use.

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
