# FHIR Preprocessing

dbt package for the Tuva Project FHIR preprocessing data mart.

## Open-ended eligibility spans

Tuva Core represents an enrollment span with no known end date using a null
`enrollment_end_date`. FHIR Preprocessing preserves that null as an open
Coverage period and links later medical and pharmacy claims to the active
Coverage record.

Tuva Core's stable eligibility identity excludes the mutable enrollment end
date. When upgrading from an implementation whose eligibility identity included
the end date, fully refresh the FHIR tables: Coverage resource identifiers and
Explanation of Benefit coverage references change once, then remain stable when
an open enrollment span is later closed.
