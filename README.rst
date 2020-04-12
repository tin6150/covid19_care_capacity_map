covid19_care_capacity_map
~~~~~~~~~~~~~~~~~~~~~~~~~

Hospital bed capacity by state vs covid19 cases

May help present problem to those shrugging the COVID19 problem off?




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

	capacity_v_pop.sketch.csv 	# sketch, combination of care capacity by state and some manual add on data for state population and number of cases
	kff_capacity_dw_2020_0409.csv	# care capacity (hospital beds) from KPP.org downloaded on 2020.04.09
	kff_cases_dw_2020_0409.csv	# covid19 cases by state, downloaded 2020.04.09 (may find better data elsewhere?)
	kff_testing_dw_2020_0409.csv	# covid19 tests by state, downloaded 2020.04.09 

	stateData.geojson		# gson with coordinate of 50 states, for choropleth., from https://docs.mapbox.com/help/tutorials/choropleth-studio-gl-pt-1
					# need a script to generate geojson...

	cases

Data files for web app
======================

::

	cases_yyyy_mm_dd.csv		# 1 file for each date, like it was done on adjoin data set (?)
	
	join with state*gson to create gson for Mapbox ?

Ref
===

* https://www.zdnet.com/article/data-scientists-white-house-issues-a-call-to-arms/
* https://pages.semanticscholar.org/coronavirus-research
* https://covidtracking.com/data  and  https://covidtracking.com/api


\

.. # use 8-space tab as that's how github render the rst
.. # vim: shiftwidth=8 tabstop=8 noexpandtab paste 
