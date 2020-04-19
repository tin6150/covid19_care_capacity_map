
Algorithm 1
===========

State geojson + care capacity data

This was the first attempt.
Got state+capacity.geojson that displays correctly, but no map for it yet.

Had to learn lot of ndjson-cli command to convert file structure and do join

Info mostly from README at git log 69ebe7f


SOURCE FILES
============

::

	stateData.geojson		# gson with coordinate of 50 states, for choropleth., from https://docs.mapbox.com/help/tutorials/choropleth-studio-gl-pt-1
	kff_capacity_dw_2020_0409.csv	# care capacity (hospital beds) from KPP.org downloaded on 2020.04.09


Algorithm
=========

* .geojson can be stored on fs, instead of a tileset in mapbox server
* single .geojson file, color like NYC collision eg
* HI likely a multi polygon, so create a state.ndjson
* ndjson join :  kpp(bed count) --> ndjson 
* ndjson join :  state + ndjson  --> geojson
* see details of csv2json, join, map at https://github.com/mbostock/ndjson-cli

Detail steps 
------------ 

Step numbers are in ref to https://github.com/tin6150/inet-dev-class/blob/master/mapbox/eg_data_ndjson/README.txt.rst

**Prep step**
- ensure csv has first row as field names
- rename field names so that it doesn't have space? eg use sed -e ... 

# rename field names (strip space is most important)
dos2unix < kff_capacity_dw_2020_0409.csv | sed -e "s/Total Hospital Beds/TotalHospitalBeds/" -e "s/Hospital Beds per 1,000 Population/HospBedsPer1kPop/"  -e "s/Total CHCs/TotalCHCs/" -e "s/CHC Service Delivery Sites/CHCServiceDeliverySites/" > kff_capacity_dw_2020_0409.prepd.csv # **0**
# there are comments at top and bottom of the csv from kff, may need to clean them first :
cat kff_capacity_dw_2020_0409.prepd.csv  | fgrep '",' | csv2json -n > kff_capacity_dw_2020_0409.ndjson # Alaska, Alabama  # 69 entries **Step 3 in tutorial** *?*

**Step 1: geo2ndj**
# convert geojson to ndjson, note that ndjson-split can't handle newline in its input, thus the filter via json5i :
cat stateData.geojson | json5 | ndjson-split 'd.features' > stateData.ndjson # 52 "states": Alabama, Hawaii, Puerto Rico  # **no mapping yet**

**Step 2: add key** 
# add a Location column to ndjson, so that it can be used as key for join , via ndjson-map cmd :
cat stateData.ndjson | ndjson-map 'd.Location = d.properties.name, d' > stateData-loc.ndjson #  **add mapping, create key field for join**

**Step 4 join**
# perforn ndjson-join of  bed capacity + state shape data :
# inner join seems appropriate.  ndjson-join could not take key "two level down" the json object, thus the earlier step of creating field with matching name as key
# below get 51 record, decent
ndjson-join  'd.Location'  stateData-loc.ndjson  kff_capacity_dw_2020_0409.ndjson  > state+capacity.ndjson    # 51 entries  **4**join**   trying with geometry as d[0]

# result of 1 entry below, split into multiple lines by me.  Note it has two elements, as d[0] and d[1] # ??

[{"type":"Feature",
  "id":"01",
  "properties":{"name":"Alabama","density":94.65},
  "geometry":{"type":"Polygon","coordinates":[[[-87.359296,35.00118],[-85.606675,34.984749],[-85.431413,34.124869],[-85.184951,32.859696],[-85.069935,32.580372],[-84.960397,32.421541],[-85.004212,32.322956],[-84.889196,32.262709],[-85.058981,32.13674],[-85.053504,32.01077],[-85.141136,31.840985],[-85.042551,31.539753],[-85.113751,31.27686],[-85.004212,31.003013],[-85.497137,30.997536],[-87.600282,30.997536],[-87.633143,30.86609],[-87.408589,30.674397],[-87.446927,30.510088],[-87.37025,30.427934],[-87.518128,30.280057],[-87.655051,30.247195],[-87.90699,30.411504],[-87.934375,30.657966],[-88.011052,30.685351],[-88.10416,30.499135],[-88.137022,30.318396],[-88.394438,30.367688],[-88.471115,31.895754],[-88.241084,33.796253],[-88.098683,34.891641],[-88.202745,34.995703],[-87.359296,35.00118]]]},
  "Location":"Alabama"},
 {"Location":"Alabama",
  "TotalHospitalBeds":"15278",
  "HospitalBedsPer1kPop":"3.13",
  "TotalCHCs":"15",
  "CHCServiceDeliverySites":"144",
  "Footnotes":""}
]



# above ndjson are two items, need to remap as single element.  could add calculated fields too, see tutorial

**Step 5: re-map/restructure**
# reshape the ndjson structure (result above are split into 2 element array)
  need to at least "move" the important data into the first array element 
  during this process, turn from 2-element array into single object, which mean strip outermost [ ] of each entry (ndjson line).
  use ndjson-map (cannot access fieldname with space):

ndjson-map 'd[0].properties = { name: d[0].properties.name, totalBed: d[1].Location }, d[0]'  < state+capacity.ndjson >  state+capacity.remapped.ndjson # **5: simple eg of remap**
ndjson-map 'd[0].properties = { name: d[0].properties.name, TotalHospitalBed: d[1].TotalHospitalBeds, HospitalBedsPer1kPop: d[1].HospitalBedsPer1kPop, TotalCHCs: d[1].TotalCHCs, CHCServiceDeliverySites: d[1].CHCServiceDeliverySites, Footnotes: d[1].Footnotes }, d[0]'  < state+capacity.ndjson >  state+capacity.remapped.ndjson # **5: re-map** 

**Step 6: ndj2geo**
# convert ndjson to regular geojson, need to add some "opener" structure into the json - 
cat capacity+state.ndjson    | ndjson-reduce | ndjson-map '{type: "FeatureCollection", features: d}'  > capacity+state-m1.geojson # Step 6a: i dont like this method, use 6b below
                                                           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*^ readd the opener needed to create geojson

ndjson-reduce 'p.features.push(d), p' '{type: "FeatureCollection", features: []}'  < state+capacity.remapped.ndjson > state+capacity.geojson  # **6b** **ndj2geo** **method 2 w/ ndjson-reduce;  i like this better** 
                                   |   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^||^-------<<<--- re-add the opener needed to create geojson
                                   more cler of where ndjson data get shoved into


*tin@Tin-U55:~/tin-gh/covid19_care_capacity_map$ git commit -a -m "ok, finally got a working geojson map with data in it!"*


**add cases data, may need to go back and go thru the cycle again**


*think all ndjson files are tmp and can be rm*



Ref
===

* https://covidtracking.com/data  and  https://covidtracking.com/api
 


.. # use 8-space tab as that's how github render the rst
.. # vim: shiftwidth=8 tabstop=8 noexpandtab paste 
