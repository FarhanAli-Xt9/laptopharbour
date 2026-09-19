import 'package:flutter/material.dart';
import '../models/laptop.dart';
import '../services/mock_laptop_data.dart';
import '../theme/colors.dart';
import '../widgets/glass_card.dart';
import 'detail_screen.dart';


class AIFinderScreen extends StatefulWidget {
  const AIFinderScreen({super.key});

  @override
  State<AIFinderScreen> createState() => _AIFinderScreenState();
}

class ChatMessage {
  final String text;
  final bool isUser;
  final List<Laptop>? recommendedLaptops;

  ChatMessage({required this.text, required this.isUser, this.recommendedLaptops});
}

class _AIFinderScreenState extends State<AIFinderScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  final List<String> _presets = [
    'Best developer rig under \$2000',
    'Gaming beast with high display refresh',
    'Ultra-portable for travel with long battery',
    'Top workstation for 4K video rendering',
  ];

  @override
  void initState() {
    super.initState();
    // Welcome message
    _messages.add(
      ChatMessage(
        text: "Greetings, Captain. I am the Harbour AI Assistant. Tell me your budget, preferred usage, or target specifications, and I will parse our fleet diagnostics to find your ideal match.",
        isUser: false,
      ),
    );
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage(String query) {
    if (query.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: query, isUser: true));
      _isTyping = true;
    });
    _textController.clear();
    _scrollToBottom();

    // AI thinking animation delay
    Future.delayed(const Duration(seconds: 1), () {
      String responseText = '';
      List<Laptop> recs = [];

      final lowerQuery = query.toLowerCase();
      if (lowerQuery.contains('developer') || lowerQuery.contains('coding') || lowerQuery.contains('programming') || lowerQuery.contains('dev')) {
        recs = mockLaptops.where((l) => l.codingScore >= 88).toList();
        responseText = "Parsing fleet metrics for Development... I found ${recs.length} rigs scoring highly on compilation and typing diagnostics. The MacBook Pro 16 or ThinkPad Carbon X1 are standout selections.";
      } else if (lowerQuery.contains('gaming') || lowerQuery.contains('game') || lowerQuery.contains('fps')) {
        recs = mockLaptops.where((l) => l.gamingScore >= 90).toList();
        responseText = "Scanning high-refresh thermal-dense setups... I found ${recs.length} elite options. These feature extreme dedicated NVIDIA RTX architectures designed to handle peak shader rendering and frame-rates.";
      } else if (lowerQuery.contains('portable') || lowerQuery.contains('travel') || lowerQuery.contains('battery') || lowerQuery.contains('light')) {
        recs = mockLaptops.where((l) => l.batteryScore >= 80 || l.weight <= 1.7).toList();
        responseText = "Diagnosing hyper-efficient portable cells... I filtered ${recs.length} rigs weighing under 1.8kg or sustaining extensive battery thresholds. The MacBook Pro and Spectre x360 are recommended for orbital travel.";
      } else if (lowerQuery.contains('video') || lowerQuery.contains('render') || lowerQuery.contains('creator') || lowerQuery.contains('photo')) {
        recs = mockLaptops.where((l) => l.category == 'Creators' || l.display.contains('OLED')).toList();
        responseText = "Filtering color-accurate OLED panels and multicore computing cores... I recommend the Zenith Pro 16 X or MacBook Pro for editing rigs.";
      } else {
        // Fallback or generic recommendation
        recs = [mockLaptops[0], mockLaptops[2]];
        responseText = "Analyzing general requests. Showing top-tier fleet laptops covering business, gaming, and creative categories for review.";
      }

      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(ChatMessage(
            text: responseText,
            isUser: false,
            recommendedLaptops: recs,
          ));
        });
        _scrollToBottom();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: PremiumTheme.primaryNeon.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.auto_awesome_rounded, color: PremiumTheme.primaryNeon, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Harbour Fleet AI Navigator',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        'Co-Pilot Diagnostic Assistant',
                        style: TextStyle(fontSize: 11, color: PremiumTheme.textSecondary),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const Divider(color: PremiumTheme.darkBorder, height: 1),

            // Message list
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(20),
                physics: const BouncingScrollPhysics(),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return _buildMessageBubble(msg);
                },
              ),
            ),

            if (_isTyping)
              Padding(
                padding: const EdgeInsets.only(left: 20.0, bottom: 12.0),
                child: Row(
                  children: [
                    Text('Navigator Co-Pilot is scanning', style: TextStyle(color: PremiumTheme.textMuted, fontSize: 11)),
                    const SizedBox(width: 8),
                    const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(strokeWidth: 2, color: PremiumTheme.primaryNeon),
                    ),
                  ],
                ),
              ),

            // Preset Quick Queries slider
            if (_messages.length == 1 && !_isTyping)
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _presets.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ActionChip(
                        label: Text(
                          _presets[index],
                          style: const TextStyle(fontSize: 11, color: Colors.white),
                        ),
                        backgroundColor: PremiumTheme.darkSurfaceCard.withValues(alpha: 0.8),
                        onPressed: () => _sendMessage(_presets[index]),
                        side: const BorderSide(color: PremiumTheme.darkBorder),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 8),

            // Text Input bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GlassCard(
                borderRadius: 20,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        onSubmitted: _sendMessage,
                        decoration: const InputDecoration(
                          hintText: 'Ask Co-Pilot: "developer laptop under \$2000"...',
                          hintStyle: TextStyle(color: PremiumTheme.textMuted, fontSize: 13),
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send_rounded, color: PremiumTheme.primaryNeon),
                      onPressed: () => _sendMessage(_textController.text),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        child: Column(
          crossAxisAlignment: msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Text bubble
            GlassCard(
              borderRadius: 16,
              color: msg.isUser ? PremiumTheme.secondaryNeon : PremiumTheme.darkSurfaceCard,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                msg.text,
                style: TextStyle(
                  color: msg.isUser ? Colors.white : PremiumTheme.textPrimary,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
            
            // Embedded recommended laptops
            if (msg.recommendedLaptops != null && msg.recommendedLaptops!.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 130,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: msg.recommendedLaptops!.length,
                  itemBuilder: (context, idx) {
                    final laptop = msg.recommendedLaptops![idx];
                    return Container(
                      width: 250,
                      margin: const EdgeInsets.only(right: 12),
                      child: GlassCard(
                        borderRadius: 16,
                        padding: const EdgeInsets.all(8),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => DetailScreen(laptop: laptop)),
                          );
                        },
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Image.network(
                                laptop.imageUrl,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.laptop),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    laptop.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${laptop.brand} | Rating: ${laptop.rating}',
                                    style: const TextStyle(color: PremiumTheme.textMuted, fontSize: 10),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '\$${laptop.basePrice.toInt()}',
                                    style: const TextStyle(
                                      color: PremiumTheme.primaryNeon,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: PremiumTheme.primaryNeon),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
