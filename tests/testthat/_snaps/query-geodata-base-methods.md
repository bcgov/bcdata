# tail works

    Code
      withr::with_options(list(pillar.width = Inf), print(tail(select(
        bcdc_query_geodata(point_record), all_of(col)), n = 3)))
    Output
      Querying 'bc-airports' record
      * Using collect() on this object will return 3 features and 9 fields
      * At most six rows of the record are printed here
      --------------------------------------------------------------------------------
      Simple feature collection with 3 features and 9 fields
      Geometry type: POINT
      Dimension: XY
      Bounding box: xmin: 1113277 ymin: 483437.1 xmax: 1470009 ymax: 758363.4
      Projected CRS: NAD83 / BC Albers
      # A tibble: 3 x 10
       id 
       <chr> 
      1 WHSE_IMAGERY_AND_BASE_MAPS.GSR_AIRPORTS_SVW.fid-<id>
      2 WHSE_IMAGERY_AND_BASE_MAPS.GSR_AIRPORTS_SVW.fid-<id>
      3 WHSE_IMAGERY_AND_BASE_MAPS.GSR_AIRPORTS_SVW.fid-<id>
       CUSTODIAN_ORG_DESCRIPTION 
       <chr> 
      1 "Ministry of Forest, Lands and Natural Resource Operations and Rural Developm~
      2 "Ministry of Forest, Lands and Natural Resource Operations and Rural Developm~
      3 "Ministry of Forest, Lands and Natural Resource Operations and Rural Developm~
       BUSINESS_CATEGORY_CLASS BUSINESS_CATEGORY_DESCRIPTION
       <chr> <chr> 
      1 airTransportation Air Transportation 
      2 airTransportation Air Transportation 
      3 airTransportation Air Transportation 
       OCCUPANT_TYPE_DESCRIPTION SOURCE_DATA_ID SUPPLIED_SOURCE_ID_IND
       <chr> <chr> <chr> 
      1 BC Airports 642 N 
      2 BC Airports 526 N 
      3 BC Airports 813 N 
       AIRPORT_NAME SEQUENCE_ID
       <chr> <int>
      1 South Cariboo Regional Airport (108 Mile Ranch Airport) 1347
      2 Oliver Airport 1349
      3 Sister Islets 1351
       geometry
       <POINT [m]>
      1 (1321215 758363.4)
      2 (1470009 483437.1)
      3 (1113277 497961.1)

