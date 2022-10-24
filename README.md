# How to Use This Shiny Application

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

* 2019 ACS Populations

* matching_vars.csv

* Census Tract and County Line Shapefiles
