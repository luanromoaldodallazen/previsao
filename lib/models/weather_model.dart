class WeatherModel {
  double? temperatura;
  double? temperaturaMinima;
  double? temperaturaMaxima;
  double? velocidadeVento;
  int? umidade;

  WeatherModel({
    this.temperatura,
    this.temperaturaMinima,
    this.temperaturaMaxima,
    this.velocidadeVento,
    this.umidade,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      temperatura: (json['current']['temperature_2m'] as num).toDouble(),
      velocidadeVento: (json['current']['wind_speed_10m'] as num).toDouble(),
      umidade: json['current']['relative_humidity_2m'],
      temperaturaMinima:
          (json['daily']['temperature_2m_min'][0] as num).toDouble(),
      temperaturaMaxima:
          (json['daily']['temperature_2m_max'][0] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperatura': temperatura,
      'temperaturaMinima': temperaturaMinima,
      'temperaturaMaxima': temperaturaMaxima,
      'velocidadeVento': velocidadeVento,
      'umidade': umidade,
    };
  }
}
