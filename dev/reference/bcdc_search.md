# Search the B.C. Data Catalogue

Search the B.C. Data Catalogue

## Usage

``` r
bcdc_search(
  ...,
  license_id = NULL,
  download_audience = NULL,
  res_format = NULL,
  sector = NULL,
  organization = NULL,
  groups = NULL,
  n = 100
)
```

## Arguments

- ...:

  search terms

- license_id:

  the type of license (see `bcdc_search_facets("license_id")`).

- download_audience:

  download audience (see `bcdc_search_facets("download_audience")`).
  Default `NULL` (all audiences).

- res_format:

  format of resource (see `bcdc_search_facets("res_format")`)

- sector:

  sector of government from which the data comes (see
  `bcdc_search_facets("sector")`)

- organization:

  government organization that manages the data (see
  `bcdc_search_facets("organization")`)

- groups:

  collections of datasets for a particular project or on a particular
  theme (see `bcdc_search_facets("groups")`)

- n:

  number of results to return. Default `100`

## Value

A list containing the records that match the search

## Examples

``` r
# \donttest{
try(
  bcdc_search("forest")
)
#> Found 576 matches. Returning the first 100.
#> To see them all, rerun the search and set the 'n' argument to 576.
#> List of B.C. Data Catalogue Records
#> Number of records: 100
#> Showing the top 50 results. You can assign the
#>  output of bcdc_search, to an object and subset with
#>  `[` to see other results in the set.
#> 
#> Titles:
#> 1: Forest Development Units (multiple, wms, kml,
#>  oracle_sde)
#>  ID: 25bbc9a6-f0eb-47dd-849c-3161a6512468
#>  Name: forest-development-units
#> 2: FADM - Provincial Forest (multiple, wms, kml)
#>  ID: 4a023cb2-09fd-44c2-b3ce-439ecb5f39f3
#>  Name: fadm-provincial-forest
#> 3: Non Replaceable Forest Licenses Kamloops Forest
#>  District (oracle_sde)
#>  ID: af8d871d-6612-4c94-a2ce-d05672ec9efa
#>  Name:
#>   non-replaceable-forest-licenses-kamloops-forest-district
#> 4: Forest Ecosystem Networks for the Chilcotin Forest
#>  District (oracle_sde)
#>  ID: e55ea13e-7503-4109-ae46-9c1a113eaed8
#>  Name:
#>   forest-ecosystem-networks-for-the-chilcotin-forest-district
#> 5: Forest Tenure Managed Licence (multiple, wms, kml)
#>  ID: c3e96239-cdc9-4328-ac19-58fba1623ef8
#>  Name: forest-tenure-managed-licence
#> 6: FDU - Forest Licence Reference (multiple)
#>  ID: 7e986391-c740-4d1b-9294-7576af2d2998
#>  Name: fdu-forest-licence-reference
#> 7: Forest Tenure Road Lines (oracle_sde)
#>  ID: bed9be0f-3590-415b-b130-d5bfa2938604
#>  Name: forest-tenure-road-lines
#> 8: FADM - Provincial Forest Deletion (multiple, wms,
#>  kml)
#>  ID: fc480dec-1e67-4944-9343-6c72ae124440
#>  Name: fadm-provincial-forest-deletion
#> 9: FADM - Provincial Forest Addition (multiple, wms,
#>  kml)
#>  ID: 07dba191-3ebc-4c32-af7e-16769c237011
#>  Name: fadm-provincial-forest-addition
#> 10: Forest Tenure Communication Sites (multiple, wms,
#>  kml)
#>  ID: 1361d483-26ae-4ca9-adba-e19c3efac147
#>  Name: forest-tenure-communication-sites
#> 11: FADM - Provincial Forest Exclusion (multiple,
#>  wms, kml)
#>  ID: f3239e0c-f347-49f9-a53d-39290e597159
#>  Name: fadm-provincial-forest-exclusion
#> 12: Forest Tenure Timber Licence (multiple, wms, kml)
#>  ID: f2356651-4456-4d93-ba17-7b8c4a3ee53d
#>  Name: forest-tenure-timber-licence
#> 13: Forest Road Segment Tenure (multiple, wms, kml)
#>  ID: 07b0830e-a505-4c88-8d9a-8cf0a630f565
#>  Name: forest-road-segment-tenure
#> 14: Forest Inventory Zones (multiple, wms, kml)
#>  ID: 67e95c68-c1ef-4363-b351-0dfead151122
#>  Name: forest-inventory-zones
#> 15: Forest MapView (other)
#>  ID: 67acfc63-1dea-43be-bee0-4bc8fa8901fc
#>  Name: forest-mapview
#> 16: Forest Tenure Chart Block Polygons (oracle_sde)
#>  ID: 9d341916-d596-481c-b191-a0df41767c2f
#>  Name: forest-tenure-chart-block-polygons
#> 17: Forest Tenure Cut Block Polygons (oracle_sde)
#>  ID: 214e60a2-4f1a-4a68-8494-b8a935b6551b
#>  Name: forest-tenure-cut-block-polygons
#> 18: Forest Tenure Road Section Lines (multiple, wms,
#>  kml)
#>  ID: 243c94a1-f275-41dc-bc37-91d8a2b26e10
#>  Name: forest-tenure-road-section-lines
#> 19: Forest Tenure Managed Licenses Polygons
#>  (oracle_sde)
#>  ID: 04fb4da4-8c6e-4166-a4e8-4c8723443980
#>  Name: forest-tenure-managed-licenses-polygons
#> 20: Forest Stewardship Plans - Identified Areas
#>  (multiple, wms, kml, oracle_sde)
#>  ID: dad55255-0f8f-4a4a-a40f-38d22750d065
#>  Name: forest-stewardship-plans-identified-areas
#> 21: Forest Tenure Timber Use Polygons (oracle_sde)
#>  ID: 4b2afa31-a0b9-488f-8f15-1d6117e0093e
#>  Name: forest-tenure-timber-use-polygons
#> 22: Forest Tenure Real Property Project (multiple,
#>  wms, kml)
#>  ID: 3d7f09c3-ff25-429e-a4d9-d88f9919d904
#>  Name: forest-tenure-real-property-project
#> 23: Forest Tenure Map Notation Point (multiple, wms)
#>  ID: 69f4f070-d70a-43c8-b224-354758f4f492
#>  Name: forest-tenure-map-notation-point
#> 24: Forest Tenure Cut Permit Polygons (oracle_sde)
#>  ID: 4876fb83-ce33-4cf8-9c13-7fdeb2f39cf6
#>  Name: forest-tenure-cut-permit-polygons
#> 25: Forest Tenure Road Section Amendment (multiple)
#>  ID: bad79704-3fc9-43e7-b5d4-660657199af8
#>  Name: forest-tenure-road-section-amendment
#> 26: Forest Tenure Map Notation Polygon (multiple,
#>  wms, kml)
#>  ID: 78838b54-f241-4269-aeb4-126d14bb5f37
#>  Name: forest-tenure-map-notation-polygon
#> 27: Forest Tenure Map Notation Line (multiple, wms,
#>  kml)
#>  ID: 8ef18f74-e53f-497a-968d-86e9a20419a2
#>  Name: forest-tenure-map-notation-line
#> 28: Forest Tenure Harvesting Authority Polygons
#>  (multiple, wms, kml)
#>  ID: cff7b8f7-6897-444f-8c53-4bb93c7e9f8b
#>  Name: forest-tenure-harvesting-authority-polygons
#> 29: Forest Tenure Communication Site Polygon
#>  (oracle_sde)
#>  ID: d8f0798b-e2e3-48e5-b587-d193daced09e
#>  Name: forest-tenure-communication-site-polygon
#> 30: Forest Tenure Timber Licence Remaining (multiple)
#>  ID: edf864e8-bae6-4735-a85b-3e6f276d4a14
#>  Name: forest-tenure-timber-licence-remaining
#> 31: Forest Tenure Free Use Permit (multiple, wms,
#>  kml)
#>  ID: 814e0ed9-95c3-4750-8152-1307795986f1
#>  Name: forest-tenure-free-use-permit
#> 32: Forest Tenure Road Segment Lines (multiple, wms,
#>  kml, other)
#>  ID: 9e5bfa62-2339-445e-bf67-81657180c682
#>  Name: forest-tenure-road-segment-lines
#> 33: Forest Tenure Timber Licence Elimination
#>  (multiple, wms, kml)
#>  ID: e15e0543-830f-43b8-b824-ed9a8ed7eeca
#>  Name: forest-tenure-timber-licence-elimination
#> 34: Forest Tenure Road Section Polygon (oracle_sde)
#>  ID: 6c560de6-f322-491f-965a-f75efae6e6d3
#>  Name: forest-tenure-road-section-polygon
#> 35: Forest Tenure Timber License Elimination
#>  (oracle_sde)
#>  ID: d3e5f900-bd2c-4537-8c72-96ee71b4d7ce
#>  Name: forest-tenure-timber-license-elimination
#> 36: RESULTS - Forest Cover Silviculture (multiple,
#>  wms, kml)
#>  ID: 258bb088-4113-47b1-b568-ce20bd64e3e3
#>  Name: results-forest-cover-silviculture
#> 37: RESULTS - Forest Cover Inventory (multiple, wms)
#>  ID: 56ac43a7-724a-4f01-b193-d5f9a16ef0a8
#>  Name: results-forest-cover-inventory
#> 38: RESULTS - Forest Cover Reserve (multiple, wms,
#>  kml)
#>  ID: 7028ac47-45dd-41d7-a371-be5a04177afe
#>  Name: results-forest-cover-reserve
#> 39: Generalized Forest Cover Ownership (wms, kml,
#>  multiple, pdf)
#>  ID: 5fc4e8ce-dd1d-44fd-af17-e0789cf65e4e
#>  Name: generalized-forest-cover-ownership
#> 40: Forest Harvesting Restrictions (generalized)
#>  (fgdb, xlsx)
#>  ID: 6c0bcb22-49cb-4315-bc9c-c4668495cc45
#>  Name: forest-harvesting-restrictions-generalized-
#> 41: Forest Licensee Operating Areas (multiple, wms,
#>  kml)
#>  ID: 5a18c401-7c99-48fe-8a1a-b4597072d8b6
#>  Name: forest-licensee-operating-areas
#> 42: Forest Tenure FTA Timber Sale Polygons
#>  (oracle_sde)
#>  ID: beb5565d-7cd1-4a51-99c4-2984a0652ef8
#>  Name: forest-tenure-fta-timber-sale-polygons
#> 43: Forest Tenure Special Access Road Polygon
#>  (multiple, wms, kml)
#>  ID: 6d171eb8-d7a8-4ad5-8a9e-027e43f7a54b
#>  Name: forest-tenure-special-access-road-polygon
#> 44: Forest Tenure Special Access Road Line (multiple,
#>  wms, kml)
#>  ID: 4ee37a5d-6a14-4f98-8ad9-566b4ea28e2b
#>  Name: forest-tenure-special-access-road-line
#> 45: Forest Tenure Special Use Permit Polygon
#>  (multiple, wms, kml)
#>  ID: d29b37fc-cbfe-4ebf-ac6e-2bf8fa926a81
#>  Name: forest-tenure-special-use-permit-polygon
#> 46: VRI - 2025 - Forest Vegetation Composite Polygons
#>  (fgdb)
#>  ID: 6ba30649-14cd-44ad-a11f-794feed39f40
#>  Name: vri-2025-forest-vegetation-composite-polygons
#> 47: Fertilization Forest Carbon Initiative Projects
#>  (arcgis_rest, other)
#>  ID: 6dec4d9c-f960-4c49-a6df-d4568531db7d
#>  Name:
#>   fertilization-forest-carbon-initiative-projects
#> 48: Forest Tenure Road Use Permits (multiple, wms,
#>  kml, oracle_sde)
#>  ID: 5c7bc316-1524-4e3f-b799-f8dbafa7a53a
#>  Name: forest-tenure-road-use-permits
#> 49: Forest Operations Map (FOM) - Cutblocks
#>  (multiple, wms, kml, arcgis_rest)
#>  ID: 7dda4615-5d32-427e-a303-1dcdb90a6fea
#>  Name: forest-operations-map-fom-cutblocks
#> 50: Forest Carbon Initiative Projects Portal (other)
#>  ID: e861e5eb-5a7f-4f1f-8764-a9b54000767f
#>  Name: forest-carbon-initiative-projects-portal
#> 
#> Access a single record by calling
#>  `bcdc_get_record(ID)` with the ID from the desired
#>  record.

try(
  bcdc_search("regional district", res_format = "fgdb")
)
#> List of B.C. Data Catalogue Records
#> Number of records: 6
#> Titles:
#> 1: Recreation Sites and Trail BC Region Boundaries
#>  (fgdb, multiple, wms, kml)
#>  ID: 919f236a-e40f-4f07-a459-f976f02b6e11
#>  Name:
#>   recreation-sites-and-trail-bc-region-boundaries
#> 2: Recreation Sites and Trails BC District Boundaries
#>  (fgdb, multiple, wms, kml)
#>  ID: 0ad49841-a25b-4be4-b98c-9e817e94cc48
#>  Name:
#>   recreation-sites-and-trails-bc-district-boundaries
#> 3: Cariboo Consolidated Roads (fgdb)
#>  ID: ef431656-44d2-4a16-9e0e-a14d934bb281
#>  Name: cariboo-consolidated-roads
#> 4: Forest Biodiversity - BC Cumulative Effects
#>  Framework - 2019 Assessment (xlsx, fgdb, other)
#>  ID: 32ea7e06-f6e1-4822-b89e-38e145113926
#>  Name:
#>   forest-biodiversity-bc-cumulative-effects-framework-2019-assessment
#> 5: Wetland and Riparian Potential – Lower Fraser
#>  Valley (fgdb, other, pdf)
#>  ID: 9c06f5a3-816d-4238-877c-f1e1adc30022
#>  Name:
#>   wetland-and-riparian-potential-lower-fraser-valley
#> 6: Old Growth - BC Cumulative Effects Framework -
#>  2019 Assessment - Robson Valley (fgdb, multiple)
#>  ID: 502442fe-0d45-43f3-a8e5-f733e5c74d7d
#>  Name:
#>   old-growth-bc-cumulative-effects-framework-2019-assessment-robson-valley
#> 
#> Access a single record by calling
#>  `bcdc_get_record(ID)` with the ID from the desired
#>  record.

try(
  bcdc_search("angling", groups = "bc-tourism")
)
#> List of B.C. Data Catalogue Records
#> Number of records: 1
#> Titles:
#> 1: Angling Licence Sales Statistics 2010 to 2024
#>  (xlsx, csv)
#>  ID: ebbe3328-43ac-4440-be2d-b3f83ae03780
#>  Name: angling-licence-sales-statistics-2010-to-2024
#> 
#> Access a single record by calling
#>  `bcdc_get_record(ID)` with the ID from the desired
#>  record.
# }
```
