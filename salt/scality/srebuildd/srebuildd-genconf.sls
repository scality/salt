
srebuildd-genconf:
  pkg.installed:
    - names:
        - scality-ringsh
        - python-scalitycs
  file:
    - managed
    - template: jinja
    - name: /srv/salt/scality/generated/srebuildd.conf
    - source: salt://scality/srebuildd/srebuildd.conf.tmpl

