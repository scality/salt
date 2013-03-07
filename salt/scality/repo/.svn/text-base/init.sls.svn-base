{% if grains['os'] == 'Ubuntu' %}
repo:
  cmd.run:
    - name: sudo apt-key adv --keyserver pgp.mit.edu --recv-keys 5B1943DD
    - unless: apt-key list | grep -q 5B1943DD
    - require:
      - file: /etc/apt/sources.list.d/scality.list
  file:
    - managed
    - name: /etc/apt/sources.list.d/scality.list
    - source: salt://scality/repo/scality.list
    - template: jinja
    - skip_verify: False
{% elif grains['os_family'] == 'RedHat' %}
repo:
  file:
    - managed
    - name: /etc/yum.repos.d/scality.repo
    - source: salt://scality/repo/scality.repo
    - template: jinja
    - skip_verify: True
    - order: 1
{% endif %}
