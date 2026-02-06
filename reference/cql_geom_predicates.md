# CQL Geometry Predicates

Functions to construct a CQL expression to be used to filter results
from
[`bcdc_query_geodata()`](https://bcgov.github.io/bcdata/reference/bcdc_query_geodata.md).
See [the geoserver CQL documentation for
details](https://docs.geoserver.org/stable/en/user/filter/ecql_reference.html#spatial-predicate).
The sf object is automatically converted in a bounding box to reduce the
complexity of the Web Feature Service call. Subsequent in-memory
filtering may be needed to achieve exact results.

## Usage

``` r
EQUALS(geom)

DISJOINT(geom)

INTERSECTS(geom)

TOUCHES(geom)

CROSSES(geom)

WITHIN(geom)

CONTAINS(geom)

OVERLAPS(geom)

BBOX(coords, crs = NULL)

DWITHIN(
  geom,
  distance,
  units = c("meters", "feet", "statute miles", "nautical miles", "kilometers")
)
```

## Arguments

- geom:

  an `sf`/`sfc`/`sfg` or `bbox` object (from the `sf` package)

- coords:

  the coordinates of the bounding box as four-element numeric vector
  `c(xmin, ymin, xmax, ymax)`, a `bbox` object from the `sf` package
  (the result of running
  [`sf::st_bbox()`](https://r-spatial.github.io/sf/reference/st_bbox.html)
  on an `sf` object), or an `sf` object which then gets converted to a
  bounding box on the fly.

- crs:

  (Optional) A numeric value or string containing an SRS code. If
  `coords` is a `bbox` object with non-empty crs, it is taken from that.
  (For example, `'EPSG:3005'` or just `3005`. The default is to use the
  CRS of the queried layer)

- distance:

  numeric value for distance tolerance

- units:

  units that distance is specified in. One of `"feet"`, `"meters"`,
  `"statute miles"`, `"nautical miles"`, `"kilometers"`

## Value

a CQL expression to be passed on to the WFS call
