{{grains['id']}}:
  host:
    - present
    - ip: {{salt['network.ip_addrs']('eth0')[0]}} # Hardcode device for now
