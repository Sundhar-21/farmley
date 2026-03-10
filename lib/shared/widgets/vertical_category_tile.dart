import 'package:flutter/material.dart';
import 'package:farmconnect/shared/design_constants.dart';
import 'package:google_fonts/google_fonts.dart';

class SelectedTabPainter extends CustomPainter {
  final Color color;

  SelectedTabPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const r = 16.0; // Top corner radius
    const flare = 6.0; // Bottom flare amount

    final path = Path();
    
    // Start at bottom left edge (the very tip of the left flare)
    path.moveTo(0, size.height);
    
    // Curve INWARD and UPWARD to the main body's left edge
    path.quadraticBezierTo(flare, size.height, flare, size.height - flare);
    
    // Line up towards top-left
    path.lineTo(flare, r);
    
    // Top-left corner (standard)
    path.quadraticBezierTo(flare, 0, flare + r, 0);
    
    // Line across top
    path.lineTo(size.width - flare - r, 0);
    
    // Top-right corner (standard)
    path.quadraticBezierTo(size.width - flare, 0, size.width - flare, r);
    
    // Line down to bottom-right
    path.lineTo(size.width - flare, size.height - flare);
    
    // Outward flare at bottom right (curve OUTWARD to the right tip)
    path.quadraticBezierTo(size.width - flare, size.height, size.width, size.height);
    
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class VerticalCategoryTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final double width;

  const VerticalCategoryTile({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.width = 75.0,
    this.isVertical = true,
  });

  final bool isVertical;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.symmetric(horizontal: 0.5),
        width: width,
        height: 60,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (isSelected)
              Positioned(
                left: -6.0, // Match the flare size to pull it outside the bounds
                right: -6.0,
                top: 0,
                bottom: 0,
                child: CustomPaint(
                  painter: SelectedTabPainter(color: Colors.white),
                ),
              )
            else
              Container(
                decoration: const BoxDecoration(
                  color: DesignColors.filterBackground,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
              ),
            
            // Content
            Center(
              child: isVertical 
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        size: 20,
                        color: Colors.black,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        label,
                        style: GoogleFonts.outfit(
                          fontSize: 9,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        size: 18,
                        color: Colors.black,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          label,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
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
