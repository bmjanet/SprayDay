# SprayDay

A simple **[NetExec](https://github.com/Pennyw0rth/NetExec) wrapper** with added database credential check and a `--default`
credential mode. Point it at a target, tick the services you want in an interactive checklist,
and it sprays either your own credentials or a curated set of default credentials per service.
Only successful logins stream to your terminal, live.

> ⚠️ **For authorized security testing only.**

## Demo

Demo Video to come (In case you find this now)

## Setup

```bash
git clone <repo-url> SprayDay
cd SprayDay
sudo ./install.sh
sprayday --help
```

`install.sh` sets up an isolated Python venv for InquirerPy (avoiding Kali's
`externally-managed-environment` error) and drops a `sprayday` launcher on your `PATH`, so you can
run it from anywhere. The backend tools it relies on (`nxc`, `mysql`, `psql`) already ship with
Kali. To uninstall: `sudo rm -rf /opt/sprayday /usr/local/bin/sprayday`.

## Usage

```bash
# Manual: spray a username/password (each a single value or a file)
sprayday 10.10.10.10 -u admin -p 'P@ssw0rd!'
sprayday 10.10.10.0/24 -u users.txt -p passwords.txt

# Default: spray curated default creds per service (ignores -u/-p)
sprayday 10.10.10.10 --default

# Skip the interactive menu with --services
sprayday 10.10.10.10 --default --services mysql,pgsql,mssql
```

The target is passed straight to NetExec, so anything `nxc` accepts works: IP, hostname, CIDR,
range, or a target file. Omit `--services` to get the interactive checklist.

Services: `smb, ldap, winrm, rdp, ssh, mssql` (via `nxc`), plus `mysql` and `pgsql` (via the
`mysql` / `psql` clients). Curated default credentials live in the `DEFAULT_CREDS` dictionary near
the top of the `sprayday` script — edit it to taste.

## License

GPLv3 — see [LICENSE](LICENSE).
