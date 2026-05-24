import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_kendaraanku_app/core/constants/colors.dart';
import 'package:flutter_kendaraanku_app/data/local/auth_local_datasource.dart';
import 'package:flutter_kendaraanku_app/data/models/vehicle_document_model.dart';
import 'package:flutter_kendaraanku_app/data/models/vehicle_model.dart';
import 'package:flutter_kendaraanku_app/data/repositories/vehicle_document_repository.dart';
import 'package:flutter_kendaraanku_app/data/repositories/vehicle_repository.dart';
import 'package:flutter_kendaraanku_app/presentation/blocs/vehicle/vehicle_bloc.dart';
import 'package:flutter_kendaraanku_app/presentation/blocs/vehicle_document/vehicle_document_bloc.dart';
import 'package:flutter_kendaraanku_app/presentation/blocs/vehicle_document/vehicle_document_event.dart';
import 'package:flutter_kendaraanku_app/presentation/blocs/vehicle_document/vehicle_document_state.dart';
import 'package:flutter_kendaraanku_app/presentation/docs/pages/add_document_page.dart';
import 'package:flutter_kendaraanku_app/presentation/vehicle/pages/add_vehicle_page.dart';

class DocsPage extends StatefulWidget {
  const DocsPage({super.key});

  @override
  State<DocsPage> createState() => _DocsPageState();
}

class _DocsPageState extends State<DocsPage> {
  int? _userId;
  List<VehicleModel> _vehicles = [];
  bool _bootstrapping = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final userId = await AuthLocalDatasource().getUserId();
    if (userId != null) {
      final vehiclesRes = await VehicleRepository().getByUser(userId);
      _vehicles = vehiclesRes.fold((_) => [], (v) => v);
    }
    if (mounted) {
      setState(() {
        _userId = userId;
        _bootstrapping = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_bootstrapping) {
      return const Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_userId == null) {
      return const Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(child: _NoUserView()),
      );
    }

    return BlocProvider(
      create: (_) => VehicleDocumentBloc(VehicleDocumentRepository())
        ..add(LoadDocuments(_userId!)),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          backgroundColor: AppColors.bg,
          body: SafeArea(
            child: _DocsContent(
              userId: _userId!,
              vehicles: _vehicles,
              onVehicleAdded: _bootstrap,
            ),
          ),
        ),
      ),
    );
  }
}

class _NoUserView extends StatelessWidget {
  const _NoUserView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          'Login terlebih dahulu',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class _DocsContent extends StatefulWidget {
  final int userId;
  final List<VehicleModel> vehicles;
  final VoidCallback onVehicleAdded;

  const _DocsContent({
    required this.userId,
    required this.vehicles,
    required this.onVehicleAdded,
  });

  @override
  State<_DocsContent> createState() => _DocsContentState();
}

class _DocsContentState extends State<_DocsContent> {
  String _searchQuery = '';
  bool _isSearching = false;

  Future<void> _openAddDocument(BuildContext ctx) async {
    if (widget.vehicles.isEmpty) {
      final vehicleBloc = ctx.read<VehicleBloc>();
      final added = await Navigator.of(ctx).push<bool>(
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: vehicleBloc,
            child: const AddVehiclePage(),
          ),
        ),
      );
      if (added == true) {
        widget.onVehicleAdded();
      }
      return;
    }
    final bloc = ctx.read<VehicleDocumentBloc>();
    await Navigator.of(ctx).push<bool>(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: AddDocumentPage(
            userId: widget.userId,
            vehicles: widget.vehicles,
          ),
        ),
      ),
    );
  }

  List<VehicleDocumentModel> _applySearch(List<VehicleDocumentModel> docs) {
    if (_searchQuery.isEmpty) return docs;
    final q = _searchQuery.toLowerCase();
    return docs.where((d) {
      final num = (d.documentNumber ?? '').toLowerCase();
      final notes = (d.notes ?? '').toLowerCase();
      return d.documentType.toLowerCase().contains(q) ||
          num.contains(q) ||
          notes.contains(q);
    }).toList();
  }

  String _vehicleName(int vehicleId) {
    final v = widget.vehicles
        .where((v) => v.id == vehicleId)
        .toList();
    return v.isNotEmpty ? v.first.name : 'Kendaraan';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VehicleDocumentBloc, VehicleDocumentState>(
      builder: (context, state) {
        if (state is VehicleDocumentLoading ||
            state is VehicleDocumentInitial) {
          return Column(
            children: [
              _buildAppBar(context, 0, 0),
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
            ],
          );
        }

        if (state is VehicleDocumentError) {
          return Column(
            children: [
              _buildAppBar(context, 0, 0),
              Expanded(
                child: Center(
                  child: Text(state.message,
                      style: GoogleFonts.plusJakartaSans(
                          color: AppColors.danger)),
                ),
              ),
            ],
          );
        }

        final loaded = state as VehicleDocumentLoaded;
        final totalCount = loaded.docs.length;
        final dueSoon = loaded.docs
            .where((d) =>
                d.daysUntilExpiry != null && d.daysUntilExpiry! <= 60)
            .length;

        if (totalCount == 0) {
          return Stack(
            children: [
              Column(
                children: [
                  _buildAppBar(context, 0, 0),
                  Expanded(
                    child: _EmptyState(
                      hasVehicles: widget.vehicles.isNotEmpty,
                      onTapAdd: () => _openAddDocument(context),
                    ),
                  ),
                ],
              ),
              if (widget.vehicles.isNotEmpty) _buildFAB(context),
            ],
          );
        }

        final visible = _applySearch(loaded.filteredDocs);

        return Stack(
          children: [
            Column(
              children: [
                _buildAppBar(context, totalCount, dueSoon),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (loaded.mostUrgent != null)
                          _UrgentBanner(
                              doc: loaded.mostUrgent!,
                              vehicleName: _vehicleName(
                                  loaded.mostUrgent!.vehicleId)),
                        _buildCategoryChips(context, loaded),
                        if (visible.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 32),
                            child: Center(
                              child: Text(
                                'Tidak ada dokumen untuk pencarian ini',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ),
                          )
                        else
                          _buildDocGrid(visible),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            _buildFAB(context),
          ],
        );
      },
    );
  }

  Widget _buildFAB(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 88,
      child: GestureDetector(
        onTap: () => _openAddDocument(context),
        child: Container(
          height: 52,
          padding: const EdgeInsets.fromLTRB(18, 0, 20, 0),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add, color: Colors.white, size: 20),
              const SizedBox(width: 6),
              Text(
                'Tambah Dokumen',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, int total, int dueSoon) {
    final subtitle = total == 0
        ? 'Belum ada dokumen'
        : '$total dokumen${dueSoon > 0 ? ' · $dueSoon perlu perpanjang' : ''}';

    if (_isSearching) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  autofocus: true,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 14, color: AppColors.text),
                  decoration: InputDecoration(
                    hintText: 'Cari dokumen...',
                    hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 14, color: AppColors.textMuted),
                    prefixIcon: const Icon(Icons.search,
                        size: 20, color: AppColors.textMuted),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => setState(() {
                _isSearching = false;
                _searchQuery = '';
              }),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.close,
                    size: 20, color: AppColors.text),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dokumen',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (total > 0)
            GestureDetector(
              onTap: () => setState(() => _isSearching = true),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.search,
                    size: 20, color: AppColors.text),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(
      BuildContext context, VehicleDocumentLoaded loaded) {
    final types = ['Semua', ...VehicleDocumentTypes.all];

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 6, 0, 14),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: types.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final type = types[index];
            final isAll = index == 0;
            final isActive = isAll
                ? loaded.activeType == null
                : loaded.activeType == type;
            final count = isAll
                ? loaded.docs.length
                : (loaded.typeCounts[type] ?? 0);
            final label = count > 0 ? '$type · $count' : type;
            return GestureDetector(
              onTap: () => context
                  .read<VehicleDocumentBloc>()
                  .add(FilterDocuments(
                      widget.userId, isAll ? null : type)),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : AppColors.surface,
                  border: isActive
                      ? null
                      : Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.white : AppColors.textMuted,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDocGrid(List<VehicleDocumentModel> docs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.78,
        ),
        itemCount: docs.length,
        itemBuilder: (context, index) {
          final doc = docs[index];
          return _DocCard(
            doc: doc,
            vehicleName: _vehicleName(doc.vehicleId),
            onDelete: () {
              context
                  .read<VehicleDocumentBloc>()
                  .add(DeleteDocument(doc.id!, widget.userId));
            },
          );
        },
      ),
    );
  }
}

// ─── Doc Card ──────────────────────────────────────────────────────────────────
class _DocCard extends StatelessWidget {
  final VehicleDocumentModel doc;
  final String vehicleName;
  final VoidCallback onDelete;

  const _DocCard({
    required this.doc,
    required this.vehicleName,
    required this.onDelete,
  });

  void _showDetailSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => VehicleDocumentDetailSheet(
        doc: doc,
        vehicleName: vehicleName,
        iconBuilder: _iconForType,
        tintBuilder: _tintForType,
        statusLabel: _statusLabel(),
        statusColor: _statusColor(),
        onDelete: onDelete,
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case VehicleDocumentTypes.stnk:
        return Icons.receipt_long_rounded;
      case VehicleDocumentTypes.bpkb:
        return Icons.shield_outlined;
      case VehicleDocumentTypes.sim:
        return Icons.badge_outlined;
      case VehicleDocumentTypes.asuransi:
        return Icons.health_and_safety_outlined;
      case VehicleDocumentTypes.pajak:
        return Icons.description_outlined;
      default:
        return Icons.folder_outlined;
    }
  }

  (Color, Color) _tintForType(String type) {
    switch (type) {
      case VehicleDocumentTypes.stnk:
        return (AppColors.tintAmberBg, AppColors.tintAmberFg);
      case VehicleDocumentTypes.bpkb:
        return (AppColors.tintBlueBg, AppColors.tintBlueFg);
      case VehicleDocumentTypes.sim:
        return (AppColors.tintLavenderBg, AppColors.tintLavenderFg);
      case VehicleDocumentTypes.asuransi:
        return (AppColors.tintMintBg, AppColors.tintMintFg);
      case VehicleDocumentTypes.pajak:
        return (AppColors.tintPeachBg, AppColors.tintPeachFg);
      default:
        return (AppColors.tintRoseBg, AppColors.tintRoseFg);
    }
  }

  String _statusLabel() {
    final days = doc.daysUntilExpiry;
    if (days == null) return 'Permanen';
    if (days < 0) return 'Kadaluarsa';
    if (days <= 30) return '$days hari lagi';
    if (days <= 90) return 'Akan habis';
    return 'Aktif';
  }

  Color _statusColor() {
    final days = doc.daysUntilExpiry;
    if (days == null) return AppColors.tintMintFg;
    if (days < 0) return AppColors.danger;
    if (days <= 30) return AppColors.danger;
    if (days <= 90) return AppColors.warning;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    final (tintBg, tintFg) = _tintForType(doc.documentType);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showDetailSheet(context),
        onLongPress: () => _confirmDelete(context),
        borderRadius: BorderRadius.circular(20),
        child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: tintBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_iconForType(doc.documentType),
                      size: 22, color: tintFg),
                ),
                if (doc.imagePath != null && File(doc.imagePath!).existsSync())
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.tintBlueBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.camera_alt,
                        size: 14, color: AppColors.tintBlueFg),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              doc.documentType,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              vehicleName,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                color: AppColors.textMuted,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              doc.documentNumber ?? '-',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: AppColors.textSoft,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.only(top: 10),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.divider, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BERLAKU',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSoft,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        doc.expiryDate != null
                            ? DateFormat('dd MMM yyyy', 'id_ID')
                                .format(doc.expiryDate!)
                            : 'Permanen',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _statusColor().withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _statusLabel(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _statusColor(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Hapus dokumen?',
          style: GoogleFonts.plusJakartaSans(
              fontSize: 16, fontWeight: FontWeight.w700),
        ),
        content: Text(
          '${doc.documentType} akan dihapus permanen.',
          style: GoogleFonts.plusJakartaSans(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal',
                style: GoogleFonts.plusJakartaSans(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onDelete();
            },
            child: Text('Hapus',
                style: GoogleFonts.plusJakartaSans(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}

// ─── Urgent Banner ─────────────────────────────────────────────────────────────
class _UrgentBanner extends StatelessWidget {
  final VehicleDocumentModel doc;
  final String vehicleName;

  const _UrgentBanner({required this.doc, required this.vehicleName});

  @override
  Widget build(BuildContext context) {
    final days = doc.daysUntilExpiry ?? 0;
    final isCritical = days <= 30;
    final bgColor =
        isCritical ? AppColors.tintRoseBg : AppColors.tintAmberBg;
    final fgColor =
        isCritical ? AppColors.tintRoseFg : AppColors.tintAmberFg;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.warning_amber_rounded,
                  size: 22, color: fgColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${doc.documentType} kadaluarsa $days hari lagi',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: fgColor,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '$vehicleName · ${DateFormat('dd MMM yyyy', 'id_ID').format(doc.expiryDate!)}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: fgColor.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty State ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final bool hasVehicles;
  final VoidCallback onTapAdd;

  const _EmptyState({required this.hasVehicles, required this.onTapAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Hero illustration
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  vertical: 32, horizontal: 24),
              decoration: BoxDecoration(
                gradient: AppColors.heroGradient,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(Icons.folder_open_rounded,
                        size: 36, color: Colors.white),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    hasVehicles
                        ? 'Belum Ada Dokumen'
                        : 'Mulai dari Kendaraan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hasVehicles
                        ? 'Catat STNK, BPKB, SIM, asuransi\ndan pajak kendaraanmu.'
                        : 'Tambahkan kendaraan terlebih dahulu\nsebelum menyimpan dokumennya.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.85),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 22),
                  GestureDetector(
                    onTap: onTapAdd,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add_rounded,
                              size: 18, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(
                            hasVehicles
                                ? 'Tambah Dokumen'
                                : 'Tambah Kendaraan',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Dokumen yang bisa kamu simpan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 12),
            _featureRow(Icons.receipt_long_rounded, AppColors.tintAmberBg,
                AppColors.tintAmberFg, 'STNK', 'Pengingat sebelum kadaluarsa'),
            const SizedBox(height: 8),
            _featureRow(Icons.shield_outlined, AppColors.tintBlueBg,
                AppColors.tintBlueFg, 'BPKB', 'Bukti kepemilikan kendaraan'),
            const SizedBox(height: 8),
            _featureRow(Icons.badge_outlined, AppColors.tintLavenderBg,
                AppColors.tintLavenderFg, 'SIM', 'Lisensi mengemudi'),
            const SizedBox(height: 8),
            _featureRow(
                Icons.health_and_safety_outlined,
                AppColors.tintMintBg,
                AppColors.tintMintFg,
                'Asuransi',
                'Polis & nomor klaim'),
          ],
        ),
      ),
    );
  }

  Widget _featureRow(
      IconData icon, Color bg, Color fg, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 18, color: fg),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Detail Bottom Sheet ──────────────────────────────────────────────────────
class VehicleDocumentDetailSheet extends StatelessWidget {
  final VehicleDocumentModel doc;
  final String vehicleName;
  final IconData Function(String) iconBuilder;
  final (Color, Color) Function(String) tintBuilder;
  final String statusLabel;
  final Color statusColor;
  final VoidCallback onDelete;

  const VehicleDocumentDetailSheet({
    super.key,
    required this.doc,
    required this.vehicleName,
    required this.iconBuilder,
    required this.tintBuilder,
    required this.statusLabel,
    required this.statusColor,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final (tintBg, tintFg) = tintBuilder(doc.documentType);
    final df = DateFormat('dd MMMM yyyy', 'id_ID');

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: tintBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(iconBuilder(doc.documentType),
                          color: tintFg, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doc.documentType,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                          ),
                          Text(
                            vehicleName,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusLabel,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.primarySofter,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppColors.primarySoft, width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc.isPermanent
                            ? 'BERLAKU SEUMUR HIDUP'
                            : 'BERLAKU SAMPAI',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        doc.expiryDate != null
                            ? df.format(doc.expiryDate!)
                            : 'Permanen',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _detailRow('Jenis Dokumen', doc.documentType),
                _detailRow('Kendaraan', vehicleName),
                if (doc.documentNumber != null &&
                    doc.documentNumber!.isNotEmpty)
                  _detailRow('Nomor', doc.documentNumber!),
                if (doc.issueDate != null)
                  _detailRow('Tanggal Terbit', df.format(doc.issueDate!)),
                _detailRow(
                  'Tanggal Kadaluarsa',
                  doc.expiryDate != null
                      ? df.format(doc.expiryDate!)
                      : 'Permanen',
                ),
                if (doc.notes != null && doc.notes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('CATATAN',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                        letterSpacing: 0.4,
                      )),
                  const SizedBox(height: 4),
                  Text(
                    doc.notes!,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: AppColors.text,
                    ),
                  ),
                ],
                if (doc.imagePath != null &&
                    File(doc.imagePath!).existsSync()) ...[
                  const SizedBox(height: 14),
                  Text('FOTO DOKUMEN',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                        letterSpacing: 0.4,
                      )),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(doc.imagePath!),
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmDelete(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.danger),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    label: Text(
                      'Hapus Dokumen',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dCtx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Hapus dokumen?',
          style: GoogleFonts.plusJakartaSans(
              fontSize: 16, fontWeight: FontWeight.w700),
        ),
        content: Text(
          '${doc.documentType} akan dihapus permanen.',
          style: GoogleFonts.plusJakartaSans(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx, false),
            child: Text('Batal',
                style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dCtx, true),
            child: Text('Hapus',
                style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      onDelete();
      Navigator.pop(context);
    }
  }
}
