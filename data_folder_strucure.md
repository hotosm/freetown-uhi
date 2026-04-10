.
└── CDCHR_UHI/
    └── {district_code}_{district_name}/
        └── {area_code}_{area_name}/
            └── {area_code}_{area_name}_{task_id}/
                ├── flight_plans/
                │   ├── geojson -> {area_code}_{area_name}_{task_id}.geojson
                │   ├── kml -> {area_code}_{area_name}_{task_id}.kml
                │   └── shp -> {area_code}_{area_name}_{task_id}.shp
                ├── captured/
                │   ├── visual/
                │   │   ├── {area_code}_{area_name}_{task_id}_pre_dawn/  ->. *.jpg
                │   │   ├── {area_code}_{area_name}_{task_id}_solar_noon/ -> *.jpg
                │   │   └── {area_code}_{area_name}_{task_id}_post_sunset/ -> *.jpg
                │   └── thermal/
                │       ├── {area_code}_{area_name}_{task_id}_pre_dawn_thermal_jpeg/ -> *.jpg
                │       ├── {area_code}_{area_name}_{task_id}_pre_dawn_radiometric_jpeg/ -> *.tif
                │       ├── {area_code}_{area_name}_{task_id}_solar_noon_thermal_jpeg/ -> *.jpg
                │       ├── {area_code}_{area_name}_{task_id}_solar_noon_radiometric_jpeg/ -> *.tif
                │       ├── {area_code}_{area_name}_{task_id}_post_sunset_thermal_jpeg/ -> *.jpg
                │       └── {area_code}_{area_name}_{task_id}_post_sunset_radiometric_jpeg/ -> *.tif
                ├── processed/
                │   ├── visual/
                │   │   └── {area_code}_{area_name}_{task_id}_solar_noon_orthomosaic.tif
                │   └── thermal/
                │       ├── {area_code}_{area_name}_{task_id}_pre_dawn_thermal.tif
                │       ├── {area_code}_{area_name}_{task_id}_solar_noon_thermal.tif
                │       ├── {area_code}_{area_name}_{task_id}_post_sunset_thermal.tif
                │       └── {area_code}_{area_name}_{task_id}_average_thermal.tif
                └── checklist/
                    ├── flight_operations/
                    │   ├── pre_dawn/
                    │   │   ├── {area_code}_{area_name}_{task_id}_pre_dawn_safety_compliance_{date}.xlsx 
                    │   │   └── {area_code}_{area_name}_{task_id}_pre_dawn_post_flight_{date}.xlsx
                    │   ├── solar_noon/
                    │   │   ├── {area_code}_{area_name}_{task_id}_solar_noon_safety_compliance_{date}.xlsx
                    │   │   └── {area_code}_{area_name}_{task_id}_solar_noon_post_flight_{date}.xlsx
                    │   └── post_sunset/
                    │       ├── {area_code}_{area_name}_{task_id}_post_sunset_safety_compliance_{date}.xlsx
                    │       └── {area_code}_{area_name}_{task_id}_post_sunset_post_flight_{date}.xlsx
                    └── data_management/
                        ├── {area_code}_{area_name}_{task_id}_pre_dawn_QC.xlsx
                        ├── {area_code}_{area_name}_{task_id}_solar_noon_QC.xlsx
                        └── {area_code}_{area_name}_{task_id}_post_sunset_QC.xlsx



_Develeped using https://tree.nathanfriend.com/_