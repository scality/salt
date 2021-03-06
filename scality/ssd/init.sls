{%- set nb_ssds = salt['pillar.get']('scality:nb_ssds', 0) %}
{%- if pillar['nb_ssds'] is defined and pillar['nb_ssds'] > 0 %}
include:
  - scality.node

{%- set ssds = range(1, nb_ssds+1) %}
{%- set hdds = range(1, salt['pillar.get']('scality:nb_disks')+1) %}
{%- set mount_prefix_ssd = salt['pillar.get']('scality:mount_prefix_ssd') %}
{%- for n in hdds %}
scality-ssd-{{n}}:
  cmd.run:
    - name: echo "nvp={{mount_prefix_ssd}}{{loop.cycle(*ssds)}}/disk{{loop.index}}" >> /etc/biziod/bizobj.disk{{loop.index}}
    - unless: grep -q '^nvp=' /etc/biziod/bizobj.disk{{loop.index}}
    - require:
      - cmd: scality-node
  file.directory:
    - name: {{mount_prefix_ssd}}{{loop.cycle(*ssds)}}/disk{{loop.index}}
    - makedirs: True
{%- endfor %}
{%- else %}
scality-ssd:
  cmd.run:
    - name: echo "Skipping SSD configuration, nb_ssds is 0 or not defined"
{%- endif %}

