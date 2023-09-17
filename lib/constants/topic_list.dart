import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

List<Map<String, String>> getTopics() {
  
  final List<Map<String, String>> topics = [
    {
    'title': 'Talking to someone for the first time.',
    'content': 'You (assistant) are a stranger meeting me (the user) for the first time. The user who is not very proficent it the relevant langauge will respond.',
    'icon': 'assets/wave.png'
    },
    {
    'title': 'Speak to language teacher for the first time.',
    'content': 'You (assistant) should act like a langauge teacher meeting me (the user) one-on-one for the first time. The user will respond as the pupil.',
    'icon': 'assets/teach.png'
    },
    {
    'title': 'Buying groceries at a store.',
    'content': 'You (assistant) should act like a shop clerk. I (the user) will respond as the customer.',
    'icon': 'assets/shopping-cart.png'
    },
    {
    'title': 'Asking a question at a restaurant.',
    'content': 'You (assistant) are a Waiter in a restaurant, I (the user) will respond as the customer.',
    'icon': 'assets/food.png'
    },
    {
    'title': 'Ask for directions for a train station.',
    'content': 'You (assistant) are a normal \$language person, I (the user) is looking for a train station, ask if I am lost.',
    'icon': 'assets/train.png'
    },
    {
    'title': 'Lost your key for the hotel room.',
    'content': 'You (assistant) are a Hotel Receptionist, I (the user) will respond as the guest who has lost their room key.',
    'icon': 'assets/key-chain.png'
    },
    {
    'title': 'You missed your flight.',
    'content': 'You (assistant) are an Airline Check-in Agent, I (the user) will respond as a Traveler who missed their flight.',
    'icon': 'assets/airplane.png'
    },
    {
    'title': 'What is your favorite movie/tv show?',
    'content': 'You (assistant) will ask me about their favorite movie/tv show, I (the user) will respond.',
    'icon': 'assets/watching-a-movie.png'
    },
    {
    'title': 'Arrived late for a Job Interview.',
    'content': 'You (assistant) are a Job Interviewer, I (the user) will respond as a Candidate who arrived late.',
    'icon': 'assets/interview.png'
    },
    {
    'title': 'You are alone at a bar and start talking to the host.',
    'content': 'You (assistant) are a Party Host, I (the user) will respond as a Guest who doesn\'t know anyone at the party.',
    'icon': 'assets/bar.png'
    },
    {
    'title': 'Ask another camper to borrow something you forgot.',
    'content': 'You (assistant) are a Camping Guide, I (the user) will respond as a Camper who forgot essential supplies.',
    'icon': 'assets/camping.png'
    }
  ];

  return topics;
}