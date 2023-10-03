# bcdata.single_download_limit is deprecated but works

    Code
      bcdc_query_geodata(record = "76b1b7a3-2112-4444-857a-afccf7b20da8")
    Condition
      Warning:
      The bcdata.single_download_limit option is deprecated. Please use bcdata.chunk_limit instead.
    Output
      Querying 'bc-airports' record
      * Using collect() on this object will return 455 features and 41 fields
      * Accessing this record requires pagination and will make 455 separate
      * requests to the WFS. See ?bcdc_options
      * At most six rows of the record are printed here
      --------------------------------------------------------------------------------
      Simple feature collection with 6 features and 41 fields
      Geometry type: POINT
      Dimension:     XY
      Bounding box:  xmin: 833323.9 ymin: 381604.1 xmax: 1198292 ymax: 1054950
      Projected CRS: NAD83 / BC Albers
      # A tibble: 6 x 42
        id        CUSTODIAN_ORG_DESCRI~1 BUSINESS_CATEGORY_CL~2 BUSINESS_CATEGORY_DE~3
        <chr>     <chr>                  <chr>                  <chr>                 
      1 WHSE_IMA~ "Ministry of Forest, ~ airTransportation      Air Transportation    
      2 WHSE_IMA~ "Ministry of Forest, ~ airTransportation      Air Transportation    
      3 WHSE_IMA~ "Ministry of Forest, ~ airTransportation      Air Transportation    
      4 WHSE_IMA~ "Ministry of Forest, ~ airTransportation      Air Transportation    
      5 WHSE_IMA~ "Ministry of Forest, ~ airTransportation      Air Transportation    
      6 WHSE_IMA~ "Ministry of Forest, ~ airTransportation      Air Transportation    
      # i abbreviated names: 1: CUSTODIAN_ORG_DESCRIPTION,
      #   2: BUSINESS_CATEGORY_CLASS, 3: BUSINESS_CATEGORY_DESCRIPTION
      # i 38 more variables: OCCUPANT_TYPE_DESCRIPTION <chr>, SOURCE_DATA_ID <chr>,
      #   SUPPLIED_SOURCE_ID_IND <chr>, AIRPORT_NAME <chr>, DESCRIPTION <chr>,
      #   PHYSICAL_ADDRESS <chr>, ALIAS_ADDRESS <chr>, STREET_ADDRESS <chr>,
      #   POSTAL_CODE <chr>, LOCALITY <chr>, CONTACT_PHONE <chr>,
      #   CONTACT_EMAIL <chr>, CONTACT_FAX <chr>, WEBSITE_URL <chr>, ...

