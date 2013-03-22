
scality-ringsh:
  pkg:
    - installed
    - names:
        - scality-ringsh
  file:
    - managed
    - name: /usr/local/scality-ringsh/ringsh/config.py
    - template: jinja
    - source: salt://scality/ringsh/config.py

