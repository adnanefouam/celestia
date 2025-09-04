class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://api.openweathermap.org';

  // API versions
  static const String v2_5 = '/data/2.5';
  static const String v3_0 = '/data/3.0';
  static const String geo1_0 = '/geo/1.0';

  // Base endpoints
  static const String _weatherBase = '$baseUrl$v2_5';
  static const String _oneCallBase = '$baseUrl$v3_0';
  static const String _geocodingBase = '$baseUrl$geo1_0';

  // Weather endpoints
  static const String currentWeather = '$_weatherBase/weather';
  static const String forecast5Day = '$_weatherBase/forecast';
  static const String forecast16Day = '$_weatherBase/forecast/daily';
  static const String historicalWeather = '$_weatherBase/history';

  // One Call API endpoints
  static const String oneCall = '$_oneCallBase/onecall';
  static const String oneCallTimestamp = '$_oneCallBase/onecall/timemachine';
  static const String oneCallDaily = '$_oneCallBase/onecall/day_summary';
  static const String oneCallOverview = '$_oneCallBase/onecall/overview';

  // Geocoding endpoints
  static const String geocodingDirect = '$_geocodingBase/direct';
  static const String geocodingReverse = '$_geocodingBase/reverse';
  static const String geocodingZip = '$_geocodingBase/zip';

  // Map endpoints
  static const String mapUrl = 'https://tile.openweathermap.org/map';
  static const String iconUrl = 'https://openweathermap.org/img/wn';

  // Map layers
  static const String cloudsLayer = '$mapUrl/clouds_new';
  static const String precipitationLayer = '$mapUrl/precipitation_new';
  static const String pressureLayer = '$mapUrl/pressure_new';
  static const String windLayer = '$mapUrl/wind_new';
  static const String temperatureLayer = '$mapUrl/temp_new';

  // Icon helpers
  static String getIconUrl(String iconCode, {String size = '2x'}) {
    return '$iconUrl/$iconCode@$size.png';
  }

  static String getMapTileUrl(
      String layer, int zoom, int x, int y, String apiKey) {
    return '$layer/$zoom/$x/$y.png?appid=$apiKey';
  }
}

class ApiQueryParams {
  ApiQueryParams._();

  // Common parameters
  static const String apiKey = 'appid';
  static const String lat = 'lat';
  static const String lon = 'lon';
  static const String units = 'units';
  static const String lang = 'lang';
  static const String mode = 'mode';
  static const String cnt = 'cnt';
  static const String exclude = 'exclude';

  // Geocoding parameters
  static const String query = 'q';
  static const String limit = 'limit';
  static const String zipCode = 'zip';

  // Historical parameters
  static const String start = 'start';
  static const String end = 'end';
  static const String dt = 'dt';

  // Units
  static const String unitsMetric = 'metric';
  static const String unitsImperial = 'imperial';
  static const String unitsStandard = 'standard';

  // Languages
  static const String langEnglish = 'en';
  static const String langFrench = 'fr';
  static const String langSpanish = 'es';
  static const String langGerman = 'de';
  static const String langItalian = 'it';
  static const String langPortuguese = 'pt';
  static const String langRussian = 'ru';
  static const String langChinese = 'zh_cn';
  static const String langJapanese = 'ja';
  static const String langArabic = 'ar';

  // Response modes
  static const String modeJson = 'json';
  static const String modeXml = 'xml';
  static const String modeHtml = 'html';

  // One Call excludes
  static const String excludeCurrent = 'current';
  static const String excludeMinutely = 'minutely';
  static const String excludeHourly = 'hourly';
  static const String excludeDaily = 'daily';
  static const String excludeAlerts = 'alerts';
}

class ApiHeaders {
  ApiHeaders._();

  static const String contentType = 'Content-Type';
  static const String accept = 'Accept';
  static const String userAgent = 'User-Agent';
  static const String authorization = 'Authorization';

  static const String applicationJson = 'application/json';
  static const String applicationXml = 'application/xml';
  static const String textHtml = 'text/html';

  static Map<String, String> get defaultHeaders => {
        contentType: applicationJson,
        accept: applicationJson,
        userAgent: 'Celestia Weather App/1.0.0',
      };
}
