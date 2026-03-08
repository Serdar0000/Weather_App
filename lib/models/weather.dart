class Weather {
  final int temp;
  final String icon;
  final int maxTemp;
  final int minTemp;
  final String? weekday;
  final String? type;
  final double humidity;
  final double windSpeed;
  final int pressure;
  final int visibility;
  final String? city;
  final String? country;

  Weather({
    required this.temp, 
    required this.icon, 
    required this.maxTemp, 
    required this.minTemp,
    this.weekday,
    this.type,
    double humidity = 0,
    double windSpeed = 0,
    int pressure = 0,
    int visibility = 0,
    this.city,
    this.country,
  }) : humidity = humidity,
       windSpeed = windSpeed,
       pressure = pressure,
       visibility = visibility;
}