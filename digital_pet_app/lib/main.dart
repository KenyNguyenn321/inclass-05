import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: DigitalPetApp(),
  ));
}

class DigitalPetApp extends StatefulWidget {
  @override
  _DigitalPetAppState createState() => _DigitalPetAppState();
}

class _DigitalPetAppState extends State<DigitalPetApp> {
  String petName = "Your Pet";
  int happinessLevel = 50;
  int hungerLevel = 50;

  final TextEditingController _nameController = TextEditingController();
  Timer? _hungerTimer;

  DateTime? _winStartTime;
  bool _gameEnded = false;

  int energyLevel = 50;

  Color _moodColor(int happinessLevel) {
    if (happinessLevel > 70) {
      return Colors.green;
    } else if (happinessLevel >= 30) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }

  String _moodText(int happinessLevel) {
    if (happinessLevel > 70) {
      return "Happy";
    } else if (happinessLevel >= 30) {
      return "Neutral";
    } else {
      return "Unhappy";
    }
  }

  String _moodEmoji(int happinessLevel) {
    if (happinessLevel > 70) {
      return ":)";
    } else if (happinessLevel >= 30) {
      return ":|";
    } else {
      return ":(";
    }
  }

  void _playWithPet() {
    if (_gameEnded) return;

    setState(() {
      happinessLevel += 10;
      if (happinessLevel > 100) happinessLevel = 100;
      _updateHunger();
    });

    _checkWinLoss();
  }

  void _feedPet() {
    if (_gameEnded) return;

    setState(() {
      hungerLevel -= 10;
      if (hungerLevel < 0) hungerLevel = 0;
      _updateHappiness();
      if (happinessLevel > 100) happinessLevel = 100;
      if (happinessLevel < 0) happinessLevel = 0;
    });

    _checkWinLoss();
  }

  void _updateHappiness() {
    if (hungerLevel < 30) {
      happinessLevel -= 20;
      if (happinessLevel < 0) happinessLevel = 0;
    } else {
      happinessLevel += 10;
      if (happinessLevel > 100) happinessLevel = 100;
    }
  }

  void _updateHunger() {
    setState(() {
      hungerLevel += 5;
      if (hungerLevel > 100) {
        hungerLevel = 100;
        happinessLevel -= 20;
        if (happinessLevel < 0) happinessLevel = 0;
      }
    });
  }

  void _checkWinLoss() {
    if (_gameEnded) return;

    if (hungerLevel >= 100 && happinessLevel <= 10) {
      _endGame("Game Over", "Your pet is too hungry and too unhappy.");
      return;
    }

    if (happinessLevel > 80) {
      _winStartTime ??= DateTime.now();
      final elapsed = DateTime.now().difference(_winStartTime!);
      if (elapsed.inMinutes >= 3) {
        _endGame("You Win", "Your pet stayed very happy for 3 minutes.");
      }
    } else {
      _winStartTime = null;
    }
  }

  void _endGame(String title, String message) {
    _gameEnded = true;
    _hungerTimer?.cancel();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    _hungerTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (_gameEnded) return;
      _updateHunger();
      _checkWinLoss();
    });
  }

  @override
  void dispose() {
    _hungerTimer?.cancel();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Digital Pet'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Enter pet name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _gameEnded
                          ? null
                          : () {
                              setState(() {
                                final txt = _nameController.text.trim();
                                if (txt.isNotEmpty) {
                                  petName = txt;
                                  _nameController.clear();
                                }
                              });
                            },
                      child: Text('Set'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.0),
              Text('Name: $petName', style: TextStyle(fontSize: 20.0)),
              SizedBox(height: 16.0),
              ColorFiltered(
                colorFilter: ColorFilter.mode(
                  _moodColor(happinessLevel),
                  BlendMode.modulate,
                ),
                child: Image.asset(
                  'assets/pet_image.png',
                  width: 250,
                  height: 250,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'Mood: ${_moodText(happinessLevel)} ${_moodEmoji(happinessLevel)}',
                style: TextStyle(fontSize: 20.0),
              ),
              SizedBox(height: 16.0),
              Text('Energy Level: $energyLevel',
                  style: TextStyle(fontSize: 20.0)),
              SizedBox(height: 8.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: LinearProgressIndicator(
                  value: energyLevel / 100,
                  minHeight: 12,
                ),
              ),
              SizedBox(height: 16.0),
              Text('Happiness Level: $happinessLevel',
                  style: TextStyle(fontSize: 20.0)),
              SizedBox(height: 16.0),
              Text('Hunger Level: $hungerLevel',
                  style: TextStyle(fontSize: 20.0)),
              SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: _gameEnded ? null : _playWithPet,
                child: Text('Play with Your Pet'),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _gameEnded ? null : _feedPet,
                child: Text('Feed Your Pet'),
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
