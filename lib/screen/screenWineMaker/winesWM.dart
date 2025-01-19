import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/userModel.dart';
import 'package:provider/provider.dart';
import '../../models/wineModel.dart';
import '../../models/experienceModel.dart';
import '../../services/wineService.dart';
import '../../services/experienceService.dart';
import '../../providers/perfilProvider.dart';
import '../../widgets/wineCardWM.dart';

class WineWMPage extends StatefulWidget {
  @override
  _WineWMPageState createState() => _WineWMPageState();
}

class _WineWMPageState extends State<WineWMPage> {
  bool _isLoading = true;
  List<WineModel> _wines = [];
  List<ExperienceModel> _experiences = [];
  final WineService _wineService = WineService();
  final ExperienceService _experienceService = ExperienceService();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _grapetypeController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  ExperienceModel? _selectedExperience;
  bool _habilitado = true;
  List<Note> _notes = [];

  final List<Map<String, String>> noteOptions = [
    { "icon": "🍓", "label": "Fruity" },
    { "icon": "🌸", "label": "Floral" },
    { "icon": "🫛", "label": "Vegetable" },
    { "icon": "🫚", "label": "Spiced" },
    { "icon": "🐴", "label": "Animal" },
    { "icon": "🌰", "label": "Toasted" },
  ];

  @override
  void initState() {
    super.initState();
    _loadWines();
    _loadExperiences();
  }

  Future<void> _loadWines() async {
    setState(() {
      _isLoading = true;
    });

    final perfilProvider = Provider.of<PerfilProvider>(context, listen: false);
    UserModel? perfil = perfilProvider.perfilUsuario;
    String? ownerId = perfil?.id;

    if (ownerId != null) {
      try {
        final wines = await _wineService.getWinesByOwner(context, ownerId);
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
  }

  Future<void> _loadExperiences() async {
    final perfilProvider = Provider.of<PerfilProvider>(context, listen: false);
    UserModel? perfil = perfilProvider.perfilUsuario;
    String? ownerId = perfil?.id;

    if (ownerId != null) {
      try {
        final experiences = await _experienceService.getExperiencesByOwner(ownerId);
        setState(() {
          _experiences = experiences;
        });
      } catch (e) {
        print('Error al cargar las experiencias: $e');
      }
    }
  }

  Future<void> _createWine() async {
    if (_formKey.currentState!.validate()) {
      final perfilProvider = Provider.of<PerfilProvider>(context, listen: false);
      UserModel? perfil = perfilProvider.perfilUsuario;
      String? ownerId = perfil?.id;

      if (ownerId != null && _selectedExperience != null) {
        final newWine = WineModel(
          owner: ownerId,
          name: _nameController.text,
          price: double.parse(_priceController.text),
          color: _colorController.text,
          brand: _brandController.text,
          grapetype: _grapetypeController.text,
          habilitado: _habilitado,
          notes: _notes,
          experience: _selectedExperience!.id!,
          year: int.parse(_yearController.text),
          image: _imageController.text,
        );

        try {
          await _wineService.createWine(context, newWine);
          _loadWines(); // Recargar la lista de vinos
        } catch (e) {
          print('Error al crear el vino: $e');
        }
      }
    }
  }

  void _showCreateWineForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                    ),
                    TextField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Precio'),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: _colorController,
                      decoration: const InputDecoration(labelText: 'Color'),
                    ),
                    TextField(
                      controller: _brandController,
                      decoration: const InputDecoration(labelText: 'Marca'),
                    ),
                    TextField(
                      controller: _grapetypeController,
                      decoration: const InputDecoration(labelText: 'Tipo de uva'),
                    ),
                    DropdownButtonFormField<ExperienceModel>(
                      decoration: const InputDecoration(labelText: 'Experiencia'),
                      items: _experiences.map((experience) {
                        return DropdownMenuItem<ExperienceModel>(
                          value: experience,
                          child: Text(experience.title ?? 'Sin título'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedExperience = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Por favor seleccione una experiencia';
                        }
                        return null;
                      },
                    ),
                    TextField(
                      controller: _imageController,
                      decoration: const InputDecoration(labelText: 'Imagen (URL)'),
                    ),
                    TextField(
                      controller: _yearController,
                      decoration: const InputDecoration(labelText: 'Año de producción'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    const Text('Notas:'),
                    ...noteOptions.map((note) {
                      return CheckboxListTile(
                        title: Text('${note["icon"]} ${note["label"]}'),
                        value: _notes.any((n) => n.label == note["label"]),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              _notes.add(Note(
                                icon: note["icon"]!,
                                label: note["label"]!,
                              ));
                            } else {
                              _notes.removeWhere((n) => n.label == note["label"]);
                            }
                          });
                        },
                      );
                    }).toList(),
                    SwitchListTile(
                      title: const Text('Habilitado'),
                      value: _habilitado,
                      onChanged: (value) {
                        setState(() {
                          _habilitado = value;
                        });
                      },
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _createWine();
                        Navigator.pop(context);
                      },
                      child: const Text('Crear Vino'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFa43d4e),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Vinos'),
        backgroundColor: Color(0xFFa43d4e),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showCreateWineForm,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              color: Color(0xFF6f2733),
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: _wines.length,
                itemBuilder: (context, index) {
                  return WineCardWM(wine: _wines[index]);
                },
              ),
            ),
    );
  }
}