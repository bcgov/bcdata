# DataBC Services used by `bcdata`

This document is an attempt at a comprehensive list of services and API endpoints accessed by the bcdata R package, as well which return values we rely on from those endpoints.

## BC Data Catalogue

### API version: 
  - PROD: https://catalogue.data.gov.bc.ca/api/3
  - BETA: https://cat.data.gov.bc.ca/api/3

### Endpoints:
  - `/action/package_show`
  - `/action/package_search`
    - license_id
    - download_audience
    - res_format
    - sector
    - organization
  - `/action/package_list`
  - `/action/group_show`

### Response values used:
  - package:
    - title
    - name
    - id
    - license_title
    - type
    - notes
    - layer_name
    - resources (see below)
    
  - resource:
    - id
    - package_id
    - object_name
    - details
      - column_comments
      - column_name
    - format
    - resource_storage_location
    - name
    - url
    
  - group: 
    - description
    - packages
