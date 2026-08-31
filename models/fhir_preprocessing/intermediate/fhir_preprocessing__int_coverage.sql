with base as (

    select
          {{ fhir_preprocessing.fhir_patient_internal_id() }} as patient_internal_id
        /* create hash due to FHIR limit of 64 characters for max length of strings */
        , {{ dbt_utils.generate_surrogate_key(['eligibility_id']) }} as resource_internal_id
        , payer as organization_name
        , {{ the_tuva_project.quote_column('plan') }} as coverage_plan
        , payer_type
        , enrollment_start_date as coverage_period_start
        , enrollment_end_date as coverage_period_end
        , coalesce(subscriber_relation,'self') as coverage_relationship
        , 'active' as coverage_status
        , coalesce(subscriber_id,member_id) as coverage_subscriber_id
        , data_source
    from {{ ref('fhir_preprocessing__stg_core__eligibility') }}

)

, normalize_plan as (

    select
          *
        , concat(
              ' '
            , replace(
                  replace(
                    replace(
                      replace(
                        replace(
                          replace(
                            replace(
                              replace(lower(coalesce(coverage_plan, '')), '-', ' ')
                            , '_', ' ')
                          , '/', ' ')
                        , '.', ' ')
                      , ',', ' ')
                    , '(', ' ')
                  , ')', ' ')
                , '&', ' ')
            , ' '
          ) as coverage_plan_tokens
    from base

)

/* Map to standardized codes for product type */
, add_product as (

    select
          patient_internal_id
        , resource_internal_id
        , organization_name
        , coverage_plan
        , payer_type
        , coverage_period_start
        , coverage_period_end
        , coverage_relationship
        , coverage_status
        , coverage_subscriber_id
        , data_source
        , case
            when lower(payer_type) like '%commercial%' then 'PPO'
            when lower(payer_type) like '%self%' then 'PPO'
            when lower(payer_type) like '%medicare%' then 'MCR'
            when lower(payer_type) like '%medicaid%' then 'MCD'
            when coverage_plan_tokens like '% pos %' then 'POS'
            when coverage_plan_tokens like '% cep %' then 'CEP'
            when coverage_plan_tokens like '% hmo %' then 'HMO'
            /* Match specific codes before their shorter prefixes. */
            when coverage_plan_tokens like '% mcs %' then 'MCS'
            when coverage_plan_tokens like '% mmp %' then 'MMP'
            when coverage_plan_tokens like '% mde %' then 'MDE'
            when coverage_plan_tokens like '% sn1 %' then 'SN1'
            when coverage_plan_tokens like '% sn2 %' then 'SN2'
            when coverage_plan_tokens like '% sn3 %' then 'SN3'
            when coverage_plan_tokens like '% mli %' then 'MLI'
            when coverage_plan_tokens like '% mrb %' then 'MRB'
            when coverage_plan_tokens like '% mmo %' then 'MMO'
            when coverage_plan_tokens like '% mos %' then 'MOS'
            when coverage_plan_tokens like '% mpo %' then 'MPO'
            when coverage_plan_tokens like '% mep %' then 'MEP'
            when coverage_plan_tokens like '% mp %' then 'MP'
            when coverage_plan_tokens like '% mc %' then 'MC'
            when coverage_plan_tokens like '% md %' then 'MD'
          end as coverage_type_product
    from normalize_plan

)

select
      patient_internal_id
    , resource_internal_id
    , organization_name
    , coverage_plan
    , coverage_period_start
    , coverage_period_end
    , coverage_relationship
    , coverage_status
    , coverage_subscriber_id
    , data_source
    , coverage_type_product
from add_product
