import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'result_screen.dart';
import '../services/history_services.dart';

class AssessmentScreen extends StatefulWidget {
  final VoidCallback? onGoToSimulation;

  const AssessmentScreen({super.key, this.onGoToSimulation});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  Map<String, dynamic>? _resultData;

  final _ageCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _apHiCtrl = TextEditingController(text: "120");
  final _apLoCtrl = TextEditingController(text: "80");

  int _gender = 1;
  int _cholesterol = 1;
  int _gluc = 1;
  int _smoke = 0;
  int _alco = 0;
  int _active = 1;

  @override
  void dispose() {
    _ageCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _apHiCtrl.dispose();
    _apLoCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

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
      "active": _active,
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
        await HistoryService.saveHistory(requestData, result);

        if (mounted) {
          setState(() => _resultData = result);
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_resultData != null) {
      return ResultScreen(
        resultData: _resultData!,
        onRecheck: () => setState(() => _resultData = null),
        onSimulate: () => widget.onGoToSimulation?.call(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Health Assessment",
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            _buildIntro(colorScheme),
            const SizedBox(height: 24),

            // --- BAGIAN 1: DATA FISIK ---
            _buildSectionTitle(
              "01",
              "Data Fisik",
              "Profil dasar untuk memulai analisis",
              Icons.person_outline,
            ),
            _buildSectionCard(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildLabelAndInput(
                            "Usia (Tahun)",
                            TextFormField(
                              controller: _ageCtrl,
                              decoration: _inputDecoration(
                                Icons.cake_outlined,
                                hint: "Cth: 20",
                              ),
                              keyboardType: TextInputType.number,
                              validator: (val) => val!.isEmpty ? 'Wajib' : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildLabelAndInput(
                            "Gender",
                            DropdownButtonFormField<int>(
                              value: _gender,
                              isExpanded:
                                  true, // Mencegah overflow pada dropdown
                              decoration: _inputDecoration(Icons.wc_outlined),
                              items: const [
                                DropdownMenuItem(
                                  value: 1,
                                  child: Text("Wanita"),
                                ),
                                DropdownMenuItem(value: 2, child: Text("Pria")),
                              ],
                              onChanged: (val) =>
                                  setState(() => _gender = val!),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildLabelAndInput(
                            "Tinggi (cm)",
                            TextFormField(
                              controller: _heightCtrl,
                              decoration: _inputDecoration(
                                Icons.height,
                                hint: "165",
                              ),
                              keyboardType: TextInputType.number,
                              validator: (val) => val!.isEmpty ? 'Wajib' : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildLabelAndInput(
                            "Berat (kg)",
                            TextFormField(
                              controller: _weightCtrl,
                              decoration: _inputDecoration(
                                Icons.monitor_weight_outlined,
                                hint: "60",
                              ),
                              keyboardType: TextInputType.number,
                              validator: (val) => val!.isEmpty ? 'Wajib' : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- BAGIAN 2: METRIK KLINIS ---
            _buildSectionTitle(
              "02",
              "Metrik Klinis",
              "Nilai kesehatan yang terukur",
              Icons.monitor_heart_outlined,
            ),
            _buildSectionCard(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildLabelAndInput(
                            "Sistolik",
                            TextFormField(
                              controller: _apHiCtrl,
                              decoration: _inputDecoration(
                                Icons.arrow_upward,
                                hint: "120",
                                suffix: "mmHg",
                              ),
                              keyboardType: TextInputType.number,
                              validator: (val) => val!.isEmpty ? 'Wajib' : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildLabelAndInput(
                            "Diastolik",
                            TextFormField(
                              controller: _apLoCtrl,
                              decoration: _inputDecoration(
                                Icons.arrow_downward,
                                hint: "80",
                                suffix: "mmHg",
                              ),
                              keyboardType: TextInputType.number,
                              validator: (val) => val!.isEmpty ? 'Wajib' : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildLabelAndInput(
                      "Level Kolesterol",
                      DropdownButtonFormField<int>(
                        value: _cholesterol,
                        isExpanded: true,
                        decoration: _inputDecoration(Icons.water_drop_outlined),
                        items: const [
                          DropdownMenuItem(value: 1, child: Text("Normal")),
                          DropdownMenuItem(
                            value: 2,
                            child: Text("Di Atas Normal"),
                          ),
                          DropdownMenuItem(
                            value: 3,
                            child: Text("Jauh Di Atas Normal"),
                          ),
                        ],
                        onChanged: (val) => setState(() => _cholesterol = val!),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildLabelAndInput(
                      "Level Glukosa",
                      DropdownButtonFormField<int>(
                        value: _gluc,
                        isExpanded: true,
                        decoration: _inputDecoration(Icons.bloodtype_outlined),
                        items: const [
                          DropdownMenuItem(value: 1, child: Text("Normal")),
                          DropdownMenuItem(
                            value: 2,
                            child: Text("Di Atas Normal"),
                          ),
                          DropdownMenuItem(
                            value: 3,
                            child: Text("Jauh Di Atas Normal"),
                          ),
                        ],
                        onChanged: (val) => setState(() => _gluc = val!),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- BAGIAN 3: GAYA HIDUP ---
            _buildSectionTitle(
              "03",
              "Gaya Hidup",
              "Kebiasaan yang memengaruhi risiko",
              Icons.favorite_outline,
            ),
            _buildSectionCard(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text(
                      "Merokok",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    value: _smoke == 1,
                    activeColor: colorScheme.primary,
                    onChanged: (val) => setState(() => _smoke = val ? 1 : 0),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text(
                      "Konsumsi Alkohol",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    value: _alco == 1,
                    activeColor: colorScheme.primary,
                    onChanged: (val) => setState(() => _alco = val ? 1 : 0),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text(
                      "Aktif Berolahraga",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    value: _active == 1,
                    activeColor: colorScheme.primary,
                    onChanged: (val) => setState(() => _active = val ? 1 : 0),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // --- TOMBOL SUBMIT ---
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isLoading ? null : _submitData,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Analisis Risiko",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 10),
                          Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Helper Widget untuk meletakkan Label Teks di atas Input Field
  Widget _buildLabelAndInput(String label, Widget inputWidget) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 6),
        inputWidget,
      ],
    );
  }

  Widget _buildIntro(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.favorite_rounded, color: Colors.white, size: 28),
          const SizedBox(height: 16),
          const Text(
            "Kenali kondisi jantungmu",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Isi data dengan jujur untuk mendapatkan analisis risiko yang lebih akurat.",
            style: TextStyle(
              color: Colors.white.withOpacity(0.86),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: child,
    );
  }

  // Update fungsi ini agar lebih ringkas (menghapus labelText dan menambah hint)
  InputDecoration _inputDecoration(
    IconData icon, {
    String? hint,
    String? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      prefixIcon: Icon(icon, size: 20),
      suffixText: suffix,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      // Mengurangi sedikit padding agar tidak sesak
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
    );
  }

  Widget _buildSectionTitle(
    String number,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 19,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withOpacity(0.1),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$number  $title",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
