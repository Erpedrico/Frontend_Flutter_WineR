import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  // Variables para almacenar la respuesta seleccionada para cada pregunta
  int? selectedOptionQuestion1;
  int? selectedOptionQuestion2;
  int? selectedOptionQuestion3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[300],
      appBar: AppBar(
        backgroundColor: Colors.red[300],
        elevation: 0,
        title: Text(
          'Quiz',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pregunta 1
              Text(
                "Si tu vida fuera una película, ¿qué género sería?",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              SizedBox(height: 10),
              OptionButton(
                text: "Comedia",
                index: 0,
                selectedOption: selectedOptionQuestion1,
                onTap: () {
                  setState(() {
                    selectedOptionQuestion1 = 0;
                  });
                },
              ),
              OptionButton(
                text: "Romance",
                index: 1,
                selectedOption: selectedOptionQuestion1,
                onTap: () {
                  setState(() {
                    selectedOptionQuestion1 = 1;
                  });
                },
              ),
              OptionButton(
                text: "Misterio",
                index: 2,
                selectedOption: selectedOptionQuestion1,
                onTap: () {
                  setState(() {
                    selectedOptionQuestion1 = 2;
                  });
                },
              ),
              OptionButton(
                text: "Drama",
                index: 3,
                selectedOption: selectedOptionQuestion1,
                onTap: () {
                  setState(() {
                    selectedOptionQuestion1 = 3;
                  });
                },
              ),
              SizedBox(height: 20),

              // Pregunta 2
              Text(
                "Describe tu vino ideal...",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              SizedBox(height: 10),
              OptionButton(
                text: "Generoso",
                index: 0,
                selectedOption: selectedOptionQuestion2,
                onTap: () {
                  setState(() {
                    selectedOptionQuestion2 = 0;
                  });
                },
              ),
              OptionButton(
                text: "Ambicioso",
                index: 1,
                selectedOption: selectedOptionQuestion2,
                onTap: () {
                  setState(() {
                    selectedOptionQuestion2 = 1;
                  });
                },
              ),
              OptionButton(
                text: "Audaz",
                index: 2,
                selectedOption: selectedOptionQuestion2,
                onTap: () {
                  setState(() {
                    selectedOptionQuestion2 = 2;
                  });
                },
              ),
              OptionButton(
                text: "Elegante",
                index: 3,
                selectedOption: selectedOptionQuestion2,
                onTap: () {
                  setState(() {
                    selectedOptionQuestion2 = 3;
                  });
                },
              ),
              SizedBox(height: 20),

              // Pregunta 3
              Text(
                "¿Qué te emociona más sobre tu viaje con el vino?",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              SizedBox(height: 10),
              OptionButton(
                text: "Combinar vino con buena comida",
                index: 0,
                selectedOption: selectedOptionQuestion3,
                onTap: () {
                  setState(() {
                    selectedOptionQuestion3 = 0;
                  });
                },
              ),
              OptionButton(
                text: "Compartir vino con otros",
                index: 1,
                selectedOption: selectedOptionQuestion3,
                onTap: () {
                  setState(() {
                    selectedOptionQuestion3 = 1;
                  });
                },
              ),
              OptionButton(
                text: "Desarrollar una nueva habilidad",
                index: 2,
                selectedOption: selectedOptionQuestion3,
                onTap: () {
                  setState(() {
                    selectedOptionQuestion3 = 2;
                  });
                },
              ),
              OptionButton(
                text: "Conocer nuevas personas",
                index: 3,
                selectedOption: selectedOptionQuestion3,
                onTap: () {
                  setState(() {
                    selectedOptionQuestion3 = 3;
                  });
                },
              ),
              SizedBox(height: 20),

              // Botón Finalizar
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  ),
                  onPressed: () {
                    // Navegar a la página principal usando GetX
                    Get.offNamed('/main');
                  },
                  child: Text(
                    "Finalizar",
                    style: TextStyle(fontSize: 16),
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

// Widget reutilizable para los botones de opciones
class OptionButton extends StatelessWidget {
  final String text;
  final int index;
  final int? selectedOption;
  final VoidCallback onTap;

  OptionButton({
    required this.text,
    required this.index,
    required this.selectedOption,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == selectedOption;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.yellow[800] : Colors.yellow[700],
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: Colors.brown, width: 2)
              : Border.all(color: Colors.transparent),
        ),
        padding: EdgeInsets.symmetric(vertical: 15),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: isSelected ? Colors.brown[900] : Colors.brown[800],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

