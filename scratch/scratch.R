
foo <- bcdc_search("forest", res_format = "wms")

bcdc_facets("type")
bcdc_facets("license_id")

bcdc_list()

bcdc_show("freshwater-atlas-named-point-features")

bar <- bcdc_map("bc-airports")

bar <- bcdc_map("freshwater-atlas-named-point-features")
rd <- bcdc_map("tantalis-regional-districts")

hyd <- bcdc_map("hydrology-hydrometric-watershed-boundaries")

obs_wells <- bcdc_map("ground-water-wells",
                      query = "OBSERVATION_WELL_NUMBER IS NOT NULL")
obs_wells <- bcdc_map("ground-water-wells",
                      query = "OBSERVATION_WELL_NUMBER=108")
