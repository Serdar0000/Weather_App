class Weather {
  final int temp;
  final String icon;
  final int maxTemp;
  final int minTemp;
  final String? weekday;
  final String? type;

  Weather({
    required this.temp, 
    required this.icon, 
    required this.maxTemp, 
    required this.minTemp, 
     this.weekday,
     this.type
  });
}