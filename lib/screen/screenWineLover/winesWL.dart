import 'package:flutter/material.dart';
import '../../models/wineModel.dart';
import '../../services/wineService.dart';
import '../../widgets/wineCardWL.dart';

class WinesWLPage extends StatefulWidget {
  @override
  _WinesWLPageState createState() => _WinesWLPageState();
}

class _WinesWLPageState extends State<WinesWLPage> {
  bool _isLoading = true;
  List<WineModel> _wines = [];
  final WineService _wineService = WineService();

  @override
  void initState() {
    super.initState();
    _loadWines();
  }

  Future<void> _loadWines() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final wines = await _wineService.getAllWines(context);
      setState(() {
        _wines = wines;
      });
    } catch (e) {
      print('Error al cargar los vinos: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todos los Vinos'),
        backgroundColor: Color(0xFFa43d4e),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              color: Color(0xFF6f2733),
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: _wines.length,
                itemBuilder: (context, index) {
                  return WineCardWL(wine: _wines[index]);
                },
              ),
            ),
    );
  }
}