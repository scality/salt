include:
  - scality.ringsh

python-scalitycs:
  pkg.installed:
    - skip_verify: True
    - require:
      - pkg: scality-ringsh
      - file: scality-ringsh
    - sources:
{%- if grains['os_family'] == 'RedHat' %}
{%- set major=grains['osmajorrelease'][0] %}
      - python-scalitycs: salt://scality/python/python-scalitycs-1.0.3-1.el{{ major }}.noarch.rpm
{%- endif %}
{%- if grains['os_family'] == 'Debian' %}
      - python-scalitycs: salt://scality/python/python-scalitycs_1.0.3_all.deb
{%- endif %}
  module.run:
    - name: saltutil.refresh_modules
    - watch:
      - pkg: python-scalitycs

