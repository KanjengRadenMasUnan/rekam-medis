import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/patient.dart';
import '../providers/patient_provider.dart';
import '../utils/date_formatter.dart';
import 'book_list_screen.dart';
import 'patient_detail_screen.dart';
import 'patient_form_screen.dart';
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
  final Color _textColor = const Color(0xFF2D3748);

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Ubah Nama',
          style: TextStyle(color: _textColor, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Nama Lengkap',
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
            style: FilledButton.styleFrom(backgroundColor: Colors.teal),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    if (newName != null && newName.trim().isNotEmpty)
      setState(() => _doctorName = newName.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _editDoctorName,
                        child: Text(
                          'Halo, $_doctorName',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _textColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _editDoctorName,
                      child: const CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white,
                        backgroundImage: NetworkImage(
                          'https://cdn-icons-png.flaticon.com/512/3774/3774299.png',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Cari pasien, riwayat, atau data...',
                      hintStyle: TextStyle(color: Colors.black38, fontSize: 14),
                      prefixIcon: Icon(Icons.search, color: Colors.black38),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    onSubmitted: (_) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PatientListScreen(
                            initialKeyword: _searchController.text,
                            doctorName: _doctorName,
                          ),
                        ),
                      ).then((_) {
                        _searchController.clear();
                        _refresh();
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),

                Consumer<PatientProvider>(
                  builder: (context, provider, _) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE3F2FD),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.bar_chart,
                              color: Color(0xFF1976D2),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Total Pasien: ${provider.patients.length}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _textColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),

                Text(
                  'Menu Utama',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 16),

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.05,
                  children: [
                    // PENAMBAHAN doctorName: _doctorName AGAR TIDAK ERROR
                    _MenuGridCard(
                      title: 'Isi Data Pasien',
                      iconData: Icons.assignment_ind_outlined,
                      bgColor: const Color(0xFFE3F2FD),
                      iconColor: const Color(0xFF1976D2),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              PatientFormScreen(doctorName: _doctorName),
                        ),
                      ).then((_) => _refresh()),
                    ),
                    _MenuGridCard(
                      title: 'Scan & Assesment',
                      iconData: Icons.qr_code_scanner,
                      bgColor: const Color(0xFFE8F5E9),
                      iconColor: const Color(0xFF388E3C),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ScanScreen(doctorName: _doctorName),
                        ),
                      ),
                    ),
                    _MenuGridCard(
                      title: 'Daftar Data Pasien',
                      iconData: Icons.folder_shared_outlined,
                      bgColor: const Color(0xFFFFF3E0),
                      iconColor: const Color(0xFFF57C00),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              PatientListScreen(doctorName: _doctorName),
                        ),
                      ).then((_) => _refresh()),
                    ),
                    _MenuGridCard(
                      title: 'Buku Digital',
                      iconData: Icons.menu_book,
                      bgColor: const Color(0xFFF3E5F5),
                      iconColor: const Color(0xFF7B1FA2),
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

                Text(
                  'Pendaftaran Terakhir',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 16),

                Consumer<PatientProvider>(
                  builder: (context, provider, _) {
                    if (provider.loading)
                      return const Center(child: CircularProgressIndicator());
                    if (provider.patients.isEmpty)
                      return const Text(
                        'Belum ada pendaftaran.',
                        style: TextStyle(color: Colors.grey),
                      );

                    final recentPatients = provider.patients.take(5).toList();
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      // PERBAIKAN TANDA BACA ERROR EXPECTED ')'
                      child: Column(
                        children: recentPatients.asMap().entries.map((entry) {
                          final patient = entry.value;
                          final timeString = formatDate(
                            patient.createdAt ?? DateTime.now(),
                            pattern: 'HH:mm',
                          );
                          return Column(
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(
                                  Icons.circle,
                                  size: 10,
                                  color: Colors.teal,
                                ),
                                title: Text(
                                  patient.nama,
                                  style: TextStyle(
                                    color: _textColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                subtitle: Text('$timeString WIB (Terdaftar)'),
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
                              if (entry.key < recentPatients.length - 1)
                                const Divider(height: 1, color: Colors.black12),
                            ],
                          );
                        }).toList(),
                      ),
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

class _MenuGridCard extends StatelessWidget {
  final String title;
  final IconData iconData;
  final Color bgColor;
  final Color iconColor;
  final VoidCallback onTap;
  const _MenuGridCard({
    required this.title,
    required this.iconData,
    required this.bgColor,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: Icon(iconData, size: 36, color: iconColor),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PatientListScreen extends StatefulWidget {
  final String? initialKeyword;
  final String doctorName;
  const PatientListScreen({
    super.key,
    this.initialKeyword,
    required this.doctorName,
  });

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  late TextEditingController _searchController;
  final Color _textColor = const Color(0xFF2D3748);

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: widget.initialKeyword ?? '',
    );
    Future.microtask(
      () => context.read<PatientProvider>().loadPatients(
        keyword: _searchController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text(
          'Daftar Data Pasien',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(
                  color: _textColor,
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  hintText: 'Cari nama, ID, tempat lahir...',
                  hintStyle: TextStyle(
                    color: Colors.black38,
                    fontWeight: FontWeight.normal,
                  ),
                  prefixIcon: Icon(Icons.search, color: Colors.black38),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 16),
                ),
                onChanged: (_) => context.read<PatientProvider>().loadPatients(
                  keyword: _searchController.text.trim(),
                ),
              ),
            ),
          ),
          Expanded(
            child: Consumer<PatientProvider>(
              builder: (context, provider, _) {
                if (provider.loading)
                  return const Center(child: CircularProgressIndicator());
                if (provider.patients.isEmpty)
                  return const Center(
                    child: Text(
                      'Data pasien tidak ditemukan.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: provider.patients.length,
                  itemBuilder: (context, index) {
                    final patient = provider.patients[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFE3F2FD),
                          child: const Icon(
                            Icons.person,
                            color: Color(0xFF1976D2),
                          ),
                        ),
                        title: Text(
                          patient.nama,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _textColor,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            'ID: ${patient.idPasien}\nTTL: ${patient.tempatLahir}, ${formatDate(patient.tanggalLahir, pattern: 'dd-MM-yyyy')}',
                          ),
                        ),
                        isThreeLine: true,
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Colors.grey,
                        ),
                        onTap: () =>
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PatientDetailScreen(
                                  patient: patient,
                                  doctorName: widget.doctorName,
                                ),
                              ),
                            ).then(
                              (_) => context
                                  .read<PatientProvider>()
                                  .loadPatients(),
                            ),
                      ),
                    );
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
