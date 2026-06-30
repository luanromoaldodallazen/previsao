import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:previsao_tempo/models/city_model.dart';

class CityService {
  static Future<List<CityModel>> fetchCityByState(String uf) async {
    final url = Uri.parse(
      'https://servicodados.ibge.gov.br/api/v1/localidades/estados/$uf/municipios',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception(
        'Erro ao buscar cidades: ${response.statusCode}',
      );
    }

    final List<dynamic> json = jsonDecode(response.body);

    return json
        .map((cidade) => CityModel.fromJson(cidade))
        .toList();
  }

  static Future<Map<String, double>> buscarCoordenadas(
    String cidade,
    String estado,
  ) async {
    final url = Uri.parse(
      "https://geocoding-api.open-meteo.com/v1/search?name=$cidade&count=1&language=pt&format=json",
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception("Erro ao buscar coordenadas.");
    }

    final json = jsonDecode(response.body);

    if (json["results"] == null || json["results"].isEmpty) {
      throw Exception("Cidade não encontrada.");
    }

    final resultado = json["results"][0];

    return {
      "latitude": (resultado["latitude"] as num).toDouble(),
      "longitude": (resultado["longitude"] as num).toDouble(),
    };
  }
}
