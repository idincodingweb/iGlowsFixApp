import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_theme.dart';
import '../../models/chat_message.dart';
import '../../models/skin_profile.dart';
import '../../services/consultation_service.dart';
import '../../services/groq_service.dart';
import '../../services/local_store.dart';

class ConsultationScreen extends StatefulWidget {
  /// Optional: buka session existing.
  final String? sessionId;
  const ConsultationScreen({super.key, this.sessionId});

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final _glowy = GroqService();
  final _store = LocalStore();
  final _picker = ImagePicker();
  final _svc = ConsultationService.instance;

  SkinProfile? _profile;
  final List<ChatMessage> _msgs = [];
  bool _typing = false;
  bool _bootstrapping = true;
  String? _sessionId;
  bool _titleSet = false;

  // Pending image attachment (sebelum dikirim)
  String? _pendingImgB64;
  String? _pendingImgMime;
  StreamSubscription<List<ChatMessage>>? _msgSub;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      _profile = await _store.loadProfile();
    } catch (_) {}

    String? sid = widget.sessionId;
    sid ??= await _svc.createSession(title: 'Konsultasi baru');

    if (!mounted) return;
    setState(() {
      _sessionId = sid;
      _bootstrapping = false;
      if (_msgs.isEmpty) {
        _msgs.add(
            ChatMessage(text: _glowy.greeting(), fromUser: false));
      }
    });

    // Kalau resume session existing, tarik history dari Firestore.
    if (widget.sessionId != null && sid != null) {
      _msgSub = _svc.streamMessages(sid).listen((remote) {
        if (!mounted || remote.isEmpty) return;
        setState(() {
          _msgs
            ..clear()
            ..add(ChatMessage(text: _glowy.greeting(), fromUser: false))
            ..addAll(remote);
          _titleSet = true;
        });
        _scrollEnd();
      });
    }
  }

  Future<void> _pickImage(ImageSource src) async {
    try {
      final x = await _picker.pickImage(
        source: src,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 70,
      );
      if (x == null) return;
      final bytes = await x.readAsBytes();
      if (!mounted) return;
      setState(() {
        _pendingImgB64 = base64Encode(bytes);
        _pendingImgMime = _mimeFromPath(x.path);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal ambil gambar: $e')),
      );
    }
  }

  String _mimeFromPath(String path) {
    final p = path.toLowerCase();
    if (p.endsWith('.png')) return 'image/png';
    if (p.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  void _showAttachSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(2))),
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded,
                  color: AppColors.primary),
              title: const Text('Ambil foto'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded,
                  color: AppColors.primary),
              title: const Text('Pilih dari galeri'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    final hasImg = _pendingImgB64 != null;
    if (text.isEmpty && !hasImg) return;

    final userMsg = ChatMessage(
      text: text.isEmpty ? '' : text,
      fromUser: true,
      imageBase64: _pendingImgB64,
      imageMime: _pendingImgMime,
    );
    _ctrl.clear();
    setState(() {
      _msgs.add(userMsg);
      _typing = true;
      _pendingImgB64 = null;
      _pendingImgMime = null;
    });
    _scrollEnd();

    final sid = _sessionId;
    if (sid != null) {
      _svc.appendMessage(sid, userMsg);
      if (!_titleSet) {
        final t = text.isEmpty ? '📷 Konsultasi foto' : text;
        _svc.setTitle(sid, t);
        _titleSet = true;
      }
    }

    try {
      final reply =
          await _glowy.chat(history: List.of(_msgs), profile: _profile);
      if (!mounted) return;
      final botMsg = ChatMessage(text: reply, fromUser: false);
      setState(() {
        _msgs.add(botMsg);
        _typing = false;
      });
      if (sid != null) _svc.appendMessage(sid, botMsg);
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
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut);
      }
    });
  }

  @override
  void dispose() {
    _msgSub?.cancel();
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
              width: 36,
              height: 36,
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
                Text('Dokter Ahli iGlows',
                    style: tt.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                Text('Team ahli iGlows',
                    style: tt.bodySmall?.copyWith(color: AppColors.primary)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Riwayat',
            icon: const Icon(Icons.history_rounded, color: AppColors.primary),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const ConsultationSessionsScreen())),
          ),
        ],
      ),
      body: _bootstrapping
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    itemCount: _msgs.length + (_typing ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (i == _msgs.length && _typing) {
                        return const _TypingBubble();
                      }
                      return _Bubble(msg: _msgs[i]);
                    },
                  ),
                ),
                if (_pendingImgB64 != null)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft.withValues(alpha: .3),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              base64Decode(_pendingImgB64!),
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                              child: Text('Foto siap dikirim ke Dokter Ahli iGlows 📸')),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => setState(() {
                              _pendingImgB64 = null;
                              _pendingImgMime = null;
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                    child: Row(
                      children: [
                        IconButton(
                          tooltip: 'Lampirkan foto',
                          onPressed: _showAttachSheet,
                          icon: const Icon(Icons.add_photo_alternate_rounded,
                              color: AppColors.primary),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _ctrl,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _send(),
                            decoration: const InputDecoration(
                              hintText: 'Tanya Dokter Ahli iGlows...',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Material(
                          color: AppColors.primary,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: _send,
                            child: const SizedBox(
                              width: 48,
                              height: 48,
                              child: Icon(Icons.send_rounded,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
              color: AppColors.primarySoft.withValues(alpha: .4)),
        ),
        child: Column(
          crossAxisAlignment:
              user ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (msg.hasImage)
              Padding(
                padding: EdgeInsets.only(bottom: msg.text.isEmpty ? 0 : 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    base64Decode(msg.imageBase64!),
                    width: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            if (msg.text.isNotEmpty)
              Text(
                msg.text,
                style: TextStyle(
                  color: user ? Colors.white : AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
          ],
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
          width: 24,
          height: 12,
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

/// Daftar session konsultasi sebelumnya (Milestone 4).
class ConsultationSessionsScreen extends StatelessWidget {
  const ConsultationSessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = ConsultationService.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Konsultasi')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (_) => const ConsultationScreen()));
        },
        icon: const Icon(Icons.add_comment_rounded),
        label: const Text('Konsultasi baru'),
      ),
      body: StreamBuilder<List<ConsultationSession>>(
        stream: svc.streamSessions(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snap.data ?? const [];
          if (items.isEmpty) {
            return const Center(
                child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                  'Belum ada konsultasi tersimpan.\nMulai chat untuk membuat session baru.',
                  textAlign: TextAlign.center),
            ));
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final s = items[i];
              return Material(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                          builder: (_) =>
                              ConsultationScreen(sessionId: s.id))),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        const CircleAvatar(
                            radius: 22,
                            backgroundColor: AppColors.primarySoft,
                            child: Text('💬')),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(height: 2),
                              Text(
                                s.lastMessage.isEmpty
                                    ? '(belum ada balasan)'
                                    : s.lastMessage,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: AppColors.textSecondary),
                          onPressed: () async {
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (d) => AlertDialog(
                                title: const Text('Hapus konsultasi?'),
                                content: const Text(
                                    'Riwayat pesan akan ikut terhapus.'),
                                actions: [
                                  TextButton(
                                      onPressed: () => Navigator.pop(d, false),
                                      child: const Text('Batal')),
                                  TextButton(
                                      onPressed: () => Navigator.pop(d, true),
                                      child: const Text('Hapus')),
                                ],
                              ),
                            );
                            if (ok == true) await svc.deleteSession(s.id);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

