### Purpose

The purpose of this RShiny application is to smooth the creation of census level coverage maps of vaccination data, once the data has been processed to the expected format type. There is flexibility to use this platform for other population level data points. For example, while the system is built to accept a data set consisting of fully vaccinated counts per census tract, it could also accept any other "counting" data point per census tract.

### How to Use This Shiny Application

1. Get a Census API Key

Visit [https://api.census.gov/data/key_signup.html](<https://api.census.gov/data/key_signup.html>) and get a census API key.

2. Put your census API key in a text file called ```census_api_key_hold.txt```

3. Place your vaccination data in the ```data``` folder

vaccination data must be called: ```vaxx_data_in.csv```

| columns | description |
| --- | --- |
| GEOID | Numerical code for the census tract under consideration (ex. 26001000100) |
| COUNTVAXXED | Count of individuals with vaccination characteristics under consideration |

4. Run the app

---

### Included Data Sets

* ```state_number_crosstab.tsv``` - tab separated data file of state abbreviations and the numerical codes used to represent each U.S. state in census data pulls

| columns | description |
| --- | --- |
| state | two-letter U.S. state abbreviations (ex. AL, MI) |
| code | two number IDs (ex. 01, 26) |

Source: [Attachment 100: Census Bureau State and County Codes](<https://www.nlsinfo.org/content/cohorts/nlsy97/other-documentation/geocode-codebook-supplement/attachment-100-census-bureau>)

* 2019 ACS Populations - data is pulled using ```censusapi```, stored versions are saved in ```./data/2019_acs_populations``` for quicker processing

[CensusAPI Information](<https://cran.r-project.org/web/packages/censusapi/censusapi.pdf>)

* ```matching_vars.csv``` - comma separated data file of census variable codes and their definitions

| columns | description |
| --- | --- |
| Group | Census variable code (ex. B01001A) |
| Number | integer number running down list |
| MatchCode | Combination of Group and Number used to match the census variable identifier to its written definition |
| Description | Age, sex, etc. descriptor for each MatchCode |
| Sex | Relevant sex information for each MatchCode |
| Race | Relevant race information for each MatchCode |

Source: [Census API: groups in /data/2019/acs/acs5/groups](<https://api.census.gov/data/2019/acs/acs5/groups.html>)

* Census Tract and County Line Shapefiles - this data is not stored, but is regularly pulled via ```tidycensus```; both 2010 and 2020 options are available

[Tidycensus Information](<https://walker-data.com/tidycensus/>)

---

### Notes:

* The created map can be downloaded as an interactive .html document using the "Download Map" button. The map will be saved as ```map_out.html``` in your Downloads folder.

* Population age groups available within the platform are under five years old, under 18 years old, 18 years old and older, and all ages (0-100+)
