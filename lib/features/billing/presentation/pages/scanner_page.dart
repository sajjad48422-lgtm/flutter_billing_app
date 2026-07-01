import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import 'package:vibration/vibration.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage>
    with WidgetsBindingObserver {
  late final MobileScannerController controller;
  bool _isScanned = false;

  // جلوگیری از فراخوانی همزمان start/stop روی کنترلر
  bool _isStarting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      returnImage: false,
      autoStart: false, // خودمون دستی استارت می‌کنیم
    );
    _startCamera();
  }

  Future<void> _startCamera() async {
    if (_isStarting) return;
    _isStarting = true;
    try {
      await controller.start();
    } catch (_) {
      // اگر دوربین در دسترس نبود (مثلاً هنوز توسط صفحه قبلی آزاد نشده)
      // یک بار دیگر بعد از یک تأخیر کوتاه تلاش می‌کنیم
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        try {
          await controller.start();
        } catch (_) {
          // اگر باز هم شکست خورد، کاربر می‌تواند با دکمه تلاش مجدد امتحان کند
        }
      }
    } finally {
      _isStarting = false;
    }
  }

  Future<void> _stopCamera() async {
    try {
      await controller.stop();
    } catch (_) {
      // کنترلر ممکن است از قبل متوقف یا dispose شده باشد
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // اگر کنترلر هنوز ساخته نشده یا دوربین متصل نیست، کاری نکن
    if (!controller.value.isInitialized && state != AppLifecycleState.resumed) {
      return;
    }

    switch (state) {
      case AppLifecycleState.resumed:
        _startCamera();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        _stopCamera();
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isScanned) return;
    final List<Barcode> barcodes = capture.barcodes;

    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        _isScanned = true;
        // Vibrate
        final hasVibrator = await Vibration.hasVibrator();
        if (hasVibrator == true) {
          Vibration.vibrate();
        }

        if (mounted) {
          context.pop(barcode.rawValue);
        }
        break; // Only take first one
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.chevron_left,
                size: 28, color: Theme.of(context).primaryColor),
            onPressed: () => context.pop(),
          ),
          title: const Text('Scan Barcode',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: _onDetect,
            errorBuilder: (context, error) {
              // به‌جای علامت "!" ثابت، یک پیام قابل فهم با دکمه تلاش مجدد نشان بده
              return Container(
                color: Colors.black,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.camera_alt_outlined,
                          color: Colors.white54, size: 48),
                      const SizedBox(height: 16),
                      const Text(
                        'دوربین در دسترس نیست',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _startCamera,
                        child: const Text('تلاش مجدد'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // Simple border overlay manually
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.transparent, width: 0),
            ),
            child: Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green, width: 2),
                  // borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _corner(0),
                          _corner(1),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _corner(3),
                          _corner(2),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Text(
              'Align barcode within frame',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _corner(int index) {
    return Container(
      width: 15,
      height: 15,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: Colors.white, width: 2),
      ),
    );
  }
}
