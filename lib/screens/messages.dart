
import 'package:flutter/material.dart';
import '../widgets/bottom_navigation.dart';
import 'chat_detail.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  static const Color background = Color(0xFF101010);
  static const Color surface = Color(0xFF1C1A1A);
  static const Color mauve = Color(0xFFB78A9B);
  static const Color mutedText = Color(0xFFB8B2B5);

  final List<Map<String, String>> alerts = const [
    {
      'title': 'Dr. Zana would like your rating!',
      'message':
          'Share your experience with Dr. Zana and help other patients.',
    },
    {
      'title':
          'Dr. Ken is now available. Would you like to book a consult?',
      'message':
          'Dr. Ken is available for consultation. You can explore booking options.',
    },
    {
      'title': 'Rate United Health clinic and earn 5 points.',
      'message':
          'Leave a rating for United Health clinic to earn 5 points.',
    },
  ];

  final List<String> hospitals = const [
    'United Health Clinic - Cancer Society',
    'Davao International Hospital - Dermatology',
    'Davao United Doctors - Internal Medicine',
    'Davao United Doctors - General Health',
    'Dr. Ken Lee and Doctors Clinic',
    'International Chinese Hospital',
    'Metro Clinic - Davao Region',
    'Philippine Internal Hospital - Southern Mindanao',
  ];

  void _openDetails(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MessageDetailScreen(
          title: title,
          message: message,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                children: [
                  // Header
                  Row(
                    children: [
                      Material(
                        color: surface,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/dashboard',
                              (route) => false,
                            );
                          },
                          child: const SizedBox(
                            width: 44,
                            height: 44,
                            child: Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                              size: 21,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Messages',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Your notifications and conversations',
                              style: TextStyle(
                                color: mutedText,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: mauve.withAlpha(30),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.mark_chat_unread_outlined,
                          color: mauve,
                          size: 22,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Alerts heading
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Alerts',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: mauve.withAlpha(30),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Notifications',
                          style: TextStyle(
                            color: mauve,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Alert cards
                  ...alerts.map((alert) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Material(
                        color: surface,
                        borderRadius: BorderRadius.circular(18),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => _openDetails(
                            context,
                            title: alert['title']!,
                            message: alert['message']!,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: mauve.withAlpha(28),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.notifications_active_outlined,
                                    color: mauve,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 13),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        alert['title']!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          height: 1.4,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        alert['message']!,
                                        style: const TextStyle(
                                          color: mutedText,
                                          fontSize: 12,
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: mutedText,
                                  size: 22,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 24),

                  // Chats heading
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Chats',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '${hospitals.length} conversations',
                        style: const TextStyle(
                          color: mutedText,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Conversation list
                  Container(
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: List.generate(hospitals.length, (index) {
                        final hospital = hospitals[index];

                        return Column(
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChatDetailScreen(
                                      hospital: hospital,
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 13,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 46,
                                      height: 46,
                                      decoration: BoxDecoration(
                                        color: mauve.withAlpha(28),
                                        borderRadius:
                                            BorderRadius.circular(16),
                                      ),
                                      child: const Icon(
                                        Icons.local_hospital_outlined,
                                        color: mauve,
                                        size: 23,
                                      ),
                                    ),
                                    const SizedBox(width: 13),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            hospital,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              height: 1.4,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          const Text(
                                            'Tap to open conversation',
                                            style: TextStyle(
                                              color: mutedText,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.chevron_right_rounded,
                                      color: mutedText,
                                      size: 22,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (index != hospitals.length - 1)
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 73),
                                child: Divider(
                                  height: 1,
                                  thickness: 0.5,
                                  color: Colors.white.withAlpha(18),
                                ),
                              ),
                          ],
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),

            // Messages tab is active.
            const HealthLineBottomNavigation(
              selectedIndex: 2,
            ),
          ],
        ),
      ),
    );
  }
}

// Alert details screen
class MessageDetailScreen extends StatelessWidget {
  final String title;
  final String message;

  const MessageDetailScreen({
    super.key,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MessagesScreen.background,
      appBar: AppBar(
        backgroundColor: MessagesScreen.background,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Notification',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: MessagesScreen.mauve.withAlpha(30),
                borderRadius: BorderRadius.circular(17),
              ),
              child: const Icon(
                Icons.notifications_active_outlined,
                color: MessagesScreen.mauve,
                size: 27,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                color: MessagesScreen.mutedText,
                fontSize: 14,
                height: 1.7,
              ),
            ),
          ],
        ),
      ),
    );
  }
}