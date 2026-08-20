select
      person_id
    , encounter_id
    , encounter_group
    , encounter_start_date
    , encounter_end_date
    , data_source
from {{ ref('core__encounter') }}
