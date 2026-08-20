select 'condition' as staging_model
from {{ ref('fhir_preprocessing__stg_core__condition') }}
where normalized_code_type is not null
  and normalized_code is null

union all

select 'procedure' as staging_model
from {{ ref('fhir_preprocessing__stg_core__procedure') }}
where normalized_code_type is not null
  and normalized_code is null
