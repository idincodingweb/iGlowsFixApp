import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/chat_message.dart';
import '../../services/groq_service.dart';
import '../../services/local_store.dart';
import '../../models/skin_profile.dart';
import '../../widgets/glow_widgets.dart';

class ConsultationScreen extends StatefulWidget {
  const ConsultationScreen({super.key});

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final _glowy = GroqService();
  final _store = LocalStore();
  SkinProfile? _profile;
  final List<ChatMessage> _msgs = [];
  bool _typing = false;

  @override
  void initState() {
    super.initState();
    _msgs.add(ChatMessage(text: _glowy.greeting(), fromUser: false));
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final p = await _store.loadProfile();
      if (mounted) setState(() => _profile = p);
    } catch (_) {/* ignore */}
  }

  Future<void> _send([String? quick]) async {
    final text = (quick ?? _ctrl.text).trim();
    if (text.isEmpty) return;
    _ctrl.clear();
    setState(() {
      _msgs.add(ChatMessage(text: text, fromUser: true));
      _typing = true;
    });
    _scrollEnd();

    try {
      // Kirim seluruh riwayat (kecuali greeting awal opsional dipakai) ke Groq
      // agar konteks percakapan terjaga.
      final reply = await _glowy.chat(
        history: List<ChatMessage>.from(_msgs),
        profile: _profile,
      );
      if (!mounted) return;
      setState(() {
        _msgs.add(ChatMessage(text: reply, fromUser: false));
        _typing = false;
      });
    } on GroqException catch (e) {
      if (!mounted) return;
      setState(() {
        _msgs.add(ChatMessage(text: e.message, fromUser: false));
        _typing = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _msgs.add(ChatMessage(
          text:
              'Yah, ada gangguan koneksi nih bestie 🥺 Coba cek internet kamu & kirim ulang ya.',
          fromUser: false,
        ));
        _typing = false;
      });
    }
    _scrollEnd();
  }

  void _scrollEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    _glowy.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: const BoxDecoration(
                shape: BoxShape.circle, color: AppColors.primarySoft),
              alignment: Alignment.center,
              child: const Text('✨'),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Glowy',
                    style: tt.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                Text('AI Beauty Assistant',
                    style: tt.bodySmall
                        ?.copyWith(color: AppColors.primary)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              itemCount: _msgs.length + (_typing ? 1 : 0),
              itemBuilder: (_, i) {
                if (i >= _msgs.length) return const _TypingBubble();
                return _Bubble(msg: _msgs[i]);
              },
            ),
          ),
          // Quick chips
          SizedBox(
            height: 44,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              children: [
                for (final q in const ['Jerawat', 'Kulit kering', 'Berminyak', 'Sensitif', 'Anti-aging', 'Kusam'])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: PillChip(
                      label: q,
                      icon: Icons.auto_awesome,
                      onTap: () => _send(q),
                    ),
                  ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                        hintText: 'Tanya Glowy apapun...',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: AppColors.primary,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => _send(),
                      child: const SizedBox(
                        width: 52, height: 52,
                        child: Icon(Icons.send_rounded, color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final ChatMessage msg;
  const _Bubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    final user = msg.fromUser;
    return Align(
      alignment: user ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * .78),
        decoration: BoxDecoration(
          color: user ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(user ? 18 : 4),
            bottomRight: Radius.circular(user ? 4 : 18),
          ),
          border: Border.all(
            color: AppColors.primarySoft.withValues(alpha: .4),
          ),
        ),
        child: Text(
          msg.text,
          style: TextStyle(
            color: user ? Colors.white : AppColors.textPrimary,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: AppColors.primarySoft.withValues(alpha: .4)),
        ),
        child: const SizedBox(
          width: 24, height: 12,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(radius: 3, backgroundColor: AppColors.primary),
              CircleAvatar(radius: 3, backgroundColor: AppColors.primary),
              CircleAvatar(radius: 3, backgroundColor: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
