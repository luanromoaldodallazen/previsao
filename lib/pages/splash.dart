import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:previsao_tempo/models/location_model.dart';
import 'package:previsao_tempo/pages/home.dart';
import 'package:previsao_tempo/repository/database_repository.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    _iniciarAplicacao();
  }

  Future<void> _iniciarAplicacao() async {
    try {
      Position position = await _obterLocalizacao();

      await DatabaseRepository().salvarLocalizacao(
        LocationModel(
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      );
    } catch (e) {
      debugPrint("Erro ao obter localização: $e");
    }

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const Home(),
      ),
    );
  }

  Future<Position> _obterLocalizacao() async {
    bool servicoAtivo = await Geolocator.isLocationServiceEnabled();

    if (!servicoAtivo) {
      throw Exception("Serviço de localização desativado.");
    }

    LocationPermission permissao = await Geolocator.checkPermission();

    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
    }

    if (permissao == LocationPermission.denied) {
      throw Exception("Permissão negada.");
    }

    if (permissao == LocationPermission.deniedForever) {
      throw Exception("Permissão negada permanentemente.");
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Container(
          color: Colors.white,
          child: Center(
            child: Image.asset(
              "assets/images/meteorology.png",
              height: 90,
            ),
          ),
        ),
      ),
    );
  }
}
