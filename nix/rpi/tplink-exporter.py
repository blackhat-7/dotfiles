"""Prometheus exporter for per-device traffic on a TP-Link Archer C80."""

import logging
import os
import time

from prometheus_client import start_http_server
from prometheus_client.core import REGISTRY, GaugeMetricFamily
from tplinkrouterc6u import TplinkC80Router


class RouterCollector:
    def __init__(self):
        self.router = TplinkC80Router(
            os.environ["TPLINK_HOST"], os.environ["TPLINK_PASSWORD"], logger=logging.getLogger("tplink")
        )
        # Firmware 1.14 rejects the login (HTTP 408) without a Referer.
        self.router._session.headers["Referer"] = os.environ["TPLINK_HOST"] + "/"
        self.logged_in = False

    def describe(self):
        # Avoid a router call when registering; collect() would crash startup if it fails.
        return []

    def devices(self):
        # Reuse the session; log in again once if it expired.
        for attempt in range(2):
            try:
                if not self.logged_in:
                    self.router.authorize()
                    self.logged_in = True
                return self.router.get_status().devices
            except Exception:
                self.logged_in = False
                if attempt:
                    raise

    def collect(self):
        labels = ["mac", "name", "ip", "connection"]
        down = GaugeMetricFamily("tplink_device_download_bytes_per_second", "Device download rate", labels=labels)
        up = GaugeMetricFamily("tplink_device_upload_bytes_per_second", "Device upload rate", labels=labels)
        for d in self.devices():
            if not d.active:
                continue
            values = [d.macaddr, d.hostname, d.ipaddr, d.type.value]
            # The router reports bits per second.
            down.add_metric(values, d.down_speed / 8)
            up.add_metric(values, d.up_speed / 8)
        yield down
        yield up


REGISTRY.register(RouterCollector())
start_http_server(int(os.environ["EXPORTER_PORT"]), addr="127.0.0.1")
while True:
    time.sleep(3600)
