import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/history_services.dart';

class SimulationScreen extends StatefulWidget {
  const SimulationScreen({super.key});

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen> {
  List<Map<String, dynamic>> _histories = [];
  Map<String, dynamic>? _selectedHistory;
  Map<String, dynamic>? _simulatedResult;
  bool _isLoading = false;

  final _weightCtrl = TextEditingController();
  final _apHiCtrl = TextEditingController();
  final _apLoCtrl = TextEditingController();

  int _cholesterol = 1;
  int _gluc = 1;
  int _smoke = 0;
  int _alco = 0;
  int _active = 1;

  @override
  void initState() {
    super.initState();
    _loadHistories();
  }

  Future<void> _loadHistories() async {
    final histories = await HistoryService.getHistories();
    setState(() {
      _histories = histories;
      if (_histories.isNotEmpty) {
        _selectHistory(_histories.first);
      }
    });
  }

  void _selectHistory(Map<String, dynamic> history) {
    setState(() {
      _selectedHistory = history;
      _simulatedResult = null;

      final req = history['request'];
      _weightCtrl.text = req['weight'].toString();
      _apHiCtrl.text = req['ap_hi'].toString();
      _apLoCtrl.text = req['ap_lo'].toString();
      _cholesterol = req['cholesterol'];
      _gluc = req['gluc'];
      _smoke = req['smoke'];
      _alco = req['alco'];
      _active = req['active'];
    });
  }

  Future<void> _runSimulation() async {
    if (_selectedHistory == null) return;
    setState(() => _isLoading = true);

    final originalReq = _selectedHistory!['request'];

    final simulatedRequest = {
      "age_days": originalReq['age_days'],
      "gender": originalReq['gender'],
      "height": originalReq['height'],
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
        body: jsonEncode(simulatedRequest),
      );

      if (response.statusCode == 200) {
        setState(() {
          _simulatedResult = jsonDecode(response.body);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Terjadi kesalahan koneksi")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_histories.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("Belum ada riwayat asesmen.\nSilakan lakukan asesmen terlebih dahulu.", textAlign: TextAlign.center)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("What-If Simulation", style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text("Pilih Data Dasar (Baseline)", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<Map<String, dynamic>>(
            value: _selectedHistory,
            isExpanded: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            items: _histories.map((hist) {
              DateTime date = DateTime.parse(hist['date']);
              return DropdownMenuItem(
                value: hist,
                child: Text("Riwayat: ${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}"),
              );
            }).toList(),
            onChanged: (val) => _selectHistory(val!),
          ),
          const SizedBox(height: 24),

          if (_simulatedResult != null) _buildComparisonChart(),
          if (_simulatedResult != null) const SizedBox(height: 24),

          const Text("Ubah Gaya Hidup & Metrik", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildLabelInput("Berat (kg)", _weightCtrl)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildLabelInput("Sistolik", _apHiCtrl)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildLabelInput("Diastolik", _apLoCtrl)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text("Berhenti Merokok / Tidak Merokok", style: TextStyle(fontSize: 14)),
                    value: _smoke == 0,
                    activeColor: Colors.green,
                    onChanged: (val) => setState(() => _smoke = val ? 0 : 1),
                  ),
                  SwitchListTile(
                    title: const Text("Aktif Berolahraga", style: TextStyle(fontSize: 14)),
                    value: _active == 1,
                    activeColor: Colors.green,
                    onChanged: (val) => setState(() => _active = val ? 1 : 0),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _isLoading ? null : _runSimulation,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Jalankan Simulasi", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildLabelInput(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonChart() {
    final originalTraj = _selectedHistory!['response']['trajectory'] as List;
    final simulatedTraj = _simulatedResult!['trajectory'] as List;

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade300)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegend(Colors.red.shade400, "Risiko Awal"),
                const SizedBox(width: 20),
                _buildLegend(Colors.green.shade600, "Setelah Perubahan"),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true, drawVerticalLine: false),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}%',
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 2,
                        getTitlesWidget: (value, meta) => Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text('Thn ${value.toInt()}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        ),
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: 10,
                  lineBarsData: [
                    _buildLineChartBarData(originalTraj, Colors.red.shade300, isDashed: true),
                    _buildLineChartBarData(simulatedTraj, Colors.green.shade600, isDashed: false),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  LineChartBarData _buildLineChartBarData(List trajectory, Color color, {required bool isDashed}) {
    return LineChartBarData(
      spots: trajectory.map<FlSpot>((point) {
        int year = int.parse(point['year'].toString().replaceAll("Year ", ""));
        return FlSpot(year.toDouble(), double.parse(point['risk_percentage'].toString()));
      }).toList(),
      isCurved: true,
      color: color,
      barWidth: 4,
      isStrokeCapRound: true,
      dashArray: isDashed ? [8, 4] : null,
      dotData: const FlDotData(show: true),
    );
  }
}