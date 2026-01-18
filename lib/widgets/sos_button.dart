import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';

/// Custom SOS Button with different states
class SOSButton extends StatefulWidget {
  final String state;
  final Function(String) onStateChanged;
  
  const SOSButton({
    super.key,
    required this.state,
    required this.onStateChanged,
  });

  @override
  State<SOSButton> createState() => _SOSButtonState();
}

class _SOSButtonState extends State<SOSButton> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _pressController;
  Timer? _holdTimer;
  bool _isHolding = false;
  double _holdProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    if (widget.state == AppConstants.sosActive) {
      _pulseController.repeat();
    }
  }

  @override
  void didUpdateWidget(SOSButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state == AppConstants.sosActive) {
      _pulseController.repeat();
    } else {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _pressController.dispose();
    _holdTimer?.cancel();
    super.dispose();
  }

  void _startHold() {
    if (widget.state != AppConstants.sosReady) return;
    
    setState(() {
      _isHolding = true;
      _holdProgress = 0.0;
    });
    
    // Haptic feedback
    HapticFeedback.mediumImpact();
    
    _holdTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        _holdProgress += 0.05 / 3; // 3 seconds total
      });
      
      if (_holdProgress >= 1.0) {
        timer.cancel();
        _triggerSOS();
      }
    });
    
    _pressController.forward();
  }

  void _endHold() {
    if (!_isHolding) return;
    
    setState(() {
      _isHolding = false;
      _holdProgress = 0.0;
    });
    
    _holdTimer?.cancel();
    _pressController.reverse();
  }

  void _triggerSOS() {
    HapticFeedback.heavyImpact();
    widget.onStateChanged(AppConstants.sosActive);
  }

  Widget _buildButtonContent() {
    switch (widget.state) {
      case AppConstants.sosLocked:
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.primaryColor,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Text(
                'SOS',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Positioned(
                bottom: 30,
                right: 30,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                  ),
                  child: const Icon(
                    Icons.lock,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        );
        
      case AppConstants.sosReady:
        return AnimatedBuilder(
          animation: _pressController,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 - (_pressController.value * 0.05),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryColor,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Text(
                      'READY',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (_isHolding)
                      Positioned.fill(
                        child: CircularProgressIndicator(
                          value: _holdProgress,
                          strokeWidth: 8,
                          backgroundColor: Colors.white.withValues(alpha: 0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
        
      case AppConstants.sosActive:
        return AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3 + (_pulseController.value * 0.3)),
                    blurRadius: 20 + (_pulseController.value * 10),
                    spreadRadius: 5 + (_pulseController.value * 5),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1 + (_pulseController.value * 0.1)),
                ),
                child: const Center(
                  child: Text(
                    '00:12',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            );
          },
        );
        
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.state == AppConstants.sosLocked 
          ? () => widget.onStateChanged(AppConstants.sosReady)
          : null,
      onLongPressStart: widget.state == AppConstants.sosReady 
          ? (_) => _startHold()
          : null,
      onLongPressEnd: widget.state == AppConstants.sosReady 
          ? (_) => _endHold()
          : null,
      child: SizedBox(
        width: AppConstants.sosButtonSize,
        height: AppConstants.sosButtonSize,
        child: _buildButtonContent(),
      ),
    );
  }
}