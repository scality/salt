{% set login = pillar['login']|default('please_define_login_in_pillar') %}
{% set password = pillar['password'] %}
{% set variant = pillar['variant']|default('stable') %}
scality-{{variant}}:
  pkgrepo.managed:
{%- if grains['os'] == 'Ubuntu' %}
    - name: deb http://{{login}}:{{password}}@packages.scality.com/{{variant}}/ubuntu/ {{grains['oscodename']}} main
    - humanname: Scality {{variant|capitalize}} for {{grains['oscodename']}}
    - file: /etc/apt/sources.list.d/scality.list
    - dist: {{grains['oscodename']}}
    - keyid: 5B1943DD
    - keyserver: pgp.mit.edu
{%- elif grains['os_family'] == 'RedHat' %}
    - humanname: Scality {{variant|capitalize}} - RHEL $releasever - $basearch
    - baseurl: http://{{login}}:{{password}}@packages.scality.com/{{variant}}/centos/$releasever/$basearch/
    - gpgcheck: 0
    - order: 1
{%- endif %}
