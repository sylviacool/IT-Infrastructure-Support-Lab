# IT Infrastructure & Support Lab

A self-built IT Support / Sysadmin lab demonstrating practical, hands-on skills across Linux administration, Bash automation, SSH remote access, self-hosted ticketing, networking troubleshooting, and Windows endpoint support — built and documented independently as a portfolio project.

This project complements my [Active Directory Enterprise Lab](link-to-project-1) by covering the Linux, remote administration, and support-ticketing side of IT infrastructure work.

## Overview

**"Can I troubleshoot and support real IT infrastructure?"**

This lab was built in VirtualBox using Ubuntu Linux and Windows 11 VMs. The troubleshooting documented here is genuine — including real networking failures, permission issues, and configuration problems that came up during setup and were diagnosed and resolved as they occurred, not staged for the sake of documentation.

## Technologies & Concepts

- Linux Administration (Ubuntu) — users, permissions, package management, filesystem hierarchy
- Bash Scripting & Automation — custom scripts, cron scheduling
- SSH Remote Administration — key-based authentication, server hardening
- Self-Hosted Ticketing (Peppermint) — Docker, Docker Compose, ticket lifecycle, escalation
- Networking — subnetting, DNS, DHCP, port verification, traceroute analysis
- Windows Endpoint Support — Event Viewer, Services, PowerShell, Task Scheduler
- VirtualBox — multi-VM lab environment (NAT Networking)

## Table of Contents

1. [Lab Environment](#1-lab-environment)
2. [Linux Administration](#2-linux-administration)
3. [Bash Automation](#3-bash-automation)
4. [SSH Remote Administration](#4-ssh-remote-administration)
5. [Help Desk & Ticketing](#5-help-desk--ticketing)
6. [Networking Troubleshooting](#6-networking-troubleshooting)
7. [Windows Endpoint Support](#7-windows-endpoint-support)

---

## 1. Lab Environment

Built and verified a multi-VM lab in VirtualBox: an Ubuntu Desktop VM and a Windows 11 VM, connected via a shared VirtualBox NAT Network.

While verifying the environment, Ubuntu's network adapter (originally set to Bridged mode over Wi-Fi) failed to obtain reliable network connectivity. I diagnosed the issue using `nmcli device status` and resolved it by switching the VM to a NAT Network, which provided reliable connectivity.

Separately, the Windows 11 VM (carried over from a previous Active Directory lab) showed a duplicate IP address conflict and an unreachable DNS server left over from its prior domain membership. Diagnosed via `ipconfig /all`, resolved by removing the machine from the domain and resetting the NAT Network's DHCP server in VirtualBox (which had a stale lease record), then verified with clean `ipconfig` output and successful pings to both the gateway and the internet.

**Screenshots:** [`screenshots/01-lab-environment/`](screenshots/01-lab-environment/)
- `01-lab-environment-virtualbox-overview.png` — VirtualBox lab overview (3 VMs)
- `02-ubuntu-network-fixed-nat.png` — Ubuntu network fixed, working IP
- `03-ubuntu-internet-connectivity.png` — Internet connectivity verified
- `04-windows11-network-fixed-clean-ping.png` — Windows 11 network fixed, verified

**Key takeaway:** Diagnosed a real network-layer failure at the DHCP/routing level, distinguished between two different root causes producing similar symptoms (a Bridged/Wi-Fi connectivity failure vs. stale DHCP lease + leftover domain config), and resolved both independently.

---

## 2. Linux Administration

Demonstrated core Linux user and permissions management on Ubuntu.

Created a user account (`jdoe`) with `adduser`, and examined the account structure via `/etc/passwd` and `/etc/shadow` — understanding why password hashes are stored separately from world-readable account metadata.

Demonstrated file and directory permissions hands-on: created a file as `jdoe`, confirmed that a second user (`ogechi`) was correctly blocked from reading it — not because of the file's own permissions, but because the home directory itself denied access (`rwxr-x---`). Used `sudo` to override this as root, demonstrating the distinction between file-level and directory-level permission enforcement.

Fixed a "Permission denied" script execution error using `chmod +x`, demonstrating both symbolic permission notation and the reason newly created scripts aren't executable by default.

Closed a gap identified during the initial audit — package removal (`apt remove`) — by installing, verifying, and cleanly removing a test package (`cowsay`), and covered `apt autoremove` for dependency cleanup.

**Screenshots:** [`screenshots/02-linux-administration/`](screenshots/02-linux-administration/)
- `05-linux-user-creation-jdoe.png` — User creation, `/etc/passwd`/`/etc/shadow` *(password hash redacted before publishing)*
- `06-linux-permissions-jdoe-notes.png` — File/directory permissions, sudo override
- `07-linux-chmod-executable-script.png` — chmod +x fix
- `08-linux-package-management-cowsay.png` — apt install/remove lifecycle

**Note:** The password hash visible in `05-linux-user-creation-jdoe.png` was redacted prior to publishing — password hashes should never be shared publicly, even from lab/training environments.

**Key takeaway:** Understood and demonstrated the difference between file-level and directory-level permission enforcement, and closed a real, self-identified knowledge gap rather than assuming prior course exposure was sufficient.

---

## 3. Bash Automation

Designed and built two original Bash scripts from scratch (not copied from a tutorial), closing two gaps identified at the start of this project: independently-authored scripting, and independently-verified task scheduling.

**`create_user.sh`** — a user-creation script with genuine input validation: checks the script is run as root (`$EUID`), checks for empty input, and checks whether the target username already exists before attempting creation. Tested against three deliberate failure scenarios (no sudo, empty input, duplicate user) plus a successful run.

**`disk_monitor.sh`** — logs a timestamp and disk usage snapshot to a log file on each run, using append (`>>`) rather than overwrite, to build a history over time. Scheduled via `cron` (`*/2 * * * *`), and independently verified it triggered automatically and correctly — without manual intervention — by checking timestamped log entries appearing on schedule.

**Scripts:** [`scripts/create_user.sh`](scripts/create_user.sh) · [`scripts/disk_monitor.sh`](scripts/disk_monitor.sh)

**Screenshots:** [`screenshots/03-bash-automation/`](screenshots/03-bash-automation/)
- `09-bash-user-creation-script-testing.png` — All test scenarios (failure + success)
- `10-bash-user-creation-script-source.png` — Full script source
- `11-cron-scheduled-monitoring-verified.png` — Verified automatic cron execution

**Key takeaway:** Automation without logging is automation you can't verify or trust. Both scripts were manually tested before being scheduled, and cron's unattended execution was independently confirmed via log evidence — not assumed.

---

## 4. SSH Remote Administration

Verified the SSH server on Ubuntu, then connected from Windows using password authentication as a baseline.

Generated a dedicated SSH key pair (ed25519), deployed the public key to Ubuntu's `authorized_keys`, and verified key-based login succeeded with no password prompt.

Hardened the SSH server by disabling password authentication (`PasswordAuthentication no` in `sshd_config`) and restarting the service — a real production security practice that reduces brute-force attack surface. Verified the change in both directions: confirmed password-only login attempts are correctly rejected (`Permission denied (publickey)`), and confirmed key-based login continues to work.

**Screenshots:** [`screenshots/04-ssh-remote-admin/`](screenshots/04-ssh-remote-admin/)
- `12a-ssh-password-auth-first-connection.png` / `12b-ssh-password-auth-verified.png` — Initial connection and host key verification
- `13-ssh-key-auth-verified.png` — Key generation, deployment, and passwordless login
- `14-ssh-hardening-password-disabled.png` — Hardening verified both ways

**Key takeaway:** Before disabling password authentication, key-based login was already confirmed working — avoiding the real risk of a self-inflicted lockout, a genuine caution on remote-only servers without local console access.

---

## 5. Help Desk & Ticketing

Deployed Peppermint (an open-source ticketing system) via Docker Compose. During setup, found and fixed a real configuration issue: the `docker-compose.yml`'s `API_URL` was hardcoded to a stale IP address from a previous network setup, which would have broken frontend-to-backend connectivity — corrected it to match the current environment before startup.

Logged in using Peppermint's documented default credentials, then immediately changed the password, following standard security practice for newly deployed self-hosted software.

Created two additional non-admin user accounts to serve as realistic ticket reporters, then created and fully documented four support tickets covering real troubleshooting performed earlier in this project: DNS resolution failure, new employee account provisioning, script permission errors, and an SSH access request.

The SSH ticket was used to demonstrate a full escalation workflow: recognizing that the request involved remote administrative access and a security-sensitive, server-wide configuration change — not just a routine grant — and escalating for approval before implementing, rather than proceeding unilaterally.

**Screenshots:** [`screenshots/05-peppermint-ticketing/`](screenshots/05-peppermint-ticketing/)
- `15` – Docker Compose deployment · `16` – Working web interface · `17` – Default password changed · `18` – User management
- `19` – Ticket 1: DNS resolution · `20` – Ticket 2: Account setup · `21` – Ticket 3: Script permissions
- `22` – Ticket 4: Escalation · `23` – Ticket 4: Resolved

**Key takeaway:** Escalation is a judgment skill, not just a ticket status — recognizing when a request's impact extends beyond a single user and requires approval, rather than simply completing every request immediately regardless of scope.

---

## 6. Networking Troubleshooting

Applied subnetting fundamentals to the lab's actual network (`10.0.2.0/24`): calculated the network address, broadcast address, and usable host range by hand, then verified the result against live system output (`ip a`).

Used `ss -tulpn` to confirm SSH, Peppermint, and Postgres were correctly listening on their expected ports — and to understand what a listening port does (and doesn't) prove about a service's overall health.

Ran `tracert` against the Ubuntu VM and two external destinations. The local VM correctly appeared as one hop, as expected on a shared virtual network. The external destinations also unexpectedly appeared as a single reported hop. This does not mean that only one router exists between the VM and the destination — `tracert` only displays routers that respond to its probes, so some intermediate hops may not appear because their responses are filtered or suppressed somewhere along the path.

**Screenshots:** [`screenshots/06-networking-troubleshooting/`](screenshots/06-networking-troubleshooting/)
- `24-networking-subnet-calculation-verified.png`
- `25-networking-port-verification.png`
- `26-networking-traceroute-analysis.png`

**Key takeaway:** When a result doesn't match expectations, the accurate response is to state what was observed and what can and can't be concluded from it — not to assert a specific cause that can't be verified from the available evidence.

---

## 7. Windows Endpoint Support

Investigated the Windows System log (Event Viewer) for events related to earlier domain-connectivity issues (Section 1). An initial keyword search surfaced a false positive (an unrelated Credential Guard status event); continued searching located a genuine Netlogon error describing a failed secure session with the domain controller — consistent with the period when the domain controller VM was powered off, before the machine was formally removed from the domain.

Reviewed the DHCP Client service (services.msc) — the Windows service involved in the IP/DNS issues diagnosed in Section 1.

Ran PowerShell diagnostics deliberately paralleling the earlier Linux work: `Get-PSDrive -PSProvider FileSystem` (disk usage, comparable to `df -h`) and `Get-Process | Sort-Object CPU -Descending | Select-Object -First 5` (top CPU consumers, comparable to `ps -ef`).

Built a Windows Task Scheduler job mirroring Section 3's cron automation. Hit a genuine PowerShell syntax issue — using `;` to separate two commands caused only the second command's output to reach the log file, since `;` runs commands independently while `|` pipes output onward. Diagnosed this by testing manually outside the scheduler, fixed it using a script block (`& { cmd1; cmd2 } | Out-File`), and verified the fix across multiple successful runs.

**Screenshots:** [`screenshots/07-windows-endpoint-support/`](screenshots/07-windows-endpoint-support/)
- `27-windows-event-viewer-netlogon-error.png`
- `28-windows-services-dhcp-client.png`
- `29-powershell-diagnostics-disk-process.png`
- `30-windows-task-scheduler-diskcheck.png`

**Key takeaway:** Windows and Linux automation follow the same underlying pattern — a trigger, an action, and a log to verify unattended execution actually happened. A real syntax bug was found, correctly diagnosed, and fixed — not avoided by only showing a clean first attempt.

---

## Overall Reflections

This project was built hands-on, end to end, including the setbacks — networking failures, permission errors, and a real PowerShell syntax bug are documented here because they happened, not edited out for a cleaner narrative. Troubleshooting through genuine problems, rather than following a script that worked on the first try, is what this project is actually meant to demonstrate.
