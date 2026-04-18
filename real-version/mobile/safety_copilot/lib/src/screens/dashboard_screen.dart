import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../widgets/animated_safety_hero.dart';
import '../widgets/route_globe.dart';
import '../widgets/security_backdrop.dart';
import '../widgets/sos_impact_overlay.dart';
import '../widgets/threat_radar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _circleCtrl = TextEditingController(text: 'Family');
  final _memberPhoneCtrl = TextEditingController();
  final _memberLabelCtrl = TextEditingController(text: 'Guardian');
  final _destinationCtrl = TextEditingController(text: 'Home');
  final _latCtrl = TextEditingController(text: '28.6139');
  final _lngCtrl = TextEditingController(text: '77.2090');
  final _etaCtrl = TextEditingController(text: '1800');

  String? _selectedCircleId;

  @override
  void dispose() {
    _circleCtrl.dispose();
    _memberPhoneCtrl.dispose();
    _memberLabelCtrl.dispose();
    _destinationCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    _etaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final activeCircleId =
        _selectedCircleId ??
        (state.circles.isNotEmpty ? state.circles.first.id : null);
    final unacknowledged = state.alerts
        .where((alert) => !alert.isAcknowledged)
        .toList();
    final criticalVisualAlert = unacknowledged.any(
      (alert) =>
          alert.type.toLowerCase().contains('sos') ||
          alert.severity.toLowerCase() == 'critical',
    );
    final elevatedVisualAlert = unacknowledged.any(
      (alert) =>
          alert.severity.toLowerCase() == 'high' ||
          alert.severity.toLowerCase() == 'critical',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mission Console'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_rounded),
            onPressed: state.busy ? null : state.refresh,
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: state.busy ? null : state.logout,
          ),
        ],
      ),
      body: SecurityBackdrop(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: state.refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                children: [
                  const AnimatedSafetyHero(),
                  const SizedBox(height: 10),
                  _panel(
                    child: _buildSituationalCore(state),
                  ).animate().fadeIn(duration: 340.ms),
                  const SizedBox(height: 12),
                  _panel(
                    child: _buildStatusBoard(state),
                  ).animate().fadeIn(delay: 80.ms, duration: 360.ms),
                  const SizedBox(height: 12),
                  _panel(
                    child: _buildCircleOps(state, activeCircleId),
                  ).animate().fadeIn(delay: 120.ms, duration: 380.ms),
                  const SizedBox(height: 12),
                  _panel(
                    child: _buildTripOps(state, activeCircleId),
                  ).animate().fadeIn(delay: 180.ms, duration: 380.ms),
                  const SizedBox(height: 12),
                  _panel(
                    child: _buildSosConsole(state),
                  ).animate().fadeIn(delay: 240.ms, duration: 380.ms),
                  const SizedBox(height: 12),
                  _panel(
                    child: _buildAlerts(state),
                  ).animate().fadeIn(delay: 300.ms, duration: 380.ms),
                ],
              ),
            ),
            Positioned.fill(
              child: SosImpactOverlay(
                visible: elevatedVisualAlert,
                critical: criticalVisualAlert,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSituationalCore(AppState state) {
    final activeTrip = state.activeTrip;
    final pendingAlerts = state.alerts.where((alert) => !alert.isAcknowledged);
    final low = pendingAlerts
        .where((a) => a.severity.toLowerCase() == 'low')
        .length;
    final medium = pendingAlerts
        .where((a) => a.severity.toLowerCase() == 'medium')
        .length;
    final high = pendingAlerts
        .where((a) => a.severity.toLowerCase() == 'high')
        .length;
    final critical = pendingAlerts
        .where((a) => a.severity.toLowerCase() == 'critical')
        .length;
    final destinationName =
        activeTrip?.destinationName ?? _destinationCtrl.text.trim();
    final destinationLat =
        activeTrip?.destinationLat ??
        double.tryParse(_latCtrl.text.trim()) ??
        0;
    final destinationLng =
        activeTrip?.destinationLng ??
        double.tryParse(_lngCtrl.text.trim()) ??
        0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title('Situational Hologram'),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 640;
            final globe = _visualCard(
              child: SizedBox(
                height: 220,
                child: RouteGlobe(
                  destinationName: destinationName,
                  destinationLat: destinationLat,
                  destinationLng: destinationLng,
                  active: activeTrip != null,
                ),
              ),
            );
            final radar = _visualCard(
              child: SizedBox(
                height: 220,
                child: ThreatRadar(
                  active: activeTrip != null,
                  lowCount: low,
                  mediumCount: medium,
                  highCount: high,
                  criticalCount: critical,
                ),
              ),
            );

            if (compact) {
              return Column(
                children: [globe, const SizedBox(height: 10), radar],
              );
            }

            return Row(
              children: [
                Expanded(child: globe),
                const SizedBox(width: 10),
                Expanded(child: radar),
              ],
            );
          },
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _signalPill(
              'Route',
              activeTrip == null ? 'Idle' : activeTrip.status.toUpperCase(),
              const Color(0xFF00E6B4),
            ),
            _signalPill(
              'Threat',
              critical > 0
                  ? 'CRITICAL'
                  : high > 0
                  ? 'HIGH'
                  : medium > 0
                  ? 'GUARDED'
                  : 'STABLE',
              critical > 0
                  ? const Color(0xFFFF6363)
                  : high > 0
                  ? const Color(0xFFFFB15A)
                  : const Color(0xFF8BEED0),
            ),
            _signalPill(
              'Watchers',
              '${state.devices.length}',
              const Color(0xFF79DFFF),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBoard(AppState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Operator: ${state.user?.name ?? "Traveler"}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 6),
        Text(
          state.status,
          style: const TextStyle(
            color: Color(0xFF93FFE9),
            fontWeight: FontWeight.w700,
          ),
        ),
        if (state.error != null) ...[
          const SizedBox(height: 8),
          Text(
            state.error!,
            style: const TextStyle(
              color: Color(0xFFFFA8A8),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _chip('Circles', '${state.circles.length}'),
            _chip('Devices', '${state.devices.length}'),
            _chip('Alerts', '${state.alerts.length}'),
            _chip('Trip', state.activeTrip?.status ?? 'idle'),
          ],
        ),
      ],
    );
  }

  Widget _buildCircleOps(AppState state, String? activeCircleId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title('Trusted Circle Control'),
        const SizedBox(height: 12),
        TextField(
          controller: _circleCtrl,
          decoration: const InputDecoration(
            labelText: 'Circle Name',
            prefixIcon: Icon(Icons.groups_2_outlined),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: state.busy
                ? null
                : () => state.createCircle(_circleCtrl.text.trim()),
            child: const Text('Create Circle'),
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          key: ValueKey(
            'circle-${activeCircleId ?? 'none'}-${state.circles.length}',
          ),
          initialValue: state.circles.any((c) => c.id == activeCircleId)
              ? activeCircleId
              : null,
          items: state.circles
              .map(
                (circle) => DropdownMenuItem(
                  value: circle.id,
                  child: Text('${circle.name} (${circle.memberCount})'),
                ),
              )
              .toList(),
          onChanged: (value) => setState(() => _selectedCircleId = value),
          decoration: const InputDecoration(
            labelText: 'Active Circle',
            prefixIcon: Icon(Icons.adjust_rounded),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _memberPhoneCtrl,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Member Phone',
            prefixIcon: Icon(Icons.phone_android_rounded),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _memberLabelCtrl,
          decoration: const InputDecoration(
            labelText: 'Member Label',
            prefixIcon: Icon(Icons.badge_outlined),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: state.busy || activeCircleId == null
                ? null
                : () => state.addMember(
                    circleId: activeCircleId,
                    phone: _memberPhoneCtrl.text.trim(),
                    label: _memberLabelCtrl.text.trim(),
                  ),
            child: const Text('Add Trusted Member'),
          ),
        ),
      ],
    );
  }

  Widget _buildTripOps(AppState state, String? activeCircleId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title('Trip Orchestrator'),
        const SizedBox(height: 12),
        TextField(
          controller: _destinationCtrl,
          decoration: const InputDecoration(
            labelText: 'Destination',
            prefixIcon: Icon(Icons.place_outlined),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _latCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Latitude',
                  prefixIcon: Icon(Icons.my_location_rounded),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _lngCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Longitude',
                  prefixIcon: Icon(Icons.explore_outlined),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _etaCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'ETA (seconds)',
            prefixIcon: Icon(Icons.timer_outlined),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton(
              onPressed:
                  state.busy ||
                      activeCircleId == null ||
                      state.activeTrip != null
                  ? null
                  : () => state.startTrip(
                      circleId: activeCircleId,
                      destinationName: _destinationCtrl.text.trim(),
                      destinationLat:
                          double.tryParse(_latCtrl.text.trim()) ?? 0,
                      destinationLng:
                          double.tryParse(_lngCtrl.text.trim()) ?? 0,
                      etaSeconds: int.tryParse(_etaCtrl.text.trim()) ?? 1800,
                    ),
              child: const Text('Start Trip'),
            ),
            OutlinedButton(
              onPressed: state.busy || state.activeTrip == null
                  ? null
                  : state.sendLocationPing,
              child: const Text('Send Location'),
            ),
            OutlinedButton(
              onPressed: state.busy || state.activeTrip == null
                  ? null
                  : state.markArrived,
              child: const Text('Arrived'),
            ),
            OutlinedButton(
              onPressed: state.busy || state.activeTrip == null
                  ? null
                  : state.endTrip,
              child: const Text('End Trip'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSosConsole(AppState state) {
    final disabled = state.busy || state.activeTrip == null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title('Emergency Console'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _dangerButton(
                label: 'SOS',
                icon: Icons.sos_rounded,
                color: const Color(0xFFFF6B6B),
                disabled: disabled,
                onTap: () => state.triggerSos(silent: false),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _dangerButton(
                label: 'Silent SOS',
                icon: Icons.visibility_off_rounded,
                color: const Color(0xFFFFB15A),
                disabled: disabled,
                onTap: () => state.triggerSos(silent: true),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAlerts(AppState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title('Alert Feed'),
        const SizedBox(height: 8),
        if (state.alerts.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('No active alerts. System stable.'),
          ),
        for (final alert in state.alerts.take(12))
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: const Color(0x99122638),
              border: Border.all(color: const Color(0x80407791)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  alert.isAcknowledged
                      ? Icons.verified_rounded
                      : Icons.warning_amber_rounded,
                  color: alert.isAcknowledged
                      ? const Color(0xFF90FBD1)
                      : const Color(0xFFFFC98B),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${alert.type.toUpperCase()} • ${alert.severity.toUpperCase()}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFD8F3FF),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(alert.message),
                    ],
                  ),
                ),
                if (!alert.isAcknowledged)
                  IconButton(
                    icon: const Icon(Icons.done_all_rounded),
                    onPressed: state.busy
                        ? null
                        : () => state.acknowledgeAlert(alert.id),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _panel({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x8845748E)),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xC9102436), Color(0xB4071727)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0x55003F5C),
            blurRadius: 20,
            spreadRadius: 1,
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _visualCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x5B5D8AA7)),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xA2092132), Color(0x77040F1E)],
        ),
      ),
      child: Padding(padding: const EdgeInsets.all(10), child: child),
    );
  }

  Widget _title(String value) {
    return Text(value, style: Theme.of(context).textTheme.titleLarge);
  }

  Widget _chip(String label, String value) {
    return Chip(label: Text('$label: $value'));
  }

  Widget _signalPill(String label, String value, Color tone) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: tone.withValues(alpha: 0.15),
        border: Border.all(color: tone.withValues(alpha: 0.45)),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          color: Color(0xFFD9F2FF),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _dangerButton({
    required String label,
    required IconData icon,
    required Color color,
    required bool disabled,
    required VoidCallback onTap,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.0),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOut,
      builder: (context, glow, _) {
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: disabled ? 0.08 : 0.28 * glow),
                blurRadius: 18,
                spreadRadius: 1,
              ),
            ],
          ),
          child: FilledButton.icon(
            onPressed: disabled ? null : onTap,
            style: FilledButton.styleFrom(
              backgroundColor: disabled ? const Color(0xFF2A3A46) : color,
              foregroundColor: const Color(0xFF091015),
            ),
            icon: Icon(icon),
            label: Text(label),
          ),
        );
      },
    );
  }
}
