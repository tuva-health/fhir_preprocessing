# FHIR Preprocessing

`fhir_preprocessing` transforms standardized Tuva Core data into relational
tables shaped for downstream FHIR resource generation. It provides a stable
preprocessing boundary for applications that need FHIR-aligned fields without
requiring every consumer to repeat the claims and clinical mapping logic.

## What this package produces

The public outputs align to these FHIR resources:

- `condition`
- `coverage`
- `explanation_of_benefit`
- `medication_dispense`
- `observation`
- `patient`
- `procedure`

The tables preserve `data_source` and use deterministic internal identifiers
so references remain unique when source systems reuse patient, claim, or
medication identifiers. They are relational preprocessing tables rather than
serialized FHIR JSON resources.

## Prerequisites and dependency ownership

This package requires dbt `>=1.10.5,<3.0.0` and a Tuva connector or other root
dbt project that installs a compatible Tuva Core revision and produces the
Core clinical and claims relations used by the selected features. The root
project owns the Tuva Core version so that one dependency graph controls the
shared Core installation. For that reason, this package intentionally does
not declare Tuva Core in its own `packages.yml`.

`dbt_utils` is a direct runtime dependency used for surrogate keys, relation
unions, and data tests. It is declared by this package and will be resolved by
`dbt deps`.

## Installation

Once this package is available on the dbt Package Hub, add it to the root
project's `packages.yml` alongside the connector-managed Core dependency:

```yaml
packages:
  - package: tuva-health/fhir_preprocessing
    version: 0.1.0
```

Before Hub registration is complete, or when testing an exact source release,
use the immutable Git tag instead:

```yaml
packages:
  - git: "https://github.com/tuva-health/fhir_preprocessing.git"
    revision: v0.1.0
```

Then install dependencies:

```shell
dbt deps
```

## Configuration and usage

FHIR Preprocessing follows the root Tuva project's native boolean feature
variables. Enable the data domains that the connector supplies:

```yaml
vars:
  claims_enabled: true
  clinical_enabled: false
```

With claims enabled, the package builds Coverage and Explanation of Benefit
records in addition to the applicable patient and clinical-resource mappings.
With clinical data enabled, it maps the available clinical conditions,
medications, observations, labs, patients, and procedures. Set
`tuva_schema_prefix` in the root project to prefix the default
`fhir_preprocessing` schema.

Build the package with:

```shell
dbt build --select package:fhir_preprocessing
```

### Upgrade behavior

- A null Core `enrollment_end_date` is preserved as an open Coverage period.
- Explanation of Benefit `resource_internal_id` values are deterministic
  32-character hashes of claim domain, `data_source`, and source claim ID.
- Medication Dispense identifiers include the complete Core medication grain:
  `medication_id`, `source_type`, and `data_source`.

Fully refresh these models when upgrading from an implementation that used an
eligibility end date in its identity or copied raw claim or medication IDs
directly into FHIR resource identifiers.

## Data assets

FHIR Preprocessing is intentionally seedless and does not load an external
data-asset snapshot.

## Supported warehouses

The package is designed for Snowflake, BigQuery, Databricks, Microsoft Fabric,
Redshift, and DuckDB when used with the matching Tuva Core adapter. Its models
and unit fixtures have been checked for compilation and parsing across that
warehouse set; complete execution still depends on the connector and Core
relations supplied by the root project.

## Documentation and contributing

- [Tuva Project documentation](https://thetuvaproject.com/)
- [Issues and feature requests](https://github.com/tuva-health/fhir_preprocessing/issues)
- [Tuva community Slack](https://join.slack.com/t/thetuvaproject/shared_invite/zt-16iz61187-G522Mc2WGA2mHF57e0il0Q)

Contributions are welcome through GitHub issues and pull requests. This
project is licensed under the [Apache License 2.0](LICENSE).
