{%- from "windows-update-agent/map.jinja" import wua with context %}

# Loop through the data model, creating `reg.present` states for any key with
# a defined value, and `reg.absent` states for any key that is missing or that
# has an empty value.

{%- for subkey,keys in wua.items() %}
    {%- for key,settings in keys.items() %}
{%- if settings.get('value', '') %}
wua_reg_{{ subkey }}_{{ key }}:
  reg.present:
    - name: {{ settings.name }}
    - value: {{ settings.value }}
    - vtype: {{ settings.vtype }}
    - reflection: False
{%- else %}
wua_reg_{{ subkey }}_{{ key }}:
  reg.absent:
    - name: {{ settings.name }}
{%- endif %}
    {%- endfor %}
{%- endfor %}

wua_reset:
  cmd.run:
    - name: 'wuauclt.exe /resetauthorization /detectnow'
    - order: 'last'
