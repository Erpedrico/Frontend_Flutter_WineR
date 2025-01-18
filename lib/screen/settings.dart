import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/providers/settings_provider.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Adjust Settings',
            style: TextStyle(fontSize: settings.fontSize),
          ),
          SizedBox(height: 20),
          Text('Font Size: ${settings.fontSize.toInt()}'),
          Slider(
            value: settings.fontSize,
            min: 12.0,
            max: 32.0,
            onChanged: (value) {
              settings.setFontSize(value);
            },
          ),
          SizedBox(height: 20),
          Text('Background Color'),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => settings.setBackgroundColor(Colors.white),
                child: Text('White'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => settings.setBackgroundColor(Colors.blue),
                child: Text('Blue'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => settings.setBackgroundColor(Colors.purple),
                child: Text('Purple'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


