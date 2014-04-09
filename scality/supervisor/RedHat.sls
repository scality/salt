
include:
  - scality.repo

extend:
  scality-supervisor:
    cmd.run:
      - name: echo "y" | /usr/local/bin/scality-supervisor-config && sleep 5
      - template: jinja
      - unless: test -d /etc/scality-supervisor
      - require:
        - pkg: scality-supervisor
    service:
    - require:
      - cmd: scality-supervisor

