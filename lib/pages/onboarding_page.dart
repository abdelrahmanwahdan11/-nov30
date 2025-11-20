import 'dart:async';

import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../l10n/app_localizations.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, required this.appController});

  final AppController appController;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController controller = PageController();
  int currentIndex = 0;
  Timer? timer;

  final pageKeys = const [
    'onboarding.story1',
    'onboarding.story2',
    'onboarding.story3',
  ];

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      final next = (currentIndex + 1) % pageKeys.length;
      controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF909D92), Color(0xFFDDE3D6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 80),
              Expanded(
                child: PageView.builder(
                  controller: controller,
                  onPageChanged: (index) => setState(() => currentIndex = index),
                  itemCount: pageKeys.length,
                  itemBuilder: (context, index) {
                    return AnimatedOpacity(
                      duration: const Duration(milliseconds: 500),
                      opacity: currentIndex == index ? 1 : 0.5,
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedScale(
                              duration: const Duration(milliseconds: 600),
                              scale: currentIndex == index ? 1 : 0.8,
                              child: Icon(
                                Icons.water_drop_outlined,
                                size: 120,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(height: 32),
                            Text(
                              strings.t(pageKeys[index]),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pageKeys.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    height: 8,
                    width: currentIndex == index ? 32 : 8,
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(currentIndex == index ? 1 : 0.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () async {
                        await widget.appController.completeOnboarding();
                        if (context.mounted) {
                          Navigator.pushReplacementNamed(context, '/auth/login');
                        }
                      },
                      child: Text(strings.t('onboarding.skip')),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final next = (currentIndex + 1).clamp(0, pageKeys.length - 1);
                        if (next == currentIndex) {
                          await widget.appController.completeOnboarding();
                          if (context.mounted) {
                            Navigator.pushReplacementNamed(context, '/auth/login');
                          }
                        } else {
                          controller.nextPage(
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: Text(strings.t('onboarding.next')),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
