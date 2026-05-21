{% macro fhir_patient_internal_id(relation_alias=None) -%}
    {%- set person_id_column = 'person_id' -%}
    {%- set data_source_column = 'data_source' -%}

    {%- if relation_alias is not none -%}
        {%- set person_id_column = relation_alias ~ '.person_id' -%}
        {%- set data_source_column = relation_alias ~ '.data_source' -%}
    {%- endif -%}

    {{ dbt_utils.generate_surrogate_key([person_id_column, data_source_column]) }}
{%- endmacro %}
