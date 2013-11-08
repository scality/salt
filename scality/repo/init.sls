{% set login = salt['pillar.get']('scality:login', 'please_define_login_in_pillar') %}
{% set password = salt['pillar.get']('scality:password', 'please_define_password_in_pillar') %}
{% set variant = salt['pillar.get']('scality:variant', 'stable') %}

scality-repository:
  pkgrepo.managed:
{%- if grains['os'] == 'Ubuntu' %}
    - name: deb [arch=amd64] http://{{login}}:{{password}}@packages.scality.com/{{variant}}/ubuntu/ {{grains['oscodename']}} main
    - humanname: Scality {{variant|capitalize}} for {{grains['oscodename']}}
    - file: /etc/apt/sources.list.d/scality.list
    - dist: {{grains['oscodename']}}
    - keyid: 5B1943DD
    - keyserver: pgp.mit.edu
{%- elif grains['os_family'] == 'RedHat' %}
    - name: scality
    - humanname: Scality {{variant|capitalize}} - RHEL $releasever - $basearch
    - baseurl: http://{{login}}:{{password}}@packages.scality.com/{{variant}}/centos/$releasever/$basearch/
    - gpgcheck: 0
    - order: 1
{%- endif %}
