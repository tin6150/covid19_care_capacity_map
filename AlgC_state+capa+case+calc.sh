#!/bin/bash

# essentially README.AlgB_state+capa+case.txt.rst in a .sh
# add calculated columns
# BedUtil = Num Hospitilized / Total Hospital Bed ( * 100 ) # could be null.  maybe could be > 100%.  so far data are null, 0, or 6.9%
# Actually, kpp care capacity csv don't have ICU bed count or ventilator.
# only other relevant stat is HospitalBedsPer1kPop
# IcuUtil = Num ICU cases / ICU beds in hospital
# VentilatorUtil = Num patients using ventilator / Avail Ventilator (this maybe hard, number likely fluctuate)


# Input and Output filenames, change as data source change ++TODO++
StateGson=stateData.geojson
StateAbbrFile=stateAbbr.csv
CapacityFile=kff_capacity_dw_2020_0409.csv
#CaseFile=cases_daily_dw_2020_0419.json
CaseFile=cases_daily_automaton.json
OutGson=state+capacity+cases.geojson  


################################################################################


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

ndjson-map  'd[0] = { Location: d[0].Location, TotalHospitalBeds: d[0].TotalHospitalBeds, HospitalBedsPer1kPop: d[0].HospitalBedsPer1kPop, TotalCHCs: d[0].TotalCHCs, CHCServiceDeliverySites: d[0].CHCServiceDeliverySites, Footnotes: d[0].Footnotes, state: d[0].Abbr,   date: d[1].date, positive: d[1].positive, positiveIncrease: d[1].positiveIncrease, hospitalizedIncrease: d[1].hospitalizedIncrease,  hospitalizedCurrently: d[1].hospitalizedCurrently, hospitalizedCumulative: d[1].hospitalizedCumulative, inIcuCurrently: d[1].inIcuCurrently, inIcuCumulative: d[1].inIcuCumulative, onVentilatorCurrently: d[1].onVentilatorCurrently, onVentilatorCumulative: d[1].onVentilatorCumulative,   hash: d[1].hash, dateChecked: d[1].dateChecked, fips: d[1].fips  }, d[0]'  < capacity+cases.ndjson > capacity+cases.remapped.ndjson  # **B5b: re-map** **+BedUtil**

# Step B4c

ndjson-join  'd.Location'  stateData-loc.ndjson  capacity+cases.remapped.ndjson    > state+capacity+cases.ndjson    # **B4c**join**


#  B5c
## need  to add the calculated columns here as well (toward the end), right before fips... ,d[0]
## BedUtil: d[1].hospitalizedCurrently / d[1].TotalHospitalBeds * 100 

ndjson-map  'd[0].properties = { Location: d[0].Location, TotalHospitalBeds: d[1].TotalHospitalBeds, HospitalBedsPer1kPop: d[1].HospitalBedsPer1kPop, TotalCHCs: d[1].TotalCHCs, CHCServiceDeliverySites: d[1].CHCServiceDeliverySites, Footnotes: d[1].Footnotes, state: d[1].Abbr,   date: d[1].date, positive: d[1].positive, positiveIncrease: d[1].positiveIncrease, hospitalizedIncrease: d[1].hospitalizedIncrease,  hospitalizedCurrently: d[1].hospitalizedCurrently, hospitalizedCumulative: d[1].hospitalizedCumulative, inIcuCurrently: d[1].inIcuCurrently, inIcuCumulative: d[1].inIcuCumulative, onVentilatorCurrently: d[1].onVentilatorCurrently, onVentilatorCumulative: d[1].onVentilatorCumulative,   hash: d[1].hash, dateChecked: d[1].dateChecked, fips: d[1].fips,   BedUtil: d[1].hospitalizedCurrently / d[1].TotalHospitalBeds * 100  }, d[0]'  < state+capacity+cases.ndjson > state+capacity+cases.remapped.ndjson  # **B5c: re-map + BedUtil column**

# wc bef    2287    3211 5020499 state+capacity+cases.remapped.ndjson
# wc aft    2287    3211 5059606 state+capacity+cases.remapped.ndjson


# Step 6b  **ndj2geo**
ndjson-reduce 'p.features.push(d), p' '{type: "FeatureCollection", features: []}'  < state+capacity+cases.remapped.ndjson  > ../${OutGson} 
# OutGson should be state+capacity+cases.geojson  # **6b** **ndj2geo**

echo "poor man data quality peek.  newest data at top"
cat capacity+cases.ndjson | grep California | head -1
cat capacity+cases.ndjson | grep California | tail -1
cat capacity+cases.ndjson | grep California | head -1 | sed 's/,/\n/g' | grep  date.: | awk -F: '{print $2}' | tee ../latestDataDate.txt

cd -

