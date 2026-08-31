with days_supply as (

    select
          claim_id
        , data_source
        , 'dayssupply' as eob_supporting_info_category_code
        , cast(days_supply as {{ dbt.type_string() }} ) as eob_supporting_info_value_quantity /* cast as string for union */
        , cast(null as {{ dbt.type_string() }} ) as eob_supporting_info_code /* required for union */
        , cast(null as {{ dbt.type_string() }} ) as eob_supporting_info_system /* required for union */
    from {{ ref('fhir_preprocessing__stg_core__pharmacy_claim') }}
    where claim_line_number = 1 /* filter to claim header */
    and days_supply is not null

)

, refill as (

    select
          claim_id
        , data_source
        , 'refillnum' as eob_supporting_info_category_code
        , cast(refills as {{ dbt.type_string() }} ) as eob_supporting_info_value_quantity /* cast as string for union */
        , cast(null as {{ dbt.type_string() }} ) as eob_supporting_info_code /* required for union */
        , cast(null as {{ dbt.type_string() }} ) as eob_supporting_info_system /* required for union */
    from {{ ref('fhir_preprocessing__stg_core__pharmacy_claim') }}
    where claim_line_number = 1 /* filter to claim header */
    and refills is not null

)

/*
    Tuva model missing DAW code.
    Mapping a default value since HEDIS reuires it.
*/
, daw as (

    select
          claim_id
        , data_source
        , 'dawcode' as eob_supporting_info_category_code
        , cast(null as {{ dbt.type_string() }} ) as eob_supporting_info_value_quantity /* cast as string for union */
        , '0' as eob_supporting_info_code
        , 'DAW' as eob_supporting_info_system
    from {{ ref('fhir_preprocessing__stg_core__pharmacy_claim') }}
    where claim_line_number = 1 /* filter to claim header */

)

, unioned as (

    select * from days_supply
    union all
    select * from refill
    union all
    select * from daw

)

, add_sequence as (
    select
          claim_id
        , data_source
        , eob_supporting_info_category_code
        , cast(eob_supporting_info_value_quantity as {{ dbt.type_numeric() }} ) as eob_supporting_info_value_quantity
        , eob_supporting_info_code
        , eob_supporting_info_system
        , row_number() over(
            partition by claim_id, data_source
            order by eob_supporting_info_category_code
          ) as eob_supporting_info_sequence
    from unioned
)

/* create a json string for CSV export */
{{ the_tuva_project.create_json_object(
    table_ref='add_sequence',
    group_by_col='claim_id, data_source',
    object_col_name='eob_supporting_info_list',
    object_col_list=[
        'eob_supporting_info_sequence'
        , 'eob_supporting_info_category_code'
        , 'eob_supporting_info_value_quantity'
        , 'eob_supporting_info_code'
        , 'eob_supporting_info_system'
    ]
) }}
