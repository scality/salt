{% set variant_old = salt['pillar.get']('scality:variant', 'stable') %}
{% set variant = salt['pillar.get']('scality:repository:variant', variant_old) %}

{% if salt['pillar.get']('scality:repository:private', False) %}
  {% set name = '%s (private)'|format(variant|capitalize)  %}
  {% set address = salt['pillar.get']('scality:repository:private', False) %}
{% else %}
  {% set login_old = salt['pillar.get']('scality:login', 'please_define_login_in_pillar') %}
  {% set login = salt['pillar.get']('scality:repository:login', login_old) %}
  {% set password_old = salt['pillar.get']('scality:password', 'please_define_password_in_pillar') %}
  {% set password = salt['pillar.get']('scality:repository:password', password_old) %}
  {% set name = variant|capitalize %}
  {% if grains['os'] == 'Ubuntu' %}
    {% set address = 'http://%s:%s@packages.scality.com'|format(login, password) %}
  {% elif grains['os_family'] == 'RedHat' %}
    {% set address = "http://%s:%s@packages.scality.com"|format(login, password) %}
  {% endif %}
{% endif %}

scality-repository:
  pkgrepo.managed:
{%- if grains['os'] == 'Ubuntu' %}
    - name: deb [arch=amd64] {{ address }}/{{ variant }}/ubuntu {{grains['oscodename']}} main
    - humanname: Scality {{ name }} for {{grains['oscodename']}}
    - file: /etc/apt/sources.list.d/scality.list
    - dist: {{grains['oscodename']}}
    - keyid: 5B1943DD
    - keyserver: pgp.mit.edu
{%- elif grains['os_family'] == 'RedHat' %}
    - name: scality
    - humanname: Scality {{ name }} - RHEL $releasever - $basearch
    - baseurl: {{ address }}/{{ variant }}/centos/$releasever/$basearch/
    - gpgcheck: 0
    - order: 1
{%- endif %}
