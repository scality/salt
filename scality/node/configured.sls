
include:
  - .added

{% from "scality/map.jinja" import scality with context %}
{% from "scality/node/helpers.sls" import for_all_nodes with context %}

# cap md pool size so that it uses no more than ~4% to avoid freezing machines with not much RAM
# an md pool entry is 70 bytes, 600 is ~ 0.04 * (1024*1024) / 70
# 30000000 is OK above 52 GB of RAM
{% set maxmdpoolsize = 600 * grains['mem_total'] %}
{% set chunkapimdpoolsize = 30000000 if 30000000 < maxmdpoolsize else maxmdpoolsize %}

{% call(node) for_all_nodes() %}

# set a few configuration values where the default is lacking
config-{{ node.name }}:
  scality_node.configured:
    - name: {{ node.name }}
    - ring: {{ node.ring }}
    - values:
        msgstore_protocol_chord:
          chordchecklocalnbchunks: 300
          chordctrlmaxparalleltasks: 5
          chordhttpsockettimeout: 30
          chordctrlrebuildrestbasepath: /rebuild/arcdata
        msgstore_storage_asyncpersistentmemory:
          pmmaxbiziostoreioidle: 8
          pmminbiziostoreblockdelayS: 30
          pmminbiziostoreblockdelaytimeoutS: 60
          pmminlibbizioreconnectdelaytimeoutS: 10
        msgstore_storage_chunkapi:
          chunkapimaxdelete: 32
          chunkapimaxphysdelete: 10
          chunkapimaxread: 96
          chunkapimaxwrite: 64
          chunkapimdpoolsize: {{ chunkapimdpoolsize }}
          chunkapinoatime: 1
        ov_cluster_node:
          usessl: 0
        ov_core_logs:
          logsdir: {{ scality.log.base_dir }}/scality-node-{{ node.index }}
          logsoccurrences: 48
          logsmaxsize: 2000
        ov_protocol_dns:
          mainresolver: 62.149.128.4,62.149.132.4
        ov_protocol_netscript:
          connect timeout: 5
          socket timeout: 30
    - require:
      - scality_node: add-{{ node.name }}

{% endcall %}
