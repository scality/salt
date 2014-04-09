
include:
  - scality.req.debconf
  - scality.repo

extend:
  scality-supervisor:
    debconf.set:
      - name: scality-supervisor
      - data:
          scality-supervisor/accept-license: {'type': 'boolean', 'value': True}
      - require:
        - pkg: debconf-utils
    pkg:
      - require:
        - debconf: scality-supervisor
