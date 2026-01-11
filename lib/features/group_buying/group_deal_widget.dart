import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Social Group Buying (Team Purchase)
///
/// Displays "Buy alone" vs "Buy with a friend" pricing, a countdown timer,
/// and a Share Link button that copies a mock deep-link to clipboard.
enum GroupDealOption { solo, group }

class GroupDealWidget extends StatefulWidget {
  final String productId;

  /// Example: 100
  final double soloPrice;

  /// Example: 80
  final double groupPrice;

  /// When the deal expires.
  final DateTime endsAt;

  final GroupDealOption selected;
  final ValueChanged<GroupDealOption> onChanged;

  const GroupDealWidget({
    super.key,
    required this.productId,
    required this.soloPrice,
    required this.groupPrice,
    required this.endsAt,
    required this.selected,
    required this.onChanged,
  });

  @override
  State<GroupDealWidget> createState() => _GroupDealWidgetState();
}

class _GroupDealWidgetState extends State<GroupDealWidget> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final now = DateTime.now();
    final diff = widget.endsAt.difference(now);
    setState(() {
      _remaining = diff.isNegative ? Duration.zero : diff;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _format(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _share(BuildContext context) async {
    // Mock deep-link; in production use Firebase Dynamic Links / app links.
    final dealId = DateTime.now().millisecondsSinceEpoch.toString();
    final link = 'mcommerce://group-deal?dealId=$dealId&productId=${widget.productId}&price=${widget.groupPrice.toStringAsFixed(2)}';

    await Clipboard.setData(ClipboardData(text: link));

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Invite link copied to clipboard'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expired = _remaining == Duration.zero;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.people_alt_outlined),
              const SizedBox(width: 8),
              Text(
                'Group Deal',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: expired ? Colors.grey.shade200 : const Color(0xFF2A2D3E),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  expired ? 'Expired' : _format(_remaining),
                  style: TextStyle(
                    color: expired ? Colors.black54 : Colors.white,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _PriceOption(
                  title: 'Buy alone',
                  price: widget.soloPrice,
                  subtitle: 'Instant checkout',
                  selected: widget.selected == GroupDealOption.solo,
                  onTap: expired ? null : () => widget.onChanged(GroupDealOption.solo),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PriceOption(
                  title: 'Buy with a friend',
                  price: widget.groupPrice,
                  subtitle: 'Unlock discount together',
                  selected: widget.selected == GroupDealOption.group,
                  onTap: expired ? null : () => widget.onChanged(GroupDealOption.group),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: expired ? null : () => _share(context),
              icon: const Icon(Icons.link),
              label: const Text('Share Link'),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceOption extends StatelessWidget {
  final String title;
  final double price;
  final String subtitle;
  final bool selected;
  final VoidCallback? onTap;

  const _PriceOption({
    required this.title,
    required this.price,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? const Color(0xFF2A2D3E) : Colors.grey.shade200;
    final bg = selected ? const Color(0xFF2A2D3E).withOpacity(0.06) : Colors.white;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: selected ? 1.5 : 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                  Icon(
                    selected ? Icons.check_circle : Icons.radio_button_unchecked,
                    size: 18,
                    color: selected ? const Color(0xFF2A2D3E) : Colors.grey,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '\$${price.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: selected ? const Color(0xFF2A2D3E) : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
