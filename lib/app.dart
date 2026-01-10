import 'package:flutter/material.dart';
import 'package:weather_app/repositories/weatherRepository.dart';
import 'package:weather_app/theme.dart';
import 'package:weather_app/models/weather.dart';

class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});

  @override
  State<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  Weather? weather;
  List<Weather>? weekWeather;
  final WeatherRepository  weather_repository = WeatherRepository(); 
  final TextEditingController controller = TextEditingController();
  
 void getData() async {
  String searchCity = controller.text.trim();
  
  if (searchCity.isEmpty) {
    searchCity = 'Astana';
    controller.text = 'Astana'; 
  }

  final dayData = await weather_repository.getWeather(searchCity);
  final weekData = await weather_repository.getWeatherforWeek(searchCity);

  if (mounted) {
    setState(() {
      weather = dayData;
      weekWeather = weekData;
    });
  }
}
  @override
  void initState() {
    super.initState();
    getData();
    
  }




  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      theme: theme,
      debugShowCheckedModeBanner: false,
      home:Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/${weather?.type}.png"), 
            fit: BoxFit.cover,
          ),
        ),
      child: 
      Scaffold(
        body: weather == null && weekWeather == null ? Center(child: CircularProgressIndicator(color: Colors.white),) : 
        Padding(padding: EdgeInsets.all(20),
        child:
         ListView(
          children: [
            TextField(
              style: TextStyle(color: Colors.white,fontSize: 25),
              onSubmitted: (value) => getData(),
              controller: controller,
            decoration: InputDecoration(
            labelText: 'Введите текст',
            hintText: "Searh city",
          border: OutlineInputBorder(), 
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
            borderSide: BorderSide(color: const Color.fromARGB(255, 199, 248, 22), width: 2.0),
            ),
           enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(45)),
            borderSide: BorderSide(color: Colors.grey, width: 1.0),
     ),
  ),
),
            SizedBox(height: 20,),
            Column(
              children: [
                
                SizedBox(height: 100,),
                Center(
                  child: Image.network("https://openweathermap.org/img/wn/${weather?.icon}@4x.png"
                  ,height:100 ,
                  width: 100,
                  ),
                ),
                Text("${controller.text}",style:theme.textTheme.titleLarge),
                Text("${weather?.temp}",style: theme.textTheme.titleMedium),
                Text("${weather?.maxTemp} / ${weather?.minTemp}",style:theme.textTheme.titleSmall),
              ],
            ),
            SizedBox(height: 15,),
            ListView.builder(
            shrinkWrap: true, // Позволяет ListView занять только необходимое место
            physics: const NeverScrollableScrollPhysics(),
            itemCount: weekWeather?.length ?? 0, // Защита от null
            itemBuilder: (context, i) {
            final day = weekWeather![i]; 
            return ListTile(leading: Image.network("https://openweathermap.org/img/wn/${day.icon}@2x.png",width: 50,),
                    title: Text("${day.temp}°", style: theme.textTheme.bodyMedium),
                    subtitle: Text("${day.maxTemp}° / ${day.minTemp}°", style: theme.textTheme.titleSmall),
                    trailing: Text("${day.weekday}", 
                    style: theme.textTheme.titleSmall,
                  ),
                );
              },
            ),
          ]),
        ),
      ),)
    );
  }
}
