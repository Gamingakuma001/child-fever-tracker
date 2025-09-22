import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WarningPage extends StatefulWidget {
  const WarningPage({super.key});

  @override
  State<WarningPage> createState() => _WarningPageState();
}

class _WarningPageState extends State<WarningPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;

  final warningSigns = [
    {"icon": "❌🍼", "text": "Refusing to drink or feed"},
    {"icon": "🤮", "text": "Vomiting everything (unable to keep anything down)"},
    {"icon": "⚡", "text": "Convulsions or seizures"},
    {"icon": "😴", "text": "Extreme tiredness, lethargy, or unconsciousness"},
    {"icon": "😤", "text": "Rapid or difficult breathing"},
    {"icon": "🚫💧", "text": "Reduced or no urine output"},
    {"icon": "❄🖐🦶", "text": "Cold hands and feet"},
  ];

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3F3),
      appBar: AppBar(
        backgroundColor: Colors.red.shade400,
        centerTitle: true,
        title: Text(
          'Warning Signs',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 20),
            ...warningSigns.map((sign) => _buildWarningCard(sign)),
            const SizedBox(height: 20),
            _buildEmergencyFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "🚨 Medical Alert",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Watch these signs in children under 2–3 years with fever. If any appear, seek immediate care.",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningCard(Map<String, String> sign) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedBuilder(
            animation: _glowController,
            builder: (context, child) {
              double glow = _glowController.value;
              return Text(
                sign["icon"] ?? "",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.red.withOpacity(0.9 * glow),
                      blurRadius: 14 + glow * 8,
                      offset: const Offset(0, 0),
                    ),
                    Shadow(
                      color: Colors.redAccent.withOpacity(0.9 * glow),
                      blurRadius: 20 + glow * 10,
                      offset: const Offset(0, 0),
                    ),
                    Shadow(
                      color: Colors.redAccent.withOpacity(0.25 * glow),
                      blurRadius: 30 + glow * 10,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              sign["text"] ?? "",
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade300,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.red.shade200,
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.local_hospital, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "If ANY of these signs appear, visit the nearest hospital immediately. Don’t delay care.",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}