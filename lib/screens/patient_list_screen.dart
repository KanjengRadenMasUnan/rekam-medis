import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/patient.dart';
import '../providers/patient_provider.dart';
import '../utils/date_formatter.dart';
import 'patient_detail_screen.dart';
import 'patient_form_screen.dart';

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
  final Color _textColor = const Color(0xFF0F172A);

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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Direktori Data Pasien'),
        actions: [
          IconButton(
            tooltip: 'Tambah Pasien',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    PatientFormScreen(doctorName: widget.doctorName),
              ),
            ).then((_) => context.read<PatientProvider>().loadPatients()),
            icon: const Icon(
              Icons.person_add_alt_1_rounded,
              color: Color(0xFF0F766E),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // SEARCH INPUT SURFACE
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(
                  color: _textColor,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: 'Cari nama, ID rekam medis, tempat lahir...',
                  hintStyle: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 13.5,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF0F766E),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            context.read<PatientProvider>().loadPatients(
                              keyword: '',
                            );
                            setState(() {});
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onChanged: (val) {
                  setState(() {});
                  context.read<PatientProvider>().loadPatients(
                    keyword: val.trim(),
                  );
                },
              ),
            ),
          ),

          // PATIENT LIST
          Expanded(
            child: Consumer<PatientProvider>(
              builder: (context, provider, _) {
                if (provider.loading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF0F766E)),
                  );
                }
                if (provider.patients.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 56,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Data pasien tidak ditemukan.',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  itemCount: provider.patients.length,
                  itemBuilder: (context, index) {
                    final patient = provider.patients[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFCCFBF1),
                          child: Text(
                            patient.nama.isNotEmpty
                                ? patient.nama[0].toUpperCase()
                                : 'P',
                            style: const TextStyle(
                              color: Color(0xFF0F766E),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        title: Text(
                          patient.nama,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.5,
                            color: _textColor,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'RM: ${patient.idPasien}\nTTL: ${patient.tempatLahir}, ${formatDate(patient.tanggalLahir, pattern: 'dd-MM-yyyy')}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                              height: 1.3,
                            ),
                          ),
                        ),
                        isThreeLine: true,
                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: Color(0xFFCBD5E1),
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
                              (_) => provider.loadPatients(
                                keyword: _searchController.text.trim(),
                              ),
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
