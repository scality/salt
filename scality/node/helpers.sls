
# macros to iterate on all nodes or all nodes from a given ring
# see configured.sls for an example

{% macro for_all_nodes() -%}
{% set xnodes = salt['scality.nodes']() if salt.has_key('scality.nodes') else () %}
{% for xnode in xnodes %}
{{ caller(node=xnode) }}
{% endfor %}
{%- endmacro %}

{% macro for_nodes_in(ring) -%}
{% set xnodes = salt['scality.nodes'](ring=ring) if salt.has_key('scality.nodes') else () %}
{% for xnode in xnodes %}
{{ caller(node=xnode) }}
{% endfor %}
{%- endmacro %}

