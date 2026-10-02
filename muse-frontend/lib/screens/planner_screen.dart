import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  final ApiService apiService = ApiService();

  List<dynamic> plans = [];
  bool loading = true;
  String? error;

  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    loadPlanner();
  }

  String formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> loadPlanner() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final date = formatDate(selectedDate);

      final result = await apiService.getPlanner(
        from: date,
        to: date,
      );

      if (!mounted) return;

      setState(() {
        plans = result;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  Future<void> selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (picked == null) return;

    setState(() {
      selectedDate = picked;
    });

    await loadPlanner();
  }

  String getPlanOutfitName(dynamic plan) {
    if (plan is! Map<String, dynamic>) {
      return 'Unknown outfit';
    }

    return plan['outfitName'] ??
        plan['name'] ??
        'Outfit ID: ${plan['outfitId'] ?? 'Unknown'}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planner'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_month),
                title: Text(
                  formatDate(selectedDate),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text('Selected date'),
                trailing: ElevatedButton(
                  onPressed: selectDate,
                  child: const Text('Change'),
                ),
              ),
            ),
          ),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 50,
              ),
              const SizedBox(height: 15),
              Text(
                error!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: loadPlanner,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (plans.isEmpty) {
      return RefreshIndicator(
        onRefresh: loadPlanner,
        child: ListView(
          children: const [
            SizedBox(height: 180),
            Center(
              child: Text(
                'No outfit planned for this date.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadPlanner,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: plans.length,
        itemBuilder: (context, index) {
          final plan = plans[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.checkroom),
              ),
              title: Text(
                getPlanOutfitName(plan),
              ),
              subtitle: Text(
                'Outfit ID: ${plan['outfitId'] ?? 'Unknown'}',
              ),
            ),
          );
        },
      ),
    );
  }
}