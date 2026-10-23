import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/patient_provider.dart';
import '../utils/date_formatter.dart';
import 'book_list_screen.dart';
import 'patient_detail_screen.dart';
import 'patient_form_screen.dart';
import 'patient_list_screen.dart';
import 'scan_screen.dart';

class HomeScreen extends StatefulWidget {
  final String doctorName;
  const HomeScreen({super.key, required this.doctorName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  late String _doctorName;

  @override
  void initState() {
    super.initState();
    _doctorName = widget.doctorName;
    Future.microtask(() => _refresh());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() => context.read<PatientProvider>().loadPatients(
    keyword: _searchController.text.trim(),
  );

  Future<void> _editDoctorName() async {
    final TextEditingController nameCtrl = TextEditingController(
      text: _doctorName,
    );
    final String? newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Ubah Identitas Petugas',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Nama Lengkap & Gelar',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, nameCtrl.text),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF0F766E),
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    if (newName != null && newName.trim().isNotEmpty) {
      setState(() => _doctorName = newName.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          color: const Color(0xFF0F766E),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER SECTION
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'SEDANG BERTUGAS',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF64748B),
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: _editDoctorName,
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    _doctorName,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F172A),
                                      letterSpacing: -0.5,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.edit_outlined,
                                  size: 16,
                                  color: Color(0xFF94A3B8),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: _editDoctorName,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF0F766E),
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: const Color(0xFFCCFBF1),
                          child: Text(
                            _doctorName.isNotEmpty
                                ? _doctorName[0].toUpperCase()
                                : 'D',
                            style: const TextStyle(
                              color: Color(0xFF0F766E),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // METRIC BANNER CARD
                Consumer<PatientProvider>(
                  builder: (context, provider, _) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F766E), Color(0xFF115E59)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF0F766E,
                            ).withValues(alpha: 0.3),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'TOTAL REKAM MEDIS AKTIF',
                                style: TextStyle(
                                  color: Color(0xFFCCFBF1),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${provider.patients.length} Pasien',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.folder_shared_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 28),

                // MAIN MENU (BENTO GRID)
                const Text(
                  'Layanan Utama',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 16),

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 1.15,
                  children: [
                    _BentoMenuCard(
                      title: 'Pendaftaran\nPasien',
                      subtitle: 'Input baru',
                      icon: Icons.person_add_alt_1_rounded,
                      color: const Color(0xFF0284C7),
                      bgSoft: const Color(0xFFE0F2FE),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              PatientFormScreen(doctorName: _doctorName),
                        ),
                      ).then((_) => _refresh()),
                    ),
                    _BentoMenuCard(
                      title: 'Scan Pasien\n& Asesmen',
                      subtitle: 'Via barcode',
                      icon: Icons.qr_code_scanner_rounded,
                      color: const Color(0xFF0F766E),
                      bgSoft: const Color(0xFFCCFBF1),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ScanScreen(doctorName: _doctorName),
                        ),
                      ),
                    ),
                    _BentoMenuCard(
                      title: 'Direktori\nPasien',
                      subtitle: 'Cari berkas',
                      icon: Icons.folder_open_rounded,
                      color: const Color(0xFFD97706),
                      bgSoft: const Color(0xFFFEF3C7),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              PatientListScreen(doctorName: _doctorName),
                        ),
                      ).then((_) => _refresh()),
                    ),
                    _BentoMenuCard(
                      title: 'Buku Medis\nDigital',
                      subtitle: 'Katalog PDF',
                      icon: Icons.auto_stories_rounded,
                      color: const Color(0xFF7C3AED),
                      bgSoft: const Color(0xFFEDE9FE),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BookListScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // RECENT PATIENT LIST
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Pendaftaran Terbaru',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              PatientListScreen(doctorName: _doctorName),
                        ),
                      ).then((_) => _refresh()),
                      child: const Text(
                        'Lihat Semua',
                        style: TextStyle(
                          color: Color(0xFF0F766E),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Consumer<PatientProvider>(
                  builder: (context, provider, _) {
                    if (provider.loading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(
                            color: Color(0xFF0F766E),
                          ),
                        ),
                      );
                    }
                    if (provider.patients.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(28),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Text(
                          'Belum ada riwayat pendaftaran pasien.',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 13,
                          ),
                        ),
                      );
                    }

                    final recentPatients = provider.patients.take(4).toList();
                    return Column(
                      children: recentPatients.map((patient) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFF1F5F9)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFFCCFBF1),
                              child: Text(
                                patient.nama.isNotEmpty
                                    ? patient.nama[0].toUpperCase()
                                    : 'P',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F766E),
                                ),
                              ),
                            ),
                            title: Text(
                              patient.nama,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            subtitle: Text(
                              'ID: ${patient.idPasien} • ${formatDate(patient.createdAt, pattern: 'dd MMM, HH:mm')}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: Color(0xFFCBD5E1),
                            ),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PatientDetailScreen(
                                  patient: patient,
                                  doctorName: _doctorName,
                                ),
                              ),
                            ).then((_) => _refresh()),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BentoMenuCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color bgSoft;
  final VoidCallback onTap;

  const _BentoMenuCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.bgSoft,
    required this.onTap,
  });

  @override
  State<_BentoMenuCard> createState() => _BentoMenuCardState();
}

class _BentoMenuCardState extends State<_BentoMenuCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.95),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: widget.bgSoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(widget.icon, color: widget.color, size: 24),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.subtitle,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
