{%- from "windows-update-agent/map.jinja" import wua with context %}

{%- for key,settings in wua.items() %}
{%- if settings.get('value', '') %}
wua_reg_{{ key }}:
  reg.present:
    - name: {{ settings.name }}
    - value: {{ settings.value }}
    - vtype: {{ settings.vtype }}
    - reflection: False
{%- else %}
wua_reg_{{ key }}:
  reg.absent:
    - name: {{ settings.name }}
{%- endif %}
{%- endfor %}

wua_reset:
  cmd.run:
    - name: 'wuauclt.exe /resetauthorization /detectnow'
    - order: 'last'
