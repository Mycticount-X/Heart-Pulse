import 'package:flutter/material.dart';

import 'screen/assessment_screen.dart';

void main() {
	runApp(const HeartPulseApp());
}

class HeartPulseApp extends StatelessWidget {
	const HeartPulseApp({super.key});

	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			title: 'Heart Pulse',
			theme: ThemeData(
				colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
				useMaterial3: true,
			),
			home: const AssessmentScreen(),
		);
	}
}
