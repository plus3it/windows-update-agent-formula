{%- from "windows-update-agent/map.jinja" import wua with context %}

# Loop through the data model, creating `reg.present` states for any key with
# defined vdata. If `remove-undefined-keys` is `True`, also create `reg.absent`
# states for any key that is missing or that has empty vdata.
{%- set remove_undefined_keys = salt['pillar.get'](
    'windows-update-agent:remove-undefined-keys',
    False) %}

{%- for subkey,keys in wua.items() %}
    {%- for vname,settings in keys.items() %}
{%- if settings.get('vdata', '') %}
wua_reg_{{ subkey }}_{{ vname }}:
  reg.present:
    - name: {{ settings.name }}
    - vname: {{ vname }}
    - vdata: {{ settings.vdata }}
    - vtype: {{ settings.vtype }}
    - watch_in:
      - service: wua_service
{%- elif remove_undefined_keys %}
wua_reg_{{ subkey }}_{{ vname }}:
  reg.absent:
    - name: {{ settings.name }}
    - vname: {{ vname }}
    - watch_in:
      - service: wua_service
{%- endif %}
    {%- endfor %}
{%- endfor %}

wua_service:
  service.running:
    - name: wuauserv
    - onchanches_in:
      - cmd: wua_reset

wua_reset:
  cmd.run:
    - name: 'wuauclt.exe /resetauthorization /detectnow'
