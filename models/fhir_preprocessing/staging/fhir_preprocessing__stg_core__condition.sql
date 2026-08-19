{{ config(
     enabled = var('fhir_preprocessing_enabled',False) | as_bool
   )
}}
select
      condition_id
    , person_id
    , claim_id
    , encounter_id
    , recorded_date
    , onset_date
    , resolved_date
    , status
    /* Core 1.0 consolidates source and normalized code systems into code_system.
       Preserve the legacy normalized type only for successfully normalized codes. */
    , case
        when normalized_code is not null then code_system
      end as normalized_code_type
    , normalized_code
    , normalized_description
    , condition_rank
    , data_source
from {{ ref('core__condition') }}
