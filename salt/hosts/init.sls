{{grains['id']}}:
  host:
    - present
    - ip: {{salt['ip_interfaces'](interface=pillar['prod_iface'])[0]}}

