import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
    theme: ThemeData(
      appBarTheme: AppBarTheme(
        color: Color.fromARGB(255, 73, 22, 92),
      ),
      primarySwatch: Colors.purple,
    ),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DateTime today = DateTime.now();
  Map<DateTime, List<String>> events = {};

  @override
  void initState() {
    super.initState();
    _loadEventsFromStorage();
  }

  void _loadEventsFromStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      events.clear(); // Clear the existing events map
      for (String key in prefs.getKeys()) {
        DateTime day = DateTime.parse(key);
        List<String>? storedEvents = prefs.getStringList(key);
        if (storedEvents != null) {
          events[day] = storedEvents;
        }
      }
    });
  }

  void _saveEventsToStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    for (DateTime day in events.keys) {
      await prefs.setStringList(day.toString(), events[day] ?? []);
    }
  }

  void _onDaySelected(DateTime day, DateTime focusedDay) {
    setState(() {
      today = day;
    });

    events[day] = events[day] ?? [];

    // Call _saveEventsToStorage to save all events
    _saveEventsToStorage();
  }

  void _addEventDialog(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String eventText = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Event'),
          content: TextField(
            onChanged: (value) {
              eventText = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (eventText.isNotEmpty) {
                  setState(() {
                    events[today]?.add(eventText);
                  });

                  await prefs.setStringList(
                    today.toString(),
                    events[today] ?? [],
                  );

                  // Call _saveEventsToStorage to save all events
                  _saveEventsToStorage();
                }
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Calendar",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: content(),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FloatingActionButton(
          onPressed: () => _addEventDialog(context),
          child: Icon(Icons.add),
          backgroundColor: Color.fromARGB(255, 73, 22, 92),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget content() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Text(
            "Selected Day  " + today.toString().split(" ")[0],
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            child: TableCalendar(
              locale: "en_US",
              rowHeight: 43,
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              availableGestures: AvailableGestures.all,
              selectedDayPredicate: (day) => isSameDay(day, today),
              focusedDay: today,
              firstDay: DateTime.utc(2010, 09, 14),
              lastDay: DateTime.utc(2030, 09, 14),
              onDaySelected: _onDaySelected,
              eventLoader: (day) => events[day] ?? [],
            ),
          ),
          if (events[today]?.isNotEmpty ?? false)
            Column(
              children: events[today]!.map((event) {
                return ListTile(
                  title: Text(event.toString()),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      setState(() {
                        events[today]!.remove(event);
                      });

                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.setStringList(
                        today.toString(),
                        events[today] ?? [],
                      );

                      _saveEventsToStorage();
                    },
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
