{{ config(
     enabled = var('fhir_preprocessing_enabled',False) | as_bool
   )
}}
select
      procedure_id
    , person_id
    , claim_id
    , encounter_id
    , case
        when normalized_code is not null then code_system
      end as normalized_code_type
    , normalized_code
    , normalized_description
    , code_system as source_code_type
    , source_code
    , source_description
    , procedure_date
    , practitioner_id
    , data_source
from {{ ref('core__procedure') }}
