{{grains['id']}}:
  host:
    - present
    - ip: {{salt['network.ip_addrs'](interface=pillar['prod_iface'])[0]}}

