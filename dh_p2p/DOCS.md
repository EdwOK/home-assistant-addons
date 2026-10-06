# Dahua P2P Tunnel

Reaches a Dahua VTO (or camera) through Dahua's P2P cloud using only its serial
number, so the [Dahua integration](https://github.com/rroller/dahua) works
when Home Assistant is not on the device's network.

It runs a patched [dh-p2p](https://github.com/khoanguyen-3fc/dh-p2p) that
forwards these ports over a single P2P relay session:

| Local port (on the HA host) | Device port | Used for |
|---|---|---|
| `http_port` (default 8080) | 80 | HTTP API |
| `rtsp_port` (default 1554) | 554 | RTSP video |
| 5000 (fixed) | 5000 | VTO events |

Port 5000 is fixed because the Dahua integration always uses it for VTO
events, so nothing else on the HA host may use port 5000.

## Configuration

- `serial`: the device's serial number (P2P page in its web UI, the label, or
  the DMSS app). P2P must be enabled on the device.
- `bind_address`: `127.0.0.1` (default) keeps the tunnel reachable only from
  the HA host. The tunnel itself has no authentication.
- `http_port`, `rtsp_port`: change these if they clash with another add-on.
- `debug_log`: log every P2P packet.

## Dahua integration settings

- Address: `127.0.0.1`
- Port: the `http_port` value (default `8080`)
- RTSP port: the `rtsp_port` value (default `1554`)
- Username and password: the device's own login

## Notes

- Traffic goes through Dahua's relay servers, so expect some video delay.
- If the session drops, the add-on reconnects automatically within about a
  minute.
- The device seems to allow only a few P2P sessions at a time, and dropped
  sessions can take several minutes to free up. If the add-on keeps logging
  "P2P handshake timed out", stop it for 5-10 minutes and start it again.
