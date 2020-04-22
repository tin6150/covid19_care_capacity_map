
Algorithm B
===========

Result: state+capacity+case.geojson - not working

Formerly Alg 2, but changed to B for numbering the steps.

now adding case data (with historical data)



SOURCE FILES
============

::

	stateData.geojson		# gson with coordinate of 50 states, for choropleth., from https://docs.mapbox.com/help/tutorials/choropleth-studio-gl-pt-1
	kff_capacity_dw_2020_0409.csv	# care capacity (hospital beds) from KPP.org downloaded on 2020.04.09
        cases_daily_dw_2020_0419.json   # https://covidtracking.com/api/v1/states/daily.json
        stateAbbr.csv

Algorithm
=========


* .geojson can be stored on fs, instead of a tileset in mapbox server
* single .geojson file, color like NYC collision eg

* First letter of step, eg A or B, refers to whether the command is from Alg A or B (this one)
* Step numbers are in ref to https://github.com/tin6150/inet-dev-class/blob/master/mapbox/eg_data_ndjson/README.txt.rst - mostly when to use split, join, map, etc
* Third letter, as group (a), (b), (c), is more on which set of files is being worked on, in what order they are being joined.

* Have to worry about ndjoin creating multiple array elements.  so have to do remap/restruc after each join.
* working with ndjson is more annoying than with csv, cuz of the hierarchy of json, imposing a need to pivot/remap data after join.  quite painful actually.

* group (a) set: join bed capacity + state name abbreviation
* group (b) set: join (a) with case count
* group (c) set: join (b) with state shape gson


One time prep
-------------

cat kff_capacity_dw_2020_0409.prepd.csv | awk -F, '/,/{print $1 "," }' > stateAbbr.csv
cat tmp2.csv | awk -F, '{print "\"" $1 "\",\"" $2 "\""}' 
vi stateAbbr.csv # add abbreviation

csv2json -n stateAbbr.csv > stateAbbr.ndjson

Detail steps 
------------ 


**Prep Step**
- ensure csv has first row as field names
- rename field names so that it doesn't have space? eg use sed -e ... 


# rename field names (strip space is most important)
dos2unix < kff_capacity_dw_2020_0409.csv | sed -e "s/Total Hospital Beds/TotalHospitalBeds/" -e "s/Hospital Beds per 1,000 Population/HospitalBedsPer1kPop/"  -e "s/Total CHCs/TotalCHCs/" -e "s/CHC Service Delivery Sites/CHCServiceDeliverySites/" > kff_capacity_dw_2020_0409.prepd.csv # **0**
# there are comments at top and bottom of the csv from kff, may need to clean them first :
cat kff_capacity_dw_2020_0409.prepd.csv  | fgrep '",' | csv2json -n > kff_capacity_dw_2020_0409.ndjson # Alaska, Alabama  # 52 entries **Step 3 in tutorial** *?*

**Step B2a: join (a) - add abbreviation to capacity**
#xx ndjson-join 'd.Location' kff_capacity_dw_2020_0409.ndjson stateAbbr.ndjson > capa+abbr.ndjson
ndjson-join 'd.Location' stateAbbr.ndjson kff_capacity_dw_2020_0409.ndjson > capa+abbr.ndjson
meld capa+abbr.ndjson kff_capacity_dw_2020_0409.ndjson # GUI tool to see diff (alt: kdiff3 fldiff)

**Step B5a: re-map (a)**
ndjson-map 'd[0] = { Location: d[0].Location, TotalHospitalBeds: d[1].TotalHospitalBeds, HospitalBedsPer1kPop: d[1].HospitalBedsPer1kPop, TotalCHCs: d[1].TotalCHCs, CHCServiceDeliverySites: d[1].CHCServiceDeliverySites, Footnotes: d[1].Footnotes, state: d[0].Abbr }, d[0]'  < capa+abbr.ndjson >  capa+abbr.remapped.ndjson  # **B5: re-map**
meld  capa+abbr.ndjson  capa+abbr.remapped.ndjson



**Step Bxx: cases to ndjson**
wget https://covidtracking.com/api/v1/states/current.json -O cases_current_dw_2020_0419.json  # fewer entries, but diff struct.  daily(historical) dont have positiveScore, negativeScore, commercialScore, grade,
wget https://covidtracking.com/api/v1/states/daily.json   -O cases_daily_dw_2020_0419.json    # use this *TODO: check this in?*

        daily.json data for 1 entry:
        {"date":20200419,"state":"AK","positive":319,"negative":9576,"pending":null,"hospitalizedCurrently":37,"hospitalizedCumulative":36,"inIcuCurrently":null,"inIcuCumulative":null,"onVentilatorCurrently":null,"onVentilatorCumulative":null,"recovered":153,"hash":"a55d5f5198d699a8859e16fc9fa49cbecbc61939","dateChecked":"2020-04-19T20:00:00Z","death":9,"hospitalized":36,"total":9895,"totalTestResults":9895,"posNeg":9895,"fips":"02","deathIncrease":0,"hospitalizedIncrease":0,"negativeIncrease":235,"positiveIncrease":5,"totalTestResultsIncrease":240},


ndjson-split 
cat cases_current_dw_2020_0419.json | json5 | ndjson-split  > cases_current_dw_2020_0419.ndjson
cat cases_daily_dw_2020_0419.json   | json5 | ndjson-split  > cases_daily_dw_2020_0419.ndjson    # **B#**

**Step B4b: join (b) cases + capa** 
dont know how to if key has diff fieldname
ndjson-join 'd.state' capa+abbr.remapped.ndjson cases_current_dw_2020_0419.ndjson > capacity+cases.ndjson # 1 day current data only, dont use this
ndjson-join 'd.state' capa+abbr.remapped.ndjson cases_daily_dw_2020_0419.ndjson   > capacity+cases.ndjson # daily = historical data, use this **B4**
meld cases_daily_dw_2020_0419.ndjson capacity+cases.ndjson (kdiff3 could not handle large diff)


**Step B5b: re-map/restructure (b)**
ndjson-map  'd[0] = { Location: d[0].Location, TotalHospitalBeds: d[0].TotalHospitalBeds, HospitalBedsPer1kPop: d[0].HospitalBedsPer1kPop, TotalCHCs: d[0].TotalCHCs, CHCServiceDeliverySites: d[0].CHCServiceDeliverySites, Footnotes: d[0].Footnotes, state: d[0].Abbr,   date: d[1].date, positive: d[1].positive, positiveIncrease: d[1].positiveIncrease, hospitalizedIncrease: d[1].hospitalizedIncrease,  hospitalizedCurrently: d[1].hospitalizedCurrently, hospitalizedCumulative: d[1].hospitalizedCumulative, inIcuCurrently: d[1].inIcuCurrently, inIcuCumulative: d[1].inIcuCumulative, onVentilatorCurrently: d[1].onVentilatorCurrently, onVentilatorCumulative: d[1].onVentilatorCumulative,   hash: d[1].hash, dateChecked: d[1].dateChecked, fips: d[1].fips  }, d[0]'  < capacity+cases.ndjson > capacity+cases.remapped.ndjson  # **B5b: re-map**

        sample input (newline by me):
        [{"Location":"Wyoming","TotalHospitalBeds":"2015","HospitalBedsPer1kPop":"3.49","TotalCHCs":"6","CHCServiceDeliverySites":"14","Footnotes":"","state":"WY"},
        {"date":20200308,"state":"WY",
        "positive":0,
        "hash":"04b812c8dbb7bd7a7c1c24bb7e3b1116fb1cfa96",
        "dateChecked":"2020-03-08T20:00:00Z",
        "total":0,"totalTestResults":0,"posNeg":0,
        "fips":"56",
        "deathIncrease":0,
        "hospitalizedIncrease":0,
        "negativeIncrease":0,
        "positiveIncrease":0,
        "totalTestResultsIncrease":0}]

        Maybe interesting, but not every entry has this info
        hospitalizedCurrently":37,"hospitalizedCumulative":36,
        "inIcuCurrently":null,"inIcuCumulative":null,
        "onVentilatorCurrently":null,"onVentilatorCumulative

~~~~

**Step A1: geo2ndj [AlgA]**
# convert geojson to ndjson, note that ndjson-split can't handle newline in its input, thus the filter via json5i :
cat stateData.geojson | json5 | ndjson-split 'd.features' > stateData.ndjson # 52 "states": Alabama, Hawaii, Puerto Rico  # **no mapping yet**

**Step A2: add key [AlgA]** 
# add a Location column to ndjson, so that it can be used as key for join , via ndjson-map cmd :
cat stateData.ndjson | ndjson-map 'd.Location = d.properties.name, d' > stateData-loc.ndjson #  **duplicate column(field) cuz need fieldname to match for join**
# **add key via mapping, create key field for join**

~~~~

**Step B4c join (c) [updated for Alg2]**
# perforn ndjson-join of : state shape data & (bed capacity + cases ) :
# inner join seems appropriate.  ndjson-join could not take key "two level down" the json object, thus the earlier step of creating field with matching name as key
# below get 2287 entries, both input and output file.
ndjson-join  'd.Location'  stateData-loc.ndjson  capacity+cases.remapped.ndjson    > state+capacity+cases.ndjson    # **B4**join**   

# result of 1 entry below, split into multiple lines by me.  Note it has two elements, as d[0] and d[1] # ??


**Step B5c: re-map/restructure (c)**
# reshape the ndjson structure (result above are split into 2 element array)
  need to at least "move" the important data into the first array element 
  during this process, turn from 2-element array into single object, which mean strip outermost [ ] of each entry (ndjson line).
  use ndjson-map (cannot access fieldname with space):
# largely reuse B5a above, but need to pivot data into d[0].properties instead of just d[0], so that it would keep geometry (and id, type, etc) 
  input is (newline by me):
  [{"type":"Feature","id":"01","properties":{"name":"Alabama","density":94.65},
  "geometry":{"type":"Polygon","coordinates":[[[-87.359296,35.00118],[-85.606675,34.984749],[-85.431413,34.124869],[-85.184951,32.859696],[-85.069935,32.580372],[-84.960397,32.421541],[-85.004212,32.322956],[-84.889196,32.262709],[-85.058981,32.13674],[-85.053504,32.01077],[-85.141136,31.840985],[-85.042551,31.539753],[-85.113751,31.27686],[-85.004212,31.003013],[-85.497137,30.997536],[-87.600282,30.997536],[-87.633143,30.86609],[-87.408589,30.674397],[-87.446927,30.510088],[-87.37025,30.427934],[-87.518128,30.280057],[-87.655051,30.247195],[-87.90699,30.411504],[-87.934375,30.657966],[-88.011052,30.685351],[-88.10416,30.499135],[-88.137022,30.318396],[-88.394438,30.367688],[-88.471115,31.895754],[-88.241084,33.796253],[-88.098683,34.891641],[-88.202745,34.995703],[-87.359296,35.00118]]]},
  "Location":"Alabama"   // <<<--- d[0]
  },                     // d[1] --->>>
  {"Location":"Alabama","TotalHospitalBeds":"15278","HospitalBedsPer1kPop":"3.13","TotalCHCs":"15","CHCServiceDeliverySites":"144","Footnotes":"","date":20200419,"positive":4837,"positiveIncrease":182,"hospitalizedIncrease":21,"hospitalizedCurrently":null,"hospitalizedCumulative":641,"inIcuCurrently":null,"inIcuCumulative":260,"onVentilatorCurrently":null,"onVentilatorCumulative":157,"hash":"e120fdc84c91ed23d5f4a2a00e930fbf90f652b3","dateChecked":"2020-04-19T20:00:00Z","fips":"01"}]


ndjson-map  'd[0].properties = { Location: d[0].Location, TotalHospitalBeds: d[1].TotalHospitalBeds, HospitalBedsPer1kPop: d[1].HospitalBedsPer1kPop, TotalCHCs: d[1].TotalCHCs, CHCServiceDeliverySites: d[1].CHCServiceDeliverySites, Footnotes: d[1].Footnotes, state: d[1].Abbr,   date: d[1].date, positive: d[1].positive, positiveIncrease: d[1].positiveIncrease, hospitalizedIncrease: d[1].hospitalizedIncrease,  hospitalizedCurrently: d[1].hospitalizedCurrently, hospitalizedCumulative: d[1].hospitalizedCumulative, inIcuCurrently: d[1].inIcuCurrently, inIcuCumulative: d[1].inIcuCumulative, onVentilatorCurrently: d[1].onVentilatorCurrently, onVentilatorCumulative: d[1].onVentilatorCumulative,   hash: d[1].hash, dateChecked: d[1].dateChecked, fips: d[1].fips  }, d[0]'  < state+capacity+cases.ndjson > state+capacity+cases.remapped.ndjson  # **B5c: re-map**


**Step 6: ndj2geo**
# convert ndjson to regular geojson, need to add some "opener" structure into the json - 
# really same command as before, just need to change filenames
cat capacity+state.ndjson    | ndjson-reduce | ndjson-map '{type: "FeatureCollection", features: d}'  > capacity+state-m1.geojson # Step 6a: i dont like this method, use 6b below
                                                           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*^ readd the opener needed to create geojson

ndjson-reduce 'p.features.push(d), p' '{type: "FeatureCollection", features: []}'  < state+capacity+cases.remapped.ndjson  > state+capacity+cases.geojson  # **6b** **ndj2geo** 
                                   |   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^||^-------<<<--- re-add the opener needed to create geojson
                                   more clear of where ndjson data get shoved into


state+capacity+cases.geojson  good now once B5c fixed.


*think all ndjson files are tmp and can be rm*



Ref
===

* https://covidtracking.com/data  and  https://covidtracking.com/api
 


.. # use 8-space tab as that's how github render the rst
.. # vim: shiftwidth=8 tabstop=8 noexpandtab paste 
