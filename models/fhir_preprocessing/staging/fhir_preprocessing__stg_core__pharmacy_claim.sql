{% if var('claims_enabled', False) == true and var('clinical_enabled', False) == true -%}

select
      pharmacy_claim_id
    , person_id
    , claim_id
    , claim_line_number
    , payer
    , {{ the_tuva_project.quote_column('plan') }}
    , dispensing_provider_id
    , dispensing_provider_name
    , dispensing_date
    , paid_date
    , days_supply
    , refills
    , paid_amount
    , in_network_flag
    , ndc_code
    , data_source
from {{ ref('core__pharmacy_claim') }}

{% elif var('claims_enabled', False) == true -%}

select
      pharmacy_claim_id
    , person_id
    , claim_id
    , claim_line_number
    , payer
    , {{ the_tuva_project.quote_column('plan') }}
    , dispensing_provider_id
    , dispensing_provider_name
    , dispensing_date
    , paid_date
    , days_supply
    , refills
    , paid_amount
    , in_network_flag
    , ndc_code
    , data_source
from {{ ref('core__pharmacy_claim') }}

{% elif var('clinical_enabled', False) == true -%}

select {% if target.type == 'fabric' %} top 0 {% else %}{% endif %}
      cast(null as {{ dbt.type_string() }} ) as pharmacy_claim_id
    , cast(null as {{ dbt.type_string() }} ) as person_id
    , cast(null as {{ dbt.type_string() }} ) as claim_id
    , cast(null as {{ dbt.type_string() }} ) as claim_line_number
    , cast(null as {{ dbt.type_string() }} ) as payer
    , cast(null as {{ dbt.type_string() }} ) as {{ the_tuva_project.quote_column('plan') }}
    , cast(null as {{ dbt.type_string() }} ) as dispensing_provider_id
    , cast(null as {{ dbt.type_string() }} ) as dispensing_provider_name
    , {{ the_tuva_project.try_to_cast_date('null', 'YYYY-MM-DD') }} as dispensing_date
    , {{ the_tuva_project.try_to_cast_date('null', 'YYYY-MM-DD') }} as paid_date
    , cast(null as {{ dbt.type_string() }} ) as days_supply
    , cast(null as {{ dbt.type_string() }} ) as refills
    , cast(null as {{ dbt.type_string() }} ) as paid_amount
    , cast(null as {{ dbt.type_string() }} ) as in_network_flag
    , cast(null as {{ dbt.type_string() }} ) as ndc_code
    , cast(null as {{ dbt.type_string() }} ) as data_source
{{ the_tuva_project.limit_zero()}}

{%- endif %}
