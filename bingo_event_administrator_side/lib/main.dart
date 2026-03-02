import 'package:flutter/material.dart';

void main() {
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bingo Admin App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AdminHomePage(),
    );
  }
}

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Events'),
              Tab(text: 'Welcome Pages'),
              Tab(text: 'Bingo Boards'),
              Tab(text: 'Mini-Games'),
              Tab(text: 'Feedback'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            EventsTab(),
            WelcomePageTab(),
            BingoBoardsTab(),
            MiniGamesTab(),
            FeedbackTab(),
          ],
        ),
      ),
    );
  }
}

class EventsTab extends StatelessWidget {
  const EventsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: 5, // Placeholder for event count
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Event Package ${index + 1}'),
                  subtitle: Text('Details about Event ${index + 1}'),
                  onTap: () {
                    // Navigate to event details
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NewEventPage(),
                  ),
                );
              },
              child: const Text('Create New Event'),
            ),
          ),
        ],
      ),
    );
  }
}

class NewEventPage extends StatelessWidget {
  const NewEventPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Event Name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Creator Name',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              items: const [
                DropdownMenuItem(value: 'Welcome Page 1', child: Text('Welcome Page 1')),
                DropdownMenuItem(value: 'Welcome Page 2', child: Text('Welcome Page 2')),
              ],
              onChanged: (value) {},
              decoration: const InputDecoration(
                labelText: 'Select Welcome Page',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              items: const [
                DropdownMenuItem(value: 'Bingo Board 1', child: Text('Bingo Board 1')),
                DropdownMenuItem(value: 'Bingo Board 2', child: Text('Bingo Board 2')),
              ],
              onChanged: (value) {},
              decoration: const InputDecoration(
                labelText: 'Select Bingo Board',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Save event logic
              },
              child: const Text('Save Event'),
            ),
          ],
        ),
      ),
    );
  }
}

class WelcomePageTab extends StatelessWidget {
  const WelcomePageTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: 5, // Placeholder for the number of welcome pages
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Welcome Page ${index + 1}'),
                  subtitle: Text('Welcome message for page ${index + 1}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      // Delete welcome page logic
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NewWelcomePageForm(),
                  ),
                );
              },
              child: const Text('Create New Welcome Page'),
            ),
          ),
        ],
      ),
    );
  }
}

class NewWelcomePageForm extends StatelessWidget {
  const NewWelcomePageForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Welcome Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Welcome Page Name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Welcome Message',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Save welcome page logic
              },
              child: const Text('Save Welcome Page'),
            ),
          ],
        ),
      ),
    );
  }
}

class BingoBoardsTab extends StatelessWidget {
  const BingoBoardsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: 5, // Placeholder for the number of bingo boards
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Bingo Board ${index + 1}'),
                  subtitle: Text('Details for board ${index + 1}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      // Delete bingo board logic
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NewBingoBoardForm(),
                  ),
                );
              },
              child: const Text('Create New Bingo Board'),
            ),
          ),
        ],
      ),
    );
  }
}

class NewBingoBoardForm extends StatelessWidget {
  const NewBingoBoardForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Bingo Board'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Bingo Board Name',
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5, // 5x5 grid
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: 25, // Total number of boxes
                itemBuilder: (context, index) {
                  return TextField(
                    decoration: InputDecoration(
                      labelText: 'Box ${index + 1}',
                      border: const OutlineInputBorder(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Save bingo board logic
              },
              child: const Text('Save Bingo Board'),
            ),
          ],
        ),
      ),
    );
  }
}

class MiniGamesTab extends StatelessWidget {
  const MiniGamesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: 4, // Placeholder for the number of mini-games
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Game ${index + 1}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MiniGamePage(gameName: 'Game ${index + 1}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class MiniGamePage extends StatelessWidget {
  final String gameName;

  const MiniGamePage({super.key, required this.gameName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(gameName),
      ),
      body: const Center(
        child: Text('Mini-game content goes here.'),
      ),
    );
  }
}

class FeedbackTab extends StatelessWidget {
  const FeedbackTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              items: const [
                DropdownMenuItem(value: 'Event 1', child: Text('Event 1')),
                DropdownMenuItem(value: 'Event 2', child: Text('Event 2')),
              ],
              onChanged: (value) {},
              decoration: const InputDecoration(
                labelText: 'Select Event',
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: 5, // Placeholder for feedback count
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Feedback ${index + 1} for the selected event.'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NewFeedbackForm extends StatelessWidget {
  const NewFeedbackForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Feedback'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Feedback Name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Feedback Message',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Save feedback logic
              },
              child: const Text('Save Feedback'),
            ),
          ],
        ),
      ),
    );
  }
}
