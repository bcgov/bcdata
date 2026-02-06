# CQL escaping

Write a CQL expression to escape its inputs, and return a CQL/SQL
object. Used when writing filter expressions in
[`bcdc_query_geodata()`](https://bcgov.github.io/bcdata/reference/bcdc_query_geodata.md).

## Usage

``` r
CQL(...)
```

## Arguments

- ...:

  Character vectors that will be combined into a single CQL statement.

## Value

An object of class `c("CQL", "SQL")`

## Details

See [the CQL/ECQL for Geoserver
website](https://docs.geoserver.org/stable/en/user/tutorials/cql/cql_tutorial.html).

## Examples

``` r
CQL("FOO > 12 & NAME LIKE 'A&'")
#> <SQL> FOO > 12 & NAME LIKE 'A&'
```
