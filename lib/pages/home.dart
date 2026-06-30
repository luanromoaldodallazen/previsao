import 'package:flutter/material.dart';
import 'package:previsao_tempo/models/city_model.dart';
import 'package:previsao_tempo/models/weather_model.dart';
import 'package:previsao_tempo/repository/database_repository.dart';
import 'package:previsao_tempo/services/city_service.dart';
import 'package:previsao_tempo/services/weather_service.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _formKey = GlobalKey<FormState>();

  final List<String> estados = const [
    'AC',
    'AL',
    'AP',
    'AM',
    'BA',
    'CE',
    'DF',
    'ES',
    'GO',
    'MA',
    'MT',
    'MS',
    'MG',
    'PA',
    'PB',
    'PR',
    'PE',
    'PI',
    'RJ',
    'RN',
    'RS',
    'RO',
    'RR',
    'SC',
    'SP',
    'SE',
    'TO',
  ];

  List<CityModel> cidades = [];

  CityModel? cidadeSelecionada;

  WeatherModel? clima;

  bool carregando = false;

  String estadoSelecionado = "";

  @override
  void initState() {
    super.initState();
    _buscarClimaAtual();
  }

  Future<void> _buscarClimaAtual() async {
    try {
      final local = await DatabaseRepository().buscarLocalizacao();

      if (local == null) return;

      final resultado = await WeatherService.buscarClima(
        latitude: local.latitude,
        longitude: local.longitude,
      );

      setState(() {
        clima = resultado;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _carregarCidades(String uf) async {
    setState(() {
      carregando = true;
      cidades.clear();
      cidadeSelecionada = null;
    });

    try {
      cidades = await CityService.fetchCityByState(uf);
    } catch (e) {
      debugPrint(e.toString());
    }

    setState(() {
      carregando = false;
    });
  }

  Future<void> _buscarCidade() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      carregando = true;
    });

    try {
      final weather = await WeatherService.buscarPorCidade(
        cidade: cidadeSelecionada!.nome!,
        estado: estadoSelecionado,
      );

      setState(() {
        clima = weather;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }

    setState(() {
      carregando = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Previsão do Tempo"),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Estado",
                  border: OutlineInputBorder(),
                ),
                value: estadoSelecionado.isEmpty ? null : estadoSelecionado,
                items: estados.map((estado) {
                  return DropdownMenuItem(
                    value: estado,
                    child: Text(estado),
                  );
                }).toList(),
                onChanged: (valor) {
                  if (valor == null) return;

                  estadoSelecionado = valor;
                  _carregarCidades(valor);
                },
              ),

              const SizedBox(height: 16),

              Autocomplete<CityModel>(
                displayStringForOption: (cidade) => cidade.nome ?? "",

                optionsBuilder: (textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return cidades;
                  }

                  return cidades.where(
                    (cidade) => cidade.nome!
                        .toLowerCase()
                        .contains(textEditingValue.text.toLowerCase()),
                  );
                },

                onSelected: (cidade) {
                  cidadeSelecionada = cidade;
                },

                fieldViewBuilder: (
                  context,
                  controller,
                  focusNode,
                  onSubmitted,
                ) {
                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      labelText: "Cidade",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (cidadeSelecionada == null) {
                        return "Selecione uma cidade";
                      }
                      return null;
                    },
                  );
                },
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: carregando ? null : _buscarCidade,
                child: const Text("Buscar"),
              ),

              const SizedBox(height: 30),

              if (carregando)
                const Center(
                  child: CircularProgressIndicator(),
                ),

              if (clima != null)
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [

                        const Text(
                          "Previsão do Tempo",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 25),

                        ListTile(
                          leading: const Icon(Icons.thermostat),
                          title: const Text("Temperatura"),
                          trailing:
                              Text("${clima!.temperatura!.toStringAsFixed(1)} °C"),
                        ),

                        ListTile(
                          leading: const Icon(Icons.air),
                          title: const Text("Velocidade do vento"),
                          trailing: Text(
                            "${clima!.velocidadeVento!.toStringAsFixed(1)} km/h",
                          ),
                        ),

                        ListTile(
                          leading: const Icon(Icons.water_drop),
                          title: const Text("Umidade"),
                          trailing: Text("${clima!.umidade}%"),
                        ),

                        ListTile(
                          leading: const Icon(Icons.arrow_downward),
                          title: const Text("Temperatura mínima"),
                          trailing: Text(
                            "${clima!.temperaturaMinima!.toStringAsFixed(1)} °C",
                          ),
                        ),

                        ListTile(
                          leading: const Icon(Icons.arrow_upward),
                          title: const Text("Temperatura máxima"),
                          trailing: Text(
                            "${clima!.temperaturaMaxima!.toStringAsFixed(1)} °C",
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
