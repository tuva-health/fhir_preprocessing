{{ config(enabled=var('claims_enabled', false) | as_bool) }}

select resource_internal_id
from {{ ref('fhir_preprocessing__explanation_of_benefit') }}
group by resource_internal_id
having count(*) > 1
