include:
  - scality.ringsh

python-scalitycs:
  pkg:
    - installed
    - skip_verify: True
    - require:
      - pkg: scality-ringsh
      - file: scality-ringsh

