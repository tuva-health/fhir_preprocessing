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

## Explanation of Benefit identifiers

Explanation of Benefit `resource_internal_id` values are deterministic
32-character hashes of the claim domain, `data_source`, and the source medical
or pharmacy claim identifier. This keeps medical and pharmacy resources unique
when source systems reuse identifiers. The original claim identifier remains in
`unique_claim_id`.

Upgrading from an implementation that copied the medical or pharmacy claim
identifier directly into `resource_internal_id` requires a full refresh of the
FHIR tables. Existing Explanation of Benefit resource identifiers change once
to adopt the source- and domain-scoped contract.

## Medication Dispense identifiers

Tuva Core medication records use the composite source grain
`(medication_id, source_type, data_source)` because clinical and claims records
can reuse the same medication identifier within one source. FHIR Medication
Dispense preserves `source_type` and generates `resource_internal_id` as a
collision-safe, domain-separated 32-character hash of that complete grain.

Fully refresh the FHIR tables when upgrading. Existing Medication Dispense
resource identifiers change once from the raw medication identifier to the
source-aware hash.
