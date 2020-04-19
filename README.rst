covid19_care_capacity_map
~~~~~~~~~~~~~~~~~~~~~~~~~

Hospital bed capacity by state vs covid19 cases  
May help present problem to those shrugging the COVID19 problem off?  \
For now plan to display hospital bed and hospitalized patient count \
Ideally also get ICU bed count and usage.

URL: https://tin6150.github.io/covid19_care_capacity_map/


.. .md two tailing white spaces cannot cause a hard line break  
.. nor can \ 
.. i wondered about: \
 at the end, but that didnt work either


DEV NOTES
=========


* https://www.kff.org/health-costs/issue-brief/state-data-and-policy-actions-to-address-coronavirus/#stateleveldata
    - ploy this against a map of population data, per state.
    - kff on same page has covid19 cases and deaths, but no date on the data…

	
* There are likely newer data, but here is a rough guide of population by state: \
  https://en.wikipedia.org/wiki/List_of_states_and_territories_of_the_United_States_by_population
		
		
* https://docs.mapbox.com/help/tutorials/choropleth-studio-gl-pt-1/
    - previous published mapbox studio used "stateData-6oppga as data source, named as sn50.a1rkty36 
    - state data: https://docs.mapbox.com/help/demos/choropleth-studio-gl/stateData.geojson




OLD Dev Notes
=============

  
* https://docs.mapbox.com/studio-manual/examples/choropleth-map/
  - choropleth tutorial from mapbox with state population data.

* https://leafletjs.com/examples/choropleth/
   - leafletjs tutorial with actual geojson of state coordinate + population data from wikipedia and census. 
   - js snippet containing geo-coordinated data: https://leafletjs.com/examples/choropleth/us-states.js
  
* https://github.com/tin6150/inet-dev-class/tree/master/mapbox

* https://blog.mapbox.com/the-net-neutrality-map-how-i-built-it-c387c9cb64a8 
  TIPPEcanoe tool for manipulating shapefiles; anything on gson?


Tools
=====

observableHQ.com
    jupeter notebook on steroid? tuned for interactive data exploration and viz

ndjson-cli
    newline delimited json.  leverage/combine features of unix shell and javascript.   \
    A 4 part tutorial with many commands to manipulate gis data:
    https://medium.com/@mbostock/command-line-cartography-part-2-c3a82c5c0f3

merge csv with state/date/case data vs geojson/js coordinate file, joining it via id such as state name (?) 
    ndjson-join 'd.id' ca-albers-id.ndjson  cb_2014_06_tract_B01003.ndjson > ca-albers-join.ndjson
		
TopoJSON 
    use ARCs instead of sequence of coordinates, thus reducing file size. \
    topomerge can combine census track data into county level data.

SOURCE FILES
============

::

	stateData.geojson		# gson with coordinate of 50 states, for choropleth., from https://docs.mapbox.com/help/tutorials/choropleth-studio-gl-pt-1

	capacity_v_pop.sketch.csv 	# sketch, combination of care capacity by state and some manual add on data for state population and number of cases

	kff_capacity_dw_2020_0409.csv	# care capacity (hospital beds) from KPP.org downloaded on 2020.04.09
	kff_cases_dw_2020_0409.csv	# covid19 cases by state, downloaded 2020.04.09 (may find better data elsewhere?)
	kff_testing_dw_2020_0409.csv	# covid19 tests by state, downloaded 2020.04.09 


	cases
	covidtrack_daily.csv		# API download, should have historical case data for all states

					# need a script to generate gson5 ...


Data files for web app
----------------------

::

	cases_yyyy_mm_dd.csv		# 1 file for each date, like it was done on adjoin data set (?)
	
	join with state*gson to create gson for Mapbox ?



geoJSON format
==============

Snippet of state polygon from stateData.geojson:

.. code:: geojson

    //{ "type": "FeatureCollection", "features": [ {
            "type":         "Feature",
            "id":           "01",
            "properties": {
                            "name":"Alabama",
                            "density":94.65},
	    "geometry":   { "type":"Polygon","coordinates":[[[-87.359296,35.00118],[-85.606675,34.984749],
	... ]]}},
    //]}

.. github rst dont know geojson5, likely just parsed as vanilla text block.
.. code:: geojson5

        {"type":"Feature","id":"01","properties":{"name":"Alabama","density":94.65},
            "geometry":{"type":"Polygon","coordinates":[[[-87.359296,35.00118],[-85.606675,34.984749],
        ... ]]}},

.. code:: geojson

	{"type":"FeatureCollection","features":[
		{"type":"Feature","id":"72","properties":{"name":"Puerto Rico","density":1082 },"geometry":{"type":"Polygon","coordinates":[[[-66.448338,17.984326],[-66.771478,18.006234],[-66.924832,17.929556],[-66.985078,17.973372],[-67.209633,17.956941],[-67.154863,18.19245],[-67.269879,18.362235],[-67.094617,18.515589],[-66.957694,18.488204],[-66.409999,18.488204],[-65.840398,18.433435],[-65.632274,18.367712],[-65.626797,18.203403],[-65.730859,18.186973],[-65.834921,18.017187],[-66.234737,17.929556],[-66.448338,17.984326]
		]]}}
	]}



Prototype 1: for what mapbox would need.  This one is a single date entry (ie, would use diff file for data of another date, may create too many files).   mapbox import ok, data format parsed as expected
``json5 EgPropertySingle.json5 > singlePropertyEg.geojson``

.. code:: json5 

        { "type": "FeatureCollection", "features": [

            { "type":       "Feature",
              //"id":           "01",           // id was present in stateData.geojson, but not likely required by mapbox
              "properties": {
                    "date":          "20200411",              // date record refers to.  use this in map
                    "dateModified":  "2020-04-11T20:00:00Z",  // date in ISO 8601 format, but this is not date of the data, but admin work timestamp
                    "fips":                 6,	// state code, perhaps use as id for json record as well
                    "state":             "CA",
                    "positive":         19472,  // Total cumulative positive test results.
                    "hospitalized":      5236,  // actual bed usage since no icubed count
                    "inIcuCurrently":    1591,    
                    "negative":        152604,  // dont really care for this
                    "death":              541,
                    "grade":              "B",
                    "bed":               5000,  // from kff.  at first wont handle case with bed number change
                    "icubed":            "NA",  // dont have data for this
                    "popolation":    39000123,  // from wikipedia, calif has ~39M 
                    "case2bed":         0.001,  // calculated ratio/%: hospitilized/bed
                    "icu2icuBedRat":    0.000,  // calculated %: icu case / icu bed, 0 when dont have this data. 
                    "positive2pop":     0.001,  // % pop positive (is positive number cumilative?)
                    "density":          94.65   // from stateData.geojson, maybe drop
              } // properties is required (at least for mapbox), even if empty.  could give it name or timestamp
              ,
              "geometry": { "type": "Polygon", "coordinates": [ [
                      [ -121.985, 37.407 ],     // LT // would actually be a much longer list of points for state boundary
                      [ -121.984, 37.407 ],     // RT
                      [ -121.984, 37.406 ],     // RB
                      [ -121.985, 37.406 ],     // LB
                      [ -121.985, 37.407 ],     // LT, close it back.  5 points make a square :)
              ] ] }  // strangely need to open two square bracket (support for multi-polygon?)
            }
            //,   // add comma iff there is next entry, json don't have a comment officially

        ] } // tagged as json5, comments would be allowed if parser supports this new version



Prototype 2 alternate format for mapbox.  This one is use nesting, containing 2 date entres (ie, would use single datafile and upload to mapbox).
see ``json5 EgPropertyArray.json5 > EgPropertyArray.geojson`` 
would mapbox take it?  can it be queried in web app? and colored correctly?  TBD
No, while could create correct .json, mapbox complained during import: ``Input failed. "properties" member should be object, but is an Array instead on line 1.``

Thus, essentially, each Feature need to have its geometry.
Multiple date entry for same state would need multiple feature, each with its own geometry (coordinate list).
Then, may as well just have one file per date.

Correctly imported by mapbox (tin117): 
- EgPropertySingle_x2.json5
- EgPropertySingle_x3.json5

Pros and cons of single .geojson vs many files, one per date:

- single file will end up more compressible, faster to load, less javascript coding?   Untested approach.
- multiple file will be tried method as done for previous data viz proj with mapbox.
- maybe mood point now, dont actually need to upload to mapbox and generate tileset (though that may actually be faster?)

Algorithm
=========

* .geojson can be stored on fs, instead of a tileset in mapbox server
* single .geojson file, color like NYC collision eg
* HI likely a multi polygon, so create a state.ndjson
* csv-etl.py script to create csv with data i need, include the calculated columns
* ndjson join :  csv(case) + kpp(bed count) --> ndjson 
* ndjson join :  ndjson + state --> geojson
* see details of csv2json, join, map at https://github.com/mbostock/ndjson-cli

Detail steps 
------------ 

Step numbers are in ref to https://github.com/tin6150/inet-dev-class/blob/master/mapbox/eg_data_ndjson/README.rst

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
cat capacity+state.ndjson    | ndjson-reduce | ndjson-map '{type: "FeatureCollection", features: d}'  > capacity+state-m1.geojson # **dont use this version**  **6a**
                                                           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*^ readd the opener needed to create geojson

ndjson-reduce 'p.features.push(d), p' '{type: "FeatureCollection", features: []}'  < capacity+state.ndjson > capacity+state.geojson  # **6b** **ndj2geo** **method 2 w/ ndjson-reduce;  i like this better** 
                                   |   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^||^-------<<<--- re-add the opener needed to create geojson
                                   more cler of where ndjson data get shoved into

resulting features had extra [] ... maybe need method 1 instead ...  nope, produce same file with extra []

cuz ca-albers-density.ndjson started as {}, not [{ }]
is it just one opening and tailing [ ] ??
                                                           
                                                           
                                                           


Dev Env
=======

To avoid CORS error (since html need to load a .geojson), run a simple web server from the directory containing the files of the project ::

        python -m SimpleHTTPServer 8000

Then on browser, navigate to http://localhost:8000 



Ref
===

* https://www.zdnet.com/article/data-scientists-white-house-issues-a-call-to-arms/
* https://pages.semanticscholar.org/coronavirus-research
* https://covidtracking.com/data  and  https://covidtracking.com/api
 
* Example geoJSON: https://www.mapbox.com/help/data/stations.geojson
* Additional ref: https://www.mapbox.com/help/define-geojson/

* mapbox tutorial multi-date data in .geojson (NYC collision): https://docs.mapbox.com/help/tutorials/show-changes-over-time/ , 
  with personalized test at: https://tin6150.github.io/covid19_care_capacity_map/eg_nyc_collision_map.html 



.. # use 8-space tab as that's how github render the rst
.. # vim: shiftwidth=8 tabstop=8 noexpandtab paste 
