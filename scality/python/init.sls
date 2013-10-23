include:
  - scality.ringsh

python-scalitycs:
  pkg.installed:
    - skip_verify: True
    - require:
      - pkg: scality-ringsh
      - file: scality-ringsh
{%- if grains['os_family'] == 'RedHat' %}
    - sources:
      - python-scalitycs: salt://scality/python/python-scalitycs-1.0.1.dev1-1.el6.noarch.rpm
{%- endif %}
  module.run:
    - name: saltutil.refresh_modules
    - watch:
      - pkg: python-scalitycs

