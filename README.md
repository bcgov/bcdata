
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

<!-- badges: start -->

<a id="devex-badge" rel="Delivery" href="https://github.com/BCDevExchange/assets/blob/master/README.md"><img alt="In production, but maybe in Alpha or Beta. Intended to persist and be supported." style="border-width:0" src="https://assets.bcdevexchange.org/images/badges/delivery.svg" title="In production, but maybe in Alpha or Beta. Intended to persist and be supported." /></a>
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Travis build
status](https://travis-ci.org/bcgov/bcdata.svg?branch=master)](https://travis-ci.org/bcgov/bcdata)
[![R build
status](https://github.com/bcgov/bcdata/workflows/R-CMD-check/badge.svg)](https://github.com/bcgov/bcdata)
[![Codecov test
coverage](https://codecov.io/gh/bcgov/bcdata/branch/master/graph/badge.svg)](https://codecov.io/gh/bcgov/bcdata?branch=master)

[![CRAN\_Status\_Badge](https://www.r-pkg.org/badges/version/bcdata)](https://cran.r-project.org/package=bcdata)
[![CRAN
Downloads](https://cranlogs.r-pkg.org/badges/bcdata?color=brightgreen)](https://CRAN.R-project.org/package=bcdata)
[![cran
checks](https://cranchecks.info/badges/worst/bcdata)](https://CRAN.R-project.org/web/checks/check_results_bcdata.html)
<!-- badges: end -->

An R package 📦 for searching & retrieving data from the [B.C. Data
Catalogue](https://catalogue.data.gov.bc.ca).

  - `bcdc_browse()` - Open the catalogue in your default browser
  - `bcdc_search()` - Search records in the catalogue
  - `bcdc_search_facets()` - List catalogue facet search options
  - `bcdc_get_record()` - Print a catalogue record
  - `bcdc_tidy_resources()` - Get a data frame of resources for a record
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

You can install `bcdata` directly from
[CRAN](https://cran.r-project.org/package=bcdata):

``` r
install.packages("bcdata")
```

To install the development version from GitHub, use the
[remotes](https://cran.r-project.org/package=remotes) package:

``` r
install.packages("remotes")

remotes::install_github("bcgov/bcdata")
library(bcdata)
```

### Vignettes

  - [Get Started with
    bcdata](https://bcgov.github.io/bcdata/articles/bcdata.html)
  - [Querying Spatial Data with
    bcdata](https://bcgov.github.io/bcdata/articles/efficiently-query-spatial-data-in-the-bc-data-catalogue.html)
  - [Exploring Silviculture Data with
    bcdata](https://bcgov.github.io/bcdata/articles/explore-silviculture-data-using-bcdata.html)
  - Using bcdata with [bcmaps](https://github.com/bcgov/bcmaps) (Coming
    Soon\!)

### BCDC Authentication

If you are an authorized editor of the B.C. Data Catalogue you may want
to access records that are not publicly available (e.g., in DRAFT,
waiting to be published). This can be done by authenticating with the
catalogue with an API key.

***Important Note:*** *Your API key is like a password and you must take
care to keep it private. Do not share it, and be careful to not include
it in any scripts or accidentally commit it to GitHub.*

You can log in to the catalogue to obtain your API key, then store it as
an environment variable in your [`.Renviron`
file](https://rstats.wtf/r-startup.html#renviron). The environment
variable must be called `BCDC_KEY`, set like this:

    BCDC_KEY=your-api-key

This way, the relevant bcdata functions will read that key and use it to
authorize your calls to the catalogue, allowing you to access additional
records that you are authorized to see if you were logged into the
catalogue web interface. Functions that benefit from this are:

  - `bcdc_search()`
  - `bcdc_list()`
  - `bcdc_get_record()`
  - `bcdc_get_data()`

### Getting Help or Reporting an Issue

To report bugs/issues/feature requests, please file an
[issue](https://github.com/bcgov/bcdata/issues/).

### How to Contribute

If you would like to contribute to the package, please see our
[CONTRIBUTING](https://github.com/bcgov/bcdata/blob/master/CONTRIBUTING.md)
guidelines.

Please note that this project is released with a [Contributor Code of
Conduct](https://github.com/bcgov/bcdata/blob/master/CODE_OF_CONDUCT.md).
By participating in this project you agree to abide by its terms.

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
