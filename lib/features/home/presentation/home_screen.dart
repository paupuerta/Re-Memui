import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:re_mem_ui/features/cards/domain/entities/card.dart'
    as entities;

/// Home screen – entry point for the app.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ReMem'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to ReMem',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your language learning companion',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            FilledButton.icon(
              onPressed: () {
                // Demo card for testing
                const demoCard = entities.Card(
                  id: '123e4567-e89b-12d3-a456-426614174000',
                  userId: '123e4567-e89b-12d3-a456-426614174001',
                  question: 'What is "hello" in Spanish?',
                  answer: 'hola',
                );

                context.pushNamed(
                  'review',
                  extra: {
                    'card': demoCard,
                    'userId': demoCard.userId,
                  },
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Try Demo Review'),
              style: FilledButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

