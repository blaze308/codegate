import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:math';
import 'package:qr_flutter/qr_flutter.dart';
import 'create_event_screen.dart';
import 'scan_qr_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if we're on web platform
    final isWeb = identical(0, 0.0);

    // Get screen width to determine layout
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 1000;
    final isMediumScreen = screenWidth > 600 && screenWidth <= 1000;

    return Scaffold(
      appBar: isWeb ? _buildWebAppBar(context) : null,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (isWeb) _buildHeroSection(context, isWideScreen),
              if (!isWeb) _buildMobileContent(context),
              if (isWeb)
                _buildFeaturesSection(context, isWideScreen, isMediumScreen),
              if (isWeb) _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildWebAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Theme.of(context).colorScheme.primary,
      title: Row(
        children: [
          Image.asset('assets/images/codegate logo.png', height: 40),
          const SizedBox(width: 12),
          Text(
            'CodeGate',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () {}, child: const Text('Features')),
        TextButton(onPressed: () {}, child: const Text('About')),
        TextButton(onPressed: () {}, child: const Text('Contact')),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateEventScreen(),
              ),
            );
          },
          child: const Text('Get Started'),
        ),
        const SizedBox(width: 24),
      ],
    );
  }

  Widget _buildHeroSection(BuildContext context, bool isWideScreen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isWideScreen ? 120 : 24,
        vertical: 80,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.primary.withOpacity(0.05),
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Modern Event Management\nMade Simple',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Create, manage, and track your events with ease.\nSecure QR code ticketing system for seamless entry management.',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateEventScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Create Event'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ScanQRScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Join Event'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isWideScreen) ...[
            const SizedBox(width: 100),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background glow effect
                  Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.2),
                          Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  // Rotating animation container
                  TweenAnimationBuilder(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(seconds: 20),
                    builder: (context, double value, child) {
                      return Transform.rotate(
                        angle: value * 2 * 3.14159,
                        child: child,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                      child: QrImageView(
                        data: 'https://codegate.example.com/demo-event',
                        version: QrVersions.auto,
                        size: 300.0,
                        backgroundColor: Colors.white,
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        eyeStyle: QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        dataModuleStyle: QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        embeddedImage: AssetImage(
                          'assets/images/codegate logo.png',
                        ),
                        embeddedImageStyle: QrEmbeddedImageStyle(
                          size: const Size(60, 60),
                        ),
                      ),
                    ),
                  ),
                  // Floating elements around QR code
                  ...List.generate(6, (index) {
                    final angle = index * (3.14159 * 2 / 6);
                    return Positioned(
                      left: 200 + 180 * cos(angle),
                      top: 200 + 180 * sin(angle),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          [
                            Icons.event,
                            Icons.qr_code,
                            Icons.security,
                            Icons.people,
                            Icons.analytics,
                            Icons.celebration,
                          ][index],
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(
    BuildContext context,
    bool isWideScreen,
    bool isMediumScreen,
  ) {
    final features = [
      {
        'icon': Icons.qr_code,
        'title': 'QR Code Ticketing',
        'description': 'Generate and scan secure QR codes for event access',
      },
      {
        'icon': Icons.event,
        'title': 'Event Management',
        'description': 'Create and manage events with detailed information',
      },
      {
        'icon': Icons.analytics,
        'title': 'Analytics',
        'description': 'Track attendance and gather event insights',
      },
      {
        'icon': Icons.security,
        'title': 'Secure Access',
        'description': 'Ensure only valid tickets are accepted',
      },
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isWideScreen ? 120 : 24,
        vertical: 80,
      ),
      child: Column(
        children: [
          Text(
            'Features',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 60),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isWideScreen ? 4 : (isMediumScreen ? 2 : 1),
              crossAxisSpacing: 30,
              mainAxisSpacing: 30,
              mainAxisExtent: 220,
            ),
            itemCount: features.length,
            itemBuilder: (context, index) {
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        features[index]['icon'] as IconData,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        features[index]['title'] as String,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        features[index]['description'] as String,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      color: Colors.grey[100],
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/codegate logo.png', height: 30),
              const SizedBox(width: 12),
              Text(
                'CodeGate',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(onPressed: () {}, child: const Text('Privacy Policy')),
              const SizedBox(width: 24),
              TextButton(
                onPressed: () {},
                child: const Text('Terms of Service'),
              ),
              const SizedBox(width: 24),
              TextButton(onPressed: () {}, child: const Text('Contact Us')),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            '© ${DateTime.now().year} CodeGate. All rights reserved.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.qr_code_rounded,
            size: 120,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'CodeGate',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create and manage events with ease',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateEventScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Create Event'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ScanQRScreen()),
                );
              },
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Join Event'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
