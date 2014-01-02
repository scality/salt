{% set prod_iface = salt['pillar.get']('scality:prod_iface', 'eth0') %}
{{grains['id']}}:
  host:
    - present
    - ip: {{salt['network.ip_addrs'](prod_iface)[0]}} # Hardcode device for now
