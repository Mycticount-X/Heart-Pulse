import 'package:flutter/material.dart';
import '../services/history_services.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _latestHistory;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLatestData();
  }

  Future<void> _loadLatestData() async {
    final histories = await HistoryService.getHistories();
    if (mounted) {
      setState(() {
        if (histories.isNotEmpty) {
          _latestHistory = histories.first;
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const SizedBox.shrink(),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadLatestData,
              color: colorScheme.primary,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.favorite_rounded, color: colorScheme.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Halo!",
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Pantau terus metrik kesehatan jantungmu di sini.",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.4),
                  ),
                  const SizedBox(height: 24),

                  // Tampilkan tampilan kosong jika belum ada data,
                  // atau tampilkan ringkasan jika sudah ada data.
                  if (_latestHistory == null)
                    _buildEmptyState(colorScheme)
                  else
                    _buildDashboardContent(colorScheme),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(Icons.monitor_heart_outlined, size: 64, color: colorScheme.primary),
          const SizedBox(height: 16),
          const Text(
            "Belum Ada Data",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Mulai asesmen pertamamu untuk melihat proyeksi risiko 10 tahun ke depan.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(ColorScheme colorScheme) {
    final request = _latestHistory!['request'];
    final trajectory = _latestHistory!['response']['trajectory'] as List;
    final currentRisk = double.parse(trajectory[0]['risk_percentage'].toString());
    final riskText = currentRisk.toStringAsFixed(1);
    
    final date = DateTime.parse(_latestHistory!['date']);
    final dateString = "${date.day}/${date.month}/${date.year}";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 0.5,
          color: currentRisk > 50 ? Colors.red.shade50 : Colors.green.shade50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: currentRisk > 50 ? Colors.red.shade200 : Colors.green.shade200,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Risiko Saat Ini",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: currentRisk > 50 ? Colors.red.shade700 : Colors.green.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$riskText%",
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: currentRisk > 50 ? Colors.red.shade700 : Colors.green.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: currentRisk > 50 ? Colors.red.shade100 : Colors.green.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        currentRisk > 50 ? "Perlu perhatian" : "Kondisi baik",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: currentRisk > 50 ? Colors.red.shade700 : Colors.green.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                Icon(
                  currentRisk > 50 ? Icons.warning_rounded : Icons.check_circle_rounded,
                  size: 48,
                  color: currentRisk > 50 ? Colors.red.shade300 : Colors.green.shade300,
                )
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        
        // Info Tanggal Asesmen
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.access_time_rounded, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Text(
                  "Asesmen terakhir: $dateString",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Grid Ringkasan Metrik
        const Text(
          "Ringkasan Metrik",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.5,
          children: [
            _buildMetricCard("Tekanan Darah", "${request['ap_hi']}/${request['ap_lo']}", "mmHg", Icons.bloodtype),
            _buildMetricCard("Berat Badan", "${request['weight']}", "kg", Icons.monitor_weight),
            _buildMetricCard("Olahraga", request['active'] == 1 ? "Aktif" : "Pasif", "", Icons.directions_run),
            _buildMetricCard("Merokok", request['smoke'] == 1 ? "Ya" : "Tidak", "", Icons.smoking_rooms),
          ],
        ),
      ],
    );
  }

  // Helper Widget untuk Kotak Metrik Kecil
  Widget _buildMetricCard(String title, String value, String unit, IconData icon) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if (unit.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3.0),
                    child: Text(unit, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                  ),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }
}