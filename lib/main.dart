import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
    theme: ThemeData(
      appBarTheme: AppBarTheme(
        color: Color.fromARGB(255, 73, 22, 92), // Set the app bar background color
      ),
      primarySwatch: Colors.purple, // Set the primary color for the calendar
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
  Map<DateTime, List<dynamic>> events = {};

  void _onDaySelected(DateTime day, DateTime focusedDay) {
    setState(() {
      today = day;
    });

    events[day] = events[day] ?? [];
  }

  void _addEventDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        String eventText = '';

        return AlertDialog(
          title: Text('Add Event'),
          content: TextField(
            onChanged: (value) {
              eventText = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  if (eventText.isNotEmpty) {
                    events[today]?.add(eventText);
                  }
                  Navigator.pop(context);
                });
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
            color: Colors.white, // Set the app bar text color
          ),
        ),
      ),
      body: content(),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FloatingActionButton(
          onPressed: () => _addEventDialog(context),
          child: Icon(Icons.add),
          backgroundColor: Color.fromARGB(255, 73, 22, 92), // Set the FloatingActionButton color
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
                    onPressed: () {
                      setState(() {
                        events[today]!.remove(event);
                      });
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
