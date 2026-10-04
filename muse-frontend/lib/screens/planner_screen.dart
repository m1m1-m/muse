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
  Map<String, String> outfitNames = {};
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

      final outfits = await apiService.getOutfits();

      if (!mounted) return;

      setState(() {
        plans = result;
        outfitNames = {
          for (final outfit in outfits)
            outfit['id'].toString(): outfit['name'].toString(),
        };
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

    return outfitNames[plan['outfitId']] ??
        'Outfit ID: ${plan['outfitId'] ?? 'Unknown'}';
  }

  Future<void> planOutfit() async {
    final outfits = await apiService.getOutfits();

    if (!mounted) return;

    if (outfits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Create an outfit first.'),
        ),
      );
      return;
    }

    final outfitId = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('Plan outfit for ${formatDate(selectedDate)}'),
        children: [
          for (final outfit in outfits)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(
                context,
                outfit['id'].toString(),
              ),
              child: Text(outfit['name'].toString()),
            ),
        ],
      ),
    );

    if (outfitId == null) return;

    try {
      await apiService.savePlanner(
        date: formatDate(selectedDate),
        outfitId: outfitId,
      );

      await loadPlanner();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to plan outfit: $e'),
        ),
      );
    }
  }

  Future<void> removePlan() async {
    try {
      await apiService.deletePlanner(
        date: formatDate(selectedDate),
      );

      await loadPlanner();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to remove plan: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planner'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: planOutfit,
        icon: const Icon(Icons.event_available),
        label: Text(plans.isEmpty ? 'Plan outfit' : 'Change outfit'),
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
                'Planned for ${formatDate(selectedDate)}',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Remove plan',
                onPressed: removePlan,
              ),
            ),
          );
        },
      ),
    );
  }
}