import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/patient.dart';
import '../providers/patient_provider.dart';
import '../utils/date_formatter.dart';
import 'patient_detail_screen.dart';
import 'patient_form_screen.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      _refresh();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() {
    return context.read<PatientProvider>().loadPatients(
      keyword: _searchController.text.trim(),
    );
  }

  void _openPatientForm() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PatientFormScreen(doctorName: ''),
      ),
    ).then((_) {
      _refresh();
    });
  }

  void _openPatientDetail(Patient patient) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PatientDetailScreen(patient: patient, doctorName: ''),
      ),
    ).then((_) {
      _refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Pasien'),
        actions: [
          IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openPatientForm,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Tambah Pasien'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari nama atau ID pasien',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  isDense: true,
                ),
                onChanged: (_) {
                  _refresh();
                },
              ),
            ),
            Expanded(
              child: Consumer<PatientProvider>(
                builder: (context, provider, _) {
                  if (provider.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.error != null) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Error: ${provider.error}',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  if (provider.patients.isEmpty) {
                    return const Center(
                      child: Text(
                        'Belum ada pasien.\nSilakan tambahkan data pasien baru.',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                      itemCount: provider.patients.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final patient = provider.patients[index];

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            patient.nama,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${patient.idPasien}\n'
                            'TTL: ${patient.tempatLahir}, '
                            '${formatDate(patient.tanggalLahir, pattern: 'dd-MM-yyyy')}',
                          ),
                          isThreeLine: true,
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _openPatientDetail(patient),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
