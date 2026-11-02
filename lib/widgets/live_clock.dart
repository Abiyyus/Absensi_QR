import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';
import '../core/time_utils.dart';

/// Jam digital real-time (HH:mm:ss) yang berganti tepat tiap detik.
class LiveClock extends StatefulWidget {
  final Color color;
  final double fontSize;
  final bool showDate;
  final CrossAxisAlignment align;

  const LiveClock({
    super.key,
    this.color = Colors.black,
    this.fontSize = 40,
    this.showDate = true,
    this.align = CrossAxisAlignment.start,
  });

  @override
  State<LiveClock> createState() => _LiveClockState();
}

class _LiveClockState extends State<LiveClock> {
  late final Stream<DateTime> _stream = tiapDetik();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DateTime>(
      stream: _stream,
      initialData: DateTime.now(),
      builder: (context, snap) {
        final now = snap.data ?? DateTime.now();
        return Column(
          crossAxisAlignment: widget.align,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              Fmt.jam.format(now),
              style: TextStyle(
                color: widget.color,
                fontSize: widget.fontSize,
                fontWeight: FontWeight.w800,
                height: 1.1,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            if (widget.showDate) ...[
              const SizedBox(height: 4),
              Text(
                '${Fmt.tanggal.format(now)} • ${now.timeZoneName}',
                style: TextStyle(
                  color: widget.color.withValues(alpha: 0.85),
                  fontSize: 13,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
