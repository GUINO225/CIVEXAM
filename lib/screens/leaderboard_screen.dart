// lib/screens/leaderboard_screen.dart (fixed async + duration format)
import 'package:flutter/material.dart';
import '../models/leaderboard_entry.dart';
import '../services/competition_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});
  @override State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<LeaderboardEntry> _entries = const [];
  String _query = '';

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final competitionService = CompetitionService();
    await competitionService.purgeLegacyEntries();
    final comp = await competitionService.topEntries();
    comp.sort((a, b) {
      final percentCompare = b.percent.compareTo(a.percent);
      if (percentCompare != 0) return percentCompare;
      return a.durationSec.compareTo(b.durationSec);
    });
    if (!mounted) return;
    setState(() { _entries = comp; });
  }

  List<LeaderboardEntry> get _filtered {
    Iterable<LeaderboardEntry> it = _entries;
    if (_query.trim().isNotEmpty) {
      final q = _query.toLowerCase();
      it = it.where((e) => e.name.toLowerCase().contains(q) || e.subject.toLowerCase().contains(q) || e.chapter.toLowerCase().contains(q));
    }
    return it.toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      appBar: AppBar(title: const Text('Classement'), actions:[
        IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
      ]),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12,12,12,6),
          child: Row(children: [
            Expanded(child: TextField(
              decoration: const InputDecoration(
                isDense: true,
                prefixIcon: Icon(Icons.search),
                hintText: 'Nom / matière',
                border: OutlineInputBorder(borderRadius: BorderRadius.zero),
              ),
              onChanged: (v)=>setState(()=>_query=v),
            )),
            const SizedBox(width:12),
          ]),
        ),
        const Divider(height:1),
        Expanded(child: filtered.isEmpty
          ? const Center(child: Text('Aucune entrée pour l’instant'))
          : ListView.separated(
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final e = filtered[i]; final rank = i+1;
                return ListTile(
                  leading: _RankAvatar(rank: rank),
                  title: Text(e.name, style: Theme.of(context).textTheme.titleMedium),
                  subtitle: Text('Compétition • ${e.subject.isEmpty ? 'Général' : e.subject}${e.chapter.isEmpty ? '' : ' / ${e.chapter}'}'),
                  trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children:[
                    Text('${e.percent.toStringAsFixed(1)} %', style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text('${e.correct}/${e.total} • ${_fmtDuration(e.durationSec)}'),
                  ]),
                );
              },
            ),
        ),
      ]),
    );
  }

  String _fmtDuration(int s){
    final m = s ~/ 60;
    final r = s % 60;
    if (m == 0) return '${r}s';
    return '${m}m ${r.toString().padLeft(2, '0')}s';
  }
}

class _RankAvatar extends StatelessWidget {
  final int rank; const _RankAvatar({required this.rank});
  @override Widget build(BuildContext context){
    final isTop3 = rank<=3; Color bg; IconData icon;
    switch(rank){case 1: bg=const Color(0xFFFFD700); icon=Icons.emoji_events; break;
                  case 2: bg=const Color(0xFFC0C0C0); icon=Icons.emoji_events; break;
                  case 3: bg=const Color(0xFFCD7F32); icon=Icons.emoji_events; break;
                  default: bg=Colors.blueGrey.shade100; icon=Icons.person;}
    return CircleAvatar(backgroundColor: bg,
      child: isTop3? Icon(icon, color: Colors.black87) : Text('$rank', style: const TextStyle(color: Colors.black87)));
  }
}
