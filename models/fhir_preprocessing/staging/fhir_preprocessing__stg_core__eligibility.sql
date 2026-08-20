{% if var('clinical_enabled', False) == true and var('claims_enabled', False) == true -%}

select
      eligibility_id
    , person_id
    , member_id
    , payer_type
    , payer
    , {{ the_tuva_project.quote_column('plan') }}
    , enrollment_start_date
    , enrollment_end_date
    , subscriber_relation
    , subscriber_id
    , data_source
from {{ ref('core__eligibility') }}

{% elif var('claims_enabled', False) == true -%}

select
      eligibility_id
    , person_id
    , member_id
    , payer_type
    , payer
    , {{ the_tuva_project.quote_column('plan') }}
    , enrollment_start_date
    , enrollment_end_date
    , subscriber_relation
    , subscriber_id
    , data_source
from {{ ref('core__eligibility') }}

{% elif var('clinical_enabled', False) == true -%}

select {% if target.type == 'fabric' %} top 0 {% else %}{% endif %}
      cast(null as {{ dbt.type_string() }} ) as eligibility_id
    , cast(null as {{ dbt.type_string() }} ) as person_id
    , cast(null as {{ dbt.type_string() }} ) as member_id
    , cast(null as {{ dbt.type_string() }} ) as payer_type
    , cast(null as {{ dbt.type_string() }} ) as payer
    , cast(null as {{ dbt.type_string() }} ) as {{ the_tuva_project.quote_column('plan') }}
    , {{ the_tuva_project.try_to_cast_date('null', 'YYYY-MM-DD') }} as enrollment_start_date
    , {{ the_tuva_project.try_to_cast_date('null', 'YYYY-MM-DD') }} as enrollment_end_date
    , cast(null as {{ dbt.type_string() }} ) as subscriber_relation
    , cast(null as {{ dbt.type_string() }} ) as subscriber_id
    , cast(null as {{ dbt.type_string() }} ) as data_source
{{ the_tuva_project.limit_zero()}}

{%- endif %}
