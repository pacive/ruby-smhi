# SMHI
A class for convenient access to a weather forecast from SMHI

SMHI::Forecast offers many ways to get the data one needs by providing several 
aliases and allows chaining of methods to narrow down the search.
  
### Example:
```ruby
require 'smhi'
fcst = SMHI.parse(SMHI.point_forecast(57.999628, 16.017767))
fcst.temperature.at(Time.now) # => Float
fcst.precip_mean.between((Time.now + 2 * 3600)..(Time.now + 5 * 3600)).values # => Array
fcst.wd[2] # => Integer
fcst['visibility'][0] # => Float
```
For more information on the available parameters, 
see http://opendata.smhi.se/apidocs/metfcst/parameters.html#parameter-table
