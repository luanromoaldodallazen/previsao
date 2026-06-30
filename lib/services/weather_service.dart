import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:previsao_tempo/models/weather_model.dart';

class WeatherService {
  static Future<WeatherModel> buscarClima({
    required double latitude,
    required double longitude,
  }) async {
    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$latitude'
      '&longitude=$longitude'
      '&current=temperature_2m,relative_humidity_2m,wind_speed_10m'
      '&daily=temperature_2m_max,temperature_2m_min'
      '&timezone=auto',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception(
        'Erro ao buscar previsão do tempo: ${response.statusCode}',
      );
    }

    final Map<String, dynamic> json = jsonDecode(response.body);

    return WeatherModel.fromJson(json);
  }

  static Future<WeatherModel> buscarPorCidade({
    required String cidade,
    required String estado,
  }) async {
    final coordenadas = await _buscarCoordenadas(cidade, estado);

    return buscarClima(
      latitude: coordenadas['latitude']!,
      longitude: coordenadas['longitude']!,
    );
  }

  static Future<Map<String, double>> _buscarCoordenadas(
    String cidade,
    String estado,
  ) async {
    final url = Uri.parse(
      'https://geocoding-api.open-meteo.com/v1/search'
      '?name=$cidade'
      '&count=1'
      '&language=pt'
      '&format=json',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar coordenadas.');
    }

    final json = jsonDecode(response.body);

    if (json['results'] == null || json['results'].isEmpty) {
      throw Exception('Cidade não encontrada.');
    }

    final resultado = json['results'][0];

    return {
      'latitude': (resultado['latitude'] as num).toDouble(),
      'longitude': (resultado['longitude'] as num).toDouble(),
    };
  }
}
