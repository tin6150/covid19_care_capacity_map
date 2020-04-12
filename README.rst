covid19_care_capacity_map
~~~~~~~~~~~~~~~~~~~~~~~~~

Hospital bed capacity by state vs covid19 cases  
May help present problem to those shrugging the COVID19 problem off?  \
For now plan to display hospital bed and hospitalized patient count \
Ideally also get ICU bed count and usage.


.. .md two tailing white spaces cannot cause a hard line break  
.. nor can \ 
.. i wondered about: \ at the end, but that didnt work either


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



what mapbox would need, single date entry (ie, use diff file for data of another date, may create too many files). 
Saving these as example files 
 - singlePropertyEg.json5 - a geojson file, but have comments.  use json5 to convert as needed.
 - nestedPropertyEg.geojson - properties has a list, one item per date, would mapbox take it?  can it be queried in web app? and colored correctly?  TBD

.. code:: json5 

        { "type": "FeatureCollection", "features": [

            { "type":       "Feature",
              //"id":           "01",           // id was present in stateData.geojson, but not likely required by mapbox
              "properties": {
                    "date":          "20200411",              // date record refers to.  use this in map
                    "dateModified":  "2020-04-11T20:00:00Z",  // date in ISO 8601 format, but this is not date of the data, but admin work timestamp
                    "fips":                 6,	// state code, perhaps use as id for json record as well
                    "state":             "CA",
                    "positive":         19472,
                    "hospitalized":      5236,  // actual bed usage since no icubed count
                    "inIcuCurrently":    1591,    
                    "negative":        152604,  // dont really care for this
                    "death":              541,
                    "grade":              "B",
                    "bed":               5000,  // from kff
                    "icubed":            "NA",  // dont have data for this
                    "density":          94.65,  // from stateData.geojson
                    "popolation":    39000123   // from wikipedia, calif has ~39M 
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




Ref
===

* https://www.zdnet.com/article/data-scientists-white-house-issues-a-call-to-arms/
* https://pages.semanticscholar.org/coronavirus-research
* https://covidtracking.com/data  and  https://covidtracking.com/api
 
* Example geoJSON: https://www.mapbox.com/help/data/stations.geojson
* Additional ref: https://www.mapbox.com/help/define-geojson/


.. # use 8-space tab as that's how github render the rst
.. # vim: shiftwidth=8 tabstop=8 noexpandtab paste 
