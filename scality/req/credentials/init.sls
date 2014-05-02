
/tmp/scality-installer-credentials:
  file.managed:
    - mode: 0600
    - source : salt://scality/req/credentials/default.json
