# SprayDay

**SprayDay** is a multi-protocol credential sprayer for a single target. Point it at a host,
tick the services you want to test in an interactive checklist (thanks InquirerPy), and it sprays either your own
credentials or a set of curated default credentials baked in per service (pgsql has different default creds than ssh).

It's a database-aware credential enumeration script inspired by NetSpray, alongside the usual
SMB/LDAP/WinRM/RDP/SSH protocols, it adds **MSSQL, MySQL, and PostgreSQL** default
credential checks.

> ⚠️ **For authorized security testing only**

## Pretty cool Features

- **Interactive service picker** - an [InquirerPy](https://github.com/kazhala/InquirerPy)
  CLI checkbox menu for choosing which of the 8 supported services to spray.
- **Two modes: Manual and Default**
  - **Manual** - spray a username/password (each a single value *or* a file) you supply.
  - **Default** - add the `--default` flag to spray a curated list of well-known default credentials, tailored per
    service (see below). I added the lists into the script based on personal experience and research.
- **Right tool per service** - NetExec for `smb, ldap, winrm, rdp, ssh, mssql`; the native
  `mysql` and `psql` clients for MySQL and PostgreSQL.
- **So Graceful** - if a backend tool isn't installed, that service is skipped with a warning
  instead of aborting the run. However, if you run this on a Kali box, it should come with all required services baked in.
- **Valid creds logged** - every hit is written to a timestamped log file (and an optional
  `-o` file), with a deduped summary at the end.
- **Scriptable** - `--services smb,mysql` skips the interactive menu for automation.

## Supported services

| Service | Backend |
|---------|---------|
| smb, ldap, winrm, rdp, ssh, mssql | NetExec (`nxc`) |
| mysql | `mysql` client |
| pgsql | `psql` client |

## Installation

### Clone it
```bash
git clone <repo-url> SprayDay
cd SprayDay
```

### Install (recommended)
The installer creates an isolated Python venv for InquirerPy (so it won't hit Kali's
`externally-managed-environment` error) and puts `sprayday` on your `PATH`:
```bash
sudo ./install.sh
sprayday --help
```

### Or run it in place
```bash
pip3 install InquirerPy      # or: pip3 install -r requirements.txt
chmod +x sprayday
./sprayday --help
```

## Usage

```
Usage: sprayday [IP] [-u USER|FILE] [-p PASS|FILE] [--default]
                [--services LIST] [--continue-on-success] [--no-bruteforce]
                [-o FILE]

Positional:
  IP                     Target IP address (you'll be prompted if omitted)

Authentication (choose one mode):
  -u, --user USER|FILE   Username, or a file of usernames (one per line)
  -p, --password P|FILE  Password, or a file of passwords (one per line)
  --default              Spray curated default credentials per service
                         (standalone — ignores -u/-p)

Options:
  --services LIST        Comma-separated services; skips the interactive menu
  --continue-on-success  Keep spraying a service after a valid cred is found
  --no-bruteforce        Pass --no-bruteforce to NetExec (safer, slower)
  -o, --output FILE      Also append valid credentials to this file
```

### Examples
```bash
# Prompt for IP + service checklist, spray one credential
sprayday -u admin -p 'P@ssw0rd!'

# Explicit target, username/password lists from files
sprayday 10.10.10.10 -u users.txt -p passwords.txt

# Default-credential mode across the database services (no menu)
sprayday 10.10.10.10 --default --services mysql,pgsql,mssql

# Fully interactive default-credential sweep
sprayday 10.10.10.10 --default
```

## Default credential lists

With `--default`, SprayDay tries a curated set of `user:password` pairs per selected service.
The high-signal database and SSH lists are drawn from
[SecLists](https://github.com/danielmiessler/SecLists) `*-betterdefaultpasslist.txt` and common
public references. A few examples:

- **mssql** - `sa:<blank>`, `sa:sa`, `sa:password`, `sa:Password123`, `admin:admin`, …
- **mysql** - `root:<blank>`, `root:root`, `root:mysql`, `root:password`, `admin:admin`, …
- **pgsql** - `postgres:<blank>`, `postgres:postgres`, `postgres:password`, `admin:admin`, …
- **ssh** - `root:root`, `root:toor`, `pi:raspberry`, `admin:admin`, `kali:kali`, …

> **Note on SMB/LDAP/WinRM/RDP:** these are normally domain-authenticated, so universal "default
> credentials" barely exist. Their `--default` lists are intentionally thin, generic local-account
> guesses (`administrator:`, `guest:`, …) and will usually miss — they're included for
> completeness, not because they're likely to land.

To extend or tune any list, edit the `DEFAULT_CREDS` dictionary near the top of the `sprayday`
script.

## Requirements

- Kali Linux (or any host with the backend tools installed)
- `python3` + `python3-venv`
- Python package: `InquirerPy`
- Backend tools: `nxc` (NetExec), `mysql` client, `psql` client — all present by default on Kali

## License

GPLv3 — see [LICENSE](LICENSE).
