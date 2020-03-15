# docker-transmission-gc
Docker image to periodically run garbage collection in transmission

## Usage

### Configuration

Configuration is done via environment variables.

| Name | Default | Description |
| ---- | ------- | ----------- |
| `TRANSMISSION_URL` | `http://transmission:9091` | The url where transmission is running. Note: The RPC api needs to be available here. We will automatically append the rpc path (`/transmission/rpc`) to this url. |
| `TRANSMISSION_RPC_PATH` | `/transmission/rpc` | The path to the RPC api. |
| `TRANSMISSION_USERNAME` | *none* | The username to access the RPC api. Alternatively mount a netrc file to `/root/.netrc`. |
| `TRANSMISSION_PASSWORD` | *none* | The password to access the RPC api. Alternatively mount a netrc file to `/root/.netrc`. |
| `VERBOSE` | `false` | Whether or not to verbosely print out data. |
| `RUN_ON_START` | `true` | Whether or not to run the garbage collection on startup (i.e. before starting up the cron scheduler). |
| `CRON_EXPRESSION` | `0 * * * *` | The cron expression for how often to run garbage collection. Defaults to every hour on the hour. |
| `DRY_RUN` | `false` | When set to true, the RPC call to remove torrents will be skipped. |
| `DELETE_DATA` | `true` | Whether or not to delete data when removing torrents. |

### docker-compose

```yaml
transmission-gc:
    image: ammmze/transmission-gc:latest
    environment: 
        - TRANSMISSION_URL=https://transmission.example.com
        - TRANSMISSION_USERNAME=my-rpc-user
        - TRANSMISSION_PASSWORD=my-rps-password
```
