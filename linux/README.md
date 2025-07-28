## Requirement 

Ubuntu server 22.04 x86_64 and above

## Install

```
git clone https://github.com/viabtc/mineragent.git
cd mineragent/linux
```

### How to Use

Use the `start.sh` script to run the mineragent. The script will also automatically set up a cron job to ensure the agent stays running.

**Basic Usage:**

To start the agent for a specific coin (e.g., btc or ltc):
```bash
./start.sh btc
```
or
```bash
./start.sh ltc
```

**Advanced Usage (Configuring Stratum Servers):**

You can specify up to three stratum servers directly from the command line. The script will update the `config.json` file for you.

The format for each server is `host:port:ssl|nossl`.

- `host`: The stratum server address (e.g., `btc.viabtc.com`).
- `port`: The stratum server port (e.g., `3333`).
- `ssl|nossl`: Use `ssl` for a secure connection or `nossl` for a standard connection.

**Example:**

To start the BTC agent and configure it with two stratum servers:
```bash
./start.sh btc btc.viabtc.com:3333:nossl btc-ssl.viabtc.io:551:ssl
```

The script will handle starting the correct agent, updating the configuration, and setting up the monitoring cron job.
