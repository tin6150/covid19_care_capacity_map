covid19_care_capacity_map
~~~~~~~~~~~~~~~~~~~~~~~~~

Developer notes for the COVID-19 Hospital bed utilization (capacity) map.



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

* https://coronavirus.1point3acres.com/en/data  JHU get US data from them!
* jhu
* wikipedia
* https://www.trackcorona.live/api
* https://www.cdph.ca.gov/Programs/CID/DCDC/Pages/Immunization/ncov2019.aspx ??


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
                    "state":             "CA",  // Need to create a join table with Location: California
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


Algorithm and steps
===================

See 
* README.Alg1_state+capa.txt.rst



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
