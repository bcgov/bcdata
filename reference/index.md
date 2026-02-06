# Package index

## Interacting with the B.C. Data Catalogue

Functions to search, browse, list, and explore records and their
resources (data sets) in the B.C. Data Catalogue

- [`bcdc_browse()`](https://bcgov.github.io/bcdata/reference/bcdc_browse.md)
  : Load the B.C. Data Catalogue URL into an HTML browser

- [`bcdc_search()`](https://bcgov.github.io/bcdata/reference/bcdc_search.md)
  : Search the B.C. Data Catalogue

- [`bcdc_search_facets()`](https://bcgov.github.io/bcdata/reference/bcdc_search_facets.md)
  :

  Get the valid values for a facet (that you can use in
  [`bcdc_search()`](https://bcgov.github.io/bcdata/reference/bcdc_search.md))

- [`bcdc_list()`](https://bcgov.github.io/bcdata/reference/bcdc_list.md)
  : Return a full list of the names of B.C. Data Catalogue records

- [`bcdc_get_record()`](https://bcgov.github.io/bcdata/reference/bcdc_get_record.md)
  : Show a single B.C. Data Catalogue record

- [`bcdc_tidy_resources()`](https://bcgov.github.io/bcdata/reference/bcdc_tidy_resources.md)
  : Provide a data frame containing the metadata for all resources from
  a single B.C. Data Catalogue record

- [`bcdc_list_groups()`](https://bcgov.github.io/bcdata/reference/bcdc_list_group_records.md)
  [`bcdc_list_group_records()`](https://bcgov.github.io/bcdata/reference/bcdc_list_group_records.md)
  : Retrieve group information for B.C. Data Catalogue

- [`bcdc_list_organizations()`](https://bcgov.github.io/bcdata/reference/bcdc_list_organization_records.md)
  [`bcdc_list_organization_records()`](https://bcgov.github.io/bcdata/reference/bcdc_list_organization_records.md)
  : Retrieve organization information for B.C. Data Catalogue

- [`bcdc_get_citation()`](https://bcgov.github.io/bcdata/reference/bcdc_get_citation.md)
  : Generate a bibentry from a Data Catalogue Record

## Direct downloads of data sets

Directly download (or preview) data sets (resources) from the B.C. Data
Catalogue

- [`bcdc_get_data()`](https://bcgov.github.io/bcdata/reference/bcdc_get_data.md)
  : Download and read a resource from a B.C. Data Catalogue record
- [`bcdc_preview()`](https://bcgov.github.io/bcdata/reference/bcdc_preview.md)
  : Get preview map from the B.C. Web Map Service
- [`bcdc_read_functions()`](https://bcgov.github.io/bcdata/reference/bcdc_read_functions.md)
  : Formats supported and loading functions

## Querying data from a Web Feature Service catalogue record

Issue queries using `select` and `filter` verbs against data sets in the
B.C. Data Catalogue that have a Web Feature Service.

- [`bcdc_query_geodata()`](https://bcgov.github.io/bcdata/reference/bcdc_query_geodata.md)
  : Query data from the B.C. Web Feature Service

- [`bcdc_describe_feature()`](https://bcgov.github.io/bcdata/reference/bcdc_describe_feature.md)
  : Describe the attributes of a Web Feature Service

- [`filter(`*`<bcdc_promise>`*`)`](https://bcgov.github.io/bcdata/reference/filter.md)
  : Filter a query from bcdc_query_geodata()

- [`select(`*`<bcdc_promise>`*`)`](https://bcgov.github.io/bcdata/reference/select.md)
  : Select columns from bcdc_query_geodata() call

- [`mutate(`*`<bcdc_promise>`*`)`](https://bcgov.github.io/bcdata/reference/mutate.md)
  :

  Throw an informative error when attempting mutate on a `bcdc_promise`
  object

- [`collect(`*`<bcdc_promise>`*`)`](https://bcgov.github.io/bcdata/reference/collect-methods.md)
  [`as_tibble(`*`<bcdc_promise>`*`)`](https://bcgov.github.io/bcdata/reference/collect-methods.md)
  : as_tibble

- [`EQUALS()`](https://bcgov.github.io/bcdata/reference/cql_geom_predicates.md)
  [`DISJOINT()`](https://bcgov.github.io/bcdata/reference/cql_geom_predicates.md)
  [`INTERSECTS()`](https://bcgov.github.io/bcdata/reference/cql_geom_predicates.md)
  [`TOUCHES()`](https://bcgov.github.io/bcdata/reference/cql_geom_predicates.md)
  [`CROSSES()`](https://bcgov.github.io/bcdata/reference/cql_geom_predicates.md)
  [`WITHIN()`](https://bcgov.github.io/bcdata/reference/cql_geom_predicates.md)
  [`CONTAINS()`](https://bcgov.github.io/bcdata/reference/cql_geom_predicates.md)
  [`OVERLAPS()`](https://bcgov.github.io/bcdata/reference/cql_geom_predicates.md)
  [`BBOX()`](https://bcgov.github.io/bcdata/reference/cql_geom_predicates.md)
  [`DWITHIN()`](https://bcgov.github.io/bcdata/reference/cql_geom_predicates.md)
  : CQL Geometry Predicates

- [`bcdc_check_geom_size()`](https://bcgov.github.io/bcdata/reference/bcdc_check_geom_size.md)
  : Check spatial objects for WFS spatial operations

- [`CQL()`](https://bcgov.github.io/bcdata/reference/CQL.md) : CQL
  escaping

- [`bcdc_options()`](https://bcgov.github.io/bcdata/reference/bcdc_options.md)
  : Retrieve options used in bcdata, their value if set and the default
  value.
