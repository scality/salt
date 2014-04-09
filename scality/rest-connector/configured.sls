
include:
  - .added

{% from "scality/map.jinja" import scality with context %}

{% set data_ring = scality.rings.split(',')[0] %}

config-rest-connector:
  scality_rest_connector.configured:
    - name: {{ scality.ctor_name_prefix }}1
    - ring: {{ data_ring }}
    - values:
        msgstore_protocol_restapi:
          bwsdeferredpolicy: -1
          bwsdrvdata: arc
          chordsplitsizetrigger: 4000000
          chordsplitsizeblock: 2000000
          bwssplitsizetrigger: 4000000
          bwssplitsizeblock: 2000000
        msgstore_storage_chordbucket:
          bwsdbmesamaincos: 4
          bwsdbmesacos: 2
          bwsdbmesahost: 127.0.0.1:81
          bwsdbmesauri: /sindexd.fcgi
        ov_core_logs:
          logsdir: {{ scality.log.base_dir }}/scality-rest-connector
          logsoccurrences: 48
          logsmaxsize: 2000
        ov_protocol_dns:
          mainresolver: 127.0.0.1
        ov_protocol_netscript:
          connect timeout: 5
          socket timeout: 30
    - require:
      - scality_rest_connector: add-rest-connector

#{%- if pillar['nodes'] is defined %}
#accessor configSet msgstore_protocol_restapi bwsdrvdataopts "sproxyd_srv=
#{%- for node in salt['pillar.get']('nodes', '') -%}
#{{node}}:81
#{%- if not loop.last -%}
#,
#{%- endif -%}
#{%- endfor -%}
#;sproxyd_uri_arc=/proxy/arc;sproxyd_uri_chord=/proxy/chord"
#{%- endif %}
