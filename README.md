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
