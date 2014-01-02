{%- set supervisor_ip = salt['pillar.get']('scality:supervisor_ip', '127.0.0.1') -%}
default_config = \
{   'accessor': None,
    'brs2': None,
    'dsup': {   'url': "https://{{ supervisor_ip }}:3443"},
    'key': {   'class1translate': '0'},
    'node': None,
    'supervisor': {   'url': "https://{{ supervisor_ip }}:2443"}}
