
<!--
Copyright 2018 Province of British Columbia

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and limitations under the License.
-->

# bcdata <a href='https://bcgov.github.io/bcdata'><img src='man/figures/logo.png' align="right" height="139" /></a>

### Version 0.1.0

<!-- badges: start -->

<a id="devex-badge" rel="Exploration" href="https://github.com/BCDevExchange/assets/blob/master/README.md"><img alt="Being designed and built, but in the lab. May change, disappear, or be buggy." style="border-width:0" src="https://assets.bcdevexchange.org/images/badges/exploration.svg" title="Being designed and built, but in the lab. May change, disappear, or be buggy." /></a>
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Travis build
status](https://travis-ci.org/bcgov/bcdata.svg?branch=master)](https://travis-ci.org/bcgov/bcdata)
[![CRAN
status](https://www.r-pkg.org/badges/version/bcdata)](https://cran.r-project.org/package=bcdata)
<!-- badges: end -->

An R package 📦 for searching & retrieving data from the [B.C. Data
Catalogue](https://catalogue.data.gov.bc.ca).

  - `bcdc_browse()` - Open the catalogue in your default browser
  - `bcdc_search()` - Search records in the catalogue
  - `bcdc_search_facets()` - List catalogue facet search options
  - `bcdc_get_record()` - Print a catalogue record
  - `bcdc_get_data()` - Get catalogue data
  - `bcdc_query_geodata()` - Get & query catalogue geospatial data
    available through a [Web
    Service](https://www2.gov.bc.ca/gov/content?id=95D78D544B244F34B89223EF069DF74E)

**Note:** The `bcdata` package supports downloading *most* file types,
including zip archives. It will do its best to identify and read data
from zip files, however if there are multiple data files in the zip, or
data files that `bcdata` doesn’t know how to import, it will fail. If
you encounter a file type in the B.C. Data Catalogue not currently
supported by `bcdata` please file an
[issue](https://github.com/bcgov/bcdata/issues/).

### Reference

[bcdata package 📦 home page and reference
guide](https://bcgov.github.io/bcdata/)

### Installation

You can install `bcdata` directly from this GitHub repository using the
[remotes](https://cran.r-project.org/package=remotes) package:

``` r
install.packages("remotes")

remotes::install_github("bcgov/bcdata")
library(bcdata)
```

### Vignettes

  - [Get started with
    bcdata](https://bcgov.github.io/bcdata/articles/bcdata.html)
  - [Querying spatial data with
    bcdata](https://bcgov.github.io/bcdata/articles/efficiently-query-spatial-data-in-the-bc-data-catalogue.html)
  - Using bcdata with [bcmaps](https://github.com/bcgov/bcmaps) (coming
    soon\!)

### Getting Help or Reporting an Issue

To report bugs/issues/feature requests, please file an
[issue](https://github.com/bcgov/bcdata/issues/).

### How to Contribute

If you would like to contribute to the package, please see our
[CONTRIBUTING](CONTRIBUTING.md) guidelines.

Please note that this project is released with a [Contributor Code of
Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree
to abide by its terms.

### License

Copyright 2018 Province of British Columbia

Licensed under the Apache License, Version 2.0 (the “License”); you may
not use this file except in compliance with the License. You may obtain
a copy of the License at

<http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an “AS IS” BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

-----

*This project was created using the
[bcgovr](https://github.com/bcgov/bcgovr) package.*
