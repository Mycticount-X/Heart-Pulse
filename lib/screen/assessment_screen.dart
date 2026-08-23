import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'result_screen.dart';

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controller untuk input text
  final _ageCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _apHiCtrl = TextEditingController();
  final _apLoCtrl = TextEditingController();

  // Variabel untuk Dropdown/Toggle
  int _gender = 1;
  int _cholesterol = 1;
  int _gluc = 1;
  int _smoke = 0;
  int _alco = 0;
  int _active = 1;

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

    // Konversi usia tahun ke hari
    int ageDays = int.parse(_ageCtrl.text) * 365;

    final requestData = {
      "age_days": ageDays,
      "gender": _gender,
      "height": double.parse(_heightCtrl.text),
      "weight": double.parse(_weightCtrl.text),
      "ap_hi": double.parse(_apHiCtrl.text),
      "ap_lo": double.parse(_apLoCtrl.text),
      "cholesterol": _cholesterol,
      "gluc": _gluc,
      "smoke": _smoke,
      "alco": _alco,
      "active": _active
    };

    try {
      final url = Uri.parse('https://heart-pulse-api.vercel.app/predict'); 
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultScreen(resultData: result),
            ),
          );
        }
      } else {
        _showError("Gagal menganalisis. Kode: ${response.statusCode}");
      }
    } catch (e) {
      _showError("Terjadi kesalahan koneksi jaringan.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Health Assessment")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            TextFormField(
              controller: _ageCtrl,
              decoration: const InputDecoration(labelText: "Usia (Tahun)", border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _heightCtrl,
                    decoration: const InputDecoration(labelText: "Tinggi (cm)", border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _weightCtrl,
                    decoration: const InputDecoration(labelText: "Berat (kg)", border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _apHiCtrl,
                    decoration: const InputDecoration(labelText: "Sistolik (cth: 120)", border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _apLoCtrl,
                    decoration: const InputDecoration(labelText: "Diastolik (cth: 80)", border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitData,
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Analisis Risiko"),
              ),
            )
          ],
        ),
      ),
    );
  }
}