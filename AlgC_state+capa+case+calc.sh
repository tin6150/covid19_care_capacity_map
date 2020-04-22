#!/bin/bash

# essentially README.AlgB_state+capa+case.txt.rst in a .sh
# add calculated columns
# BedUtil = Num Hospitilized / Total Hospital Bed ( * 100% ? )
# IcuUtil = Num ICU cases / ICU beds in hospital
# VentilatorUtil = Num patients using ventilator / Avail Ventilator (this maybe hard, number likely fluctuate)



StateGson=stateData.geojson
StateAbbrFile=stateAbbr.csv
CapacityFile=kff_capacity_dw_2020_0409.csv
CaseFile=cases_daily_dw_2020_0419.json


[[ -d DATA_PREP ]] || mkdir DATA_PREP
cd DATA_PREP

# Prep Step
# csv2json -n stateAbbr.csv > stateAbbr.ndjson
csv2json -n ../${StateAbbrFile} > stateAbbr.ndjson


# A1:
#   stateData.geojson
cat ../${StateGson}  | json5 | ndjson-split 'd.features' > stateData.ndjson # 52 "states" **no mapping yet**

# A2:
cat stateData.ndjson | ndjson-map 'd.Location = d.properties.name, d' > stateData-loc.ndjson #  **duplicate column(field) cuz need fieldname to match for join**


# kff_capacity_dw_2020_0409.csv 
dos2unix < ../${CapacityFile} | sed -e "s/Total Hospital Beds/TotalHospitalBeds/" -e "s/Hospital Beds per 1,000 Population/HospitalBedsPer1kPop/"  -e "s/Total CHCs/TotalCHCs/" -e "s/CHC Service Delivery Sites/CHCServiceDeliverySites/" > kff_capacity.prepd.csv # **0**

cat kff_capacity.prepd.csv  | fgrep '",' | csv2json -n > kff_capacity.ndjson # **Step 3 in tutorial** 

# B2a
ndjson-join 'd.Location' stateAbbr.ndjson kff_capacity.ndjson > capa+abbr.ndjson

ndjson-map 'd[0] = { Location: d[0].Location, TotalHospitalBeds: d[1].TotalHospitalBeds, HospitalBedsPer1kPop: d[1].HospitalBedsPer1kPop, TotalCHCs: d[1].TotalCHCs, CHCServiceDeliverySites: d[1].CHCServiceDeliverySites, Footnotes: d[1].Footnotes, state: d[0].Abbr }, d[0]'  < capa+abbr.ndjson >  capa+abbr.remapped.ndjson  # **B5: re-map**


#   cases_daily_dw_2020_0419.json
cat ../${CaseFile}     | json5 | ndjson-split  > cases_daily.tmp.ndjson    # **B#**

ndjson-join 'd.state' capa+abbr.remapped.ndjson cases_daily.tmp.ndjson   > capacity+cases.ndjson # daily = historical data, use this **B4**



## Step B5b.  lots of column remap/pivot.
## need  to add the calculated columns here as well (toward the end), right before fips... ,d[0]
## BedUtil: d[1].hospitalizedCurrently / d[0].TotalHospitalBeds * 100 

#xx ndjson-map  'd[0] = { Location: d[0].Location, TotalHospitalBeds: d[0].TotalHospitalBeds, HospitalBedsPer1kPop: d[0].HospitalBedsPer1kPop, TotalCHCs: d[0].TotalCHCs, CHCServiceDeliverySites: d[0].CHCServiceDeliverySites, Footnotes: d[0].Footnotes, state: d[0].Abbr,   date: d[1].date, positive: d[1].positive, positiveIncrease: d[1].positiveIncrease, hospitalizedIncrease: d[1].hospitalizedIncrease,  hospitalizedCurrently: d[1].hospitalizedCurrently, hospitalizedCumulative: d[1].hospitalizedCumulative, inIcuCurrently: d[1].inIcuCurrently, inIcuCumulative: d[1].inIcuCumulative, onVentilatorCurrently: d[1].onVentilatorCurrently, onVentilatorCumulative: d[1].onVentilatorCumulative,   hash: d[1].hash, dateChecked: d[1].dateChecked, fips: d[1].fips  }, d[0]'  < capacity+cases.ndjson > capacity+cases.remapped.ndjson  # **B5b: re-map**

ndjson-map  'd[0] = { Location: d[0].Location, TotalHospitalBeds: d[0].TotalHospitalBeds, HospitalBedsPer1kPop: d[0].HospitalBedsPer1kPop, TotalCHCs: d[0].TotalCHCs, CHCServiceDeliverySites: d[0].CHCServiceDeliverySites, Footnotes: d[0].Footnotes, state: d[0].Abbr,   date: d[1].date, positive: d[1].positive, positiveIncrease: d[1].positiveIncrease, hospitalizedIncrease: d[1].hospitalizedIncrease,  hospitalizedCurrently: d[1].hospitalizedCurrently, hospitalizedCumulative: d[1].hospitalizedCumulative, inIcuCurrently: d[1].inIcuCurrently, inIcuCumulative: d[1].inIcuCumulative, onVentilatorCurrently: d[1].onVentilatorCurrently, onVentilatorCumulative: d[1].onVentilatorCumulative,   hash: d[1].hash, dateChecked: d[1].dateChecked, fips: d[1].fips,  BedUtil: d[1].hospitalizedCurrently / d[0].TotalHospitalBeds * 100 }, d[0]'  < capacity+cases.ndjson > capacity+cases.remapped.ndjson  # **B5b: re-map**

# wc before change:    2287    2749 1005258 capacity+cases.remapped.ndjson
# wc inter :           2287    2749 1044365 capacity+cases.remapped.ndjson

# ref: {density: Math.floor(d[1].B01003 / d[0].properties.ALAND * 2589975.2356)}, d[0]




# once above is fixed, add 
# Step B4c
