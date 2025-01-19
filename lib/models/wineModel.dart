class WineModel {
  String? id;
  String owner;
  String name;
  double price;
  String color;
  String brand;
  String grapetype;
  bool habilitado;
  List<Note> notes;
  String experience;
  int year;
  String? image;

  WineModel({
    this.id,
    required this.owner,
    required this.name,
    required this.price,
    required this.color,
    required this.brand,
    required this.grapetype,
    required this.habilitado,
    required this.notes,
    required this.experience,
    required this.year,
    this.image,
  });

  factory WineModel.fromJson(Map<String, dynamic> json) {
    return WineModel(
      id: json['_id'],
      owner: json['owner'],
      name: json['name'],
      price: json['price'].toDouble(),
      color: json['color'],
      brand: json['brand'],
      grapetype: json['grapetype'],
      habilitado: json['habilitado'],
      notes: (json['notes'] as List).map((note) => Note.fromJson(note)).toList(),
      experience: json['experience'],
      year: json['year'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'owner': owner,
      'name': name,
      'price': price,
      'color': color,
      'brand': brand,
      'grapetype': grapetype,
      'habilitado': habilitado,
      'notes': notes.map((note) => note.toJson()).toList(),
      'experience': experience,
      'year': year,
      'image': image,
    };
  }
}

class Note {
  String icon;
  String label;

  Note({
    required this.icon,
    required this.label,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      icon: json['icon'],
      label: json['label'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'icon': icon,
      'label': label,
    };
  }
}