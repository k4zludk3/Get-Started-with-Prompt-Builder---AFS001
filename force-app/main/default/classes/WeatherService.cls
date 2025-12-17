public class WeatherService {
    /**
     * Gets the weather at Coral Cloud Resort for the provided date
     */
    public static Weather getResortWeather(Date dateToCheck) {
      
        // Calculate the number of days between today and the dateToCheck
        Integer days = Date.today().daysBetween(dateToCheck);

        // Get API key from custom metadata
        Weather_API_Key__mdt apiKeyConfig = Weather_API_Key__mdt.getInstance('Weather_API_Key');
        String API_Key = apiKeyConfig.API_Key__c;

    //Prepare API request
    //units = M or I
    
    HttpRequest req = new HttpRequest();
    req.setEndpoint('callout:WeatherBit?lat=37.789782764570425&lon=-122.39723702244089&days=' + days + '&key=' + API_key);
    req.setMethod('GET');
    // Make callout
    Http http = new Http();
    HttpResponse res = http.send(req);
    if (res.getStatusCode() != 200) {
      throw new CalloutException('Bad response: ' + res);
    }

    // The response contains a list of temperatures for different times of the day
    // We parse the response and find the min and max temperatures
    String body = res.getBody();

    
    Map<String, Object> parsedResponse = (Map<String, Object>) JSON.deserializeUntyped(body);

        // Extract the 'data' key from the response
        List<Object> dataList = (List<Object>) parsedResponse.get('data');
        if (dataList == null || dataList.isEmpty()) {
            return null; // No weather data available
        }

        // Get the first weather data entry (you can adjust if needed for multiple entries)
        Map<String, Object> weatherData = (Map<String, Object>) dataList[days-1];

        // Extract relevant fields
        Decimal minTempC = (Decimal) weatherData.get('min_temp');
        Decimal maxTempC = (Decimal) weatherData.get('max_temp');
        Map<String, Object> weatherDescription = (Map<String, Object>) weatherData.get('weather');
        String description = (String) weatherDescription.get('description');

        // Convert Celsius to Fahrenheit
        Decimal minTempF = (minTempC * 9 / 5) + 32;
        Decimal maxTempF = (maxTempC * 9 / 5) + 32;

        // Create and populate the Weather object
        Weather weather = new Weather();
        weather.minTemperatureC = minTempC;
        weather.minTemperatureF = minTempF;
        weather.maxTemperatureC = maxTempC;
        weather.maxTemperatureF = maxTempF;
        weather.description = description;

        return weather;
    
  }

  private static Decimal toFahrenheit(Decimal celsuis) {
    return (celsuis * 9 / 5 + 32).setScale(1);
  }

  private class WeatherApiResponse {
    public List<TemperatureWrapper> weather;
  }

  private class TemperatureWrapper {
    public Decimal temperature;
  }

  public class Weather {
    public Decimal minTemperatureC;
    public Decimal minTemperatureF;
    public Decimal maxTemperatureC;
    public Decimal maxTemperatureF;
    public String description;
  }
}