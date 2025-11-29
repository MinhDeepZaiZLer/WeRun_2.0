import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dacs4_werun_2_0/core/di/injection.dart';
import '../../../../domain/entities/leaderboard_entry.dart';
import '../../../../domain/repositories/leaderboard_repository.dart';
import 'bloc/leaderboard_bloc.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<LeaderboardBloc>()..add(LoadLeaderboard()),
      child: const StatisticsView(),
    );
  }
}

class StatisticsView extends StatelessWidget {
  const StatisticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Leaderboard", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 1. Filter & Scope Controls
          const _LeaderboardControls(),
          
          // 2. Ranking List
          Expanded(
            child: BlocBuilder<LeaderboardBloc, LeaderboardState>(
              builder: (context, state) {
                if (state.isLoading) return const Center(child: CircularProgressIndicator(color: Color(0xFFD0FD3E)));
                if (state.rankings.isEmpty) return const Center(child: Text("No data available"));

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 16),
                  itemCount: state.rankings.length,
                  itemBuilder: (context, index) {
                    final entry = state.rankings[index];
                    // Top 3 có thể làm nổi bật (tuỳ chọn, ở đây làm list đơn giản trước)
                    return _RankItem(entry: entry, rank: index + 1);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardControls extends StatelessWidget {
  const _LeaderboardControls();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<LeaderboardBloc>();
    
    return BlocBuilder<LeaderboardBloc, LeaderboardState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Toggle Global / Friends
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ScopeButton(
                    title: "Global", 
                    isSelected: state.isGlobal,
                    onTap: () => bloc.add(LoadLeaderboard(filter: state.currentFilter, isGlobal: true)),
                  ),
                  const SizedBox(width: 16),
                  _ScopeButton(
                    title: "Friends", 
                    isSelected: !state.isGlobal,
                    onTap: () => bloc.add(LoadLeaderboard(filter: state.currentFilter, isGlobal: false)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Time Filters
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip(label: "All Time", filter: LeaderboardFilter.total, current: state.currentFilter),
                    _FilterChip(label: "Year", filter: LeaderboardFilter.year, current: state.currentFilter),
                    _FilterChip(label: "Month", filter: LeaderboardFilter.month, current: state.currentFilter),
                    _FilterChip(label: "Week", filter: LeaderboardFilter.week, current: state.currentFilter),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ScopeButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _ScopeButton({required this.title, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.black),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? const Color(0xFFD0FD3E) : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final LeaderboardFilter filter;
  final LeaderboardFilter current;

  const _FilterChip({required this.label, required this.filter, required this.current});

  @override
  Widget build(BuildContext context) {
    final isSelected = filter == current;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: const Color(0xFFD0FD3E),
        backgroundColor: Colors.grey[200],
        labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.grey[600], fontWeight: FontWeight.bold),
        onSelected: (_) {
           final bloc = context.read<LeaderboardBloc>();
           bloc.add(LoadLeaderboard(filter: filter, isGlobal: bloc.state.isGlobal));
        },
      ),
    );
  }
}

class _RankItem extends StatelessWidget {
  final LeaderboardEntry entry;
  final int rank;

  const _RankItem({required this.entry, required this.rank});

  @override
  Widget build(BuildContext context) {
    Color rankColor = Colors.grey;
    if (rank == 1) rankColor = Colors.amber;
    if (rank == 2) rankColor = Colors.grey.shade400;
    if (rank == 3) rankColor = Colors.orangeAccent;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: rank <= 3 ? rankColor.withOpacity(0.2) : Colors.transparent,
          ),
          child: Text(
            "#$rank",
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              color: rank <= 3 ? rankColor : Colors.black
            ),
          ),
        ),
        title: Text(entry.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "${entry.totalDistanceKm.toStringAsFixed(1)} km",
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black),
            ),
            Text(
              _formatDuration(entry.totalDurationSeconds),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    return h > 0 ? "${h}h" : "${seconds ~/ 60}m";
  }
}