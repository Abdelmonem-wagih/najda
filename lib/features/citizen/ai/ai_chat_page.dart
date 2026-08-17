import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/services/groq_service.dart';
import '../../../core/theme/design.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';

// ═══════════════════════════════════════════════════════════════════
// UNIFIED AI CHAT PAGE — triage + assistant all in one
// Opened via FAB from home; works for both citizen and paramedic
// ═══════════════════════════════════════════════════════════════════

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final List<_Msg> _msgs = [];
  final List<Map<String, String>> _history = [];
  bool _loading = false;
  late String _role;

  // Quick suggestion chips
  static const _citizenSuggestions = [
    '🩺 قيّم أعراضي',
    '🫀 كيف أعمل CPR؟',
    '🩸 كيف أوقف نزيفاً شديداً؟',
    '🤕 مريض فاقد الوعي ماذا أفعل؟',
    '🔥 إسعاف الحروق',
  ];

  static const _paramedicSuggestions = [
    '💊 جرعة الأدرينالين للحساسية',
    '🫀 بروتوكول الصدمة النزفية',
    '🧠 علامات السكتة الدماغية',
    '💉 جرعة الأسبرين في احتشاء القلب',
    '🫁 إدارة مجرى الهواء',
  ];

  @override
  void initState() {
    super.initState();
    final s = context.read<AuthCubit>().state;
    _role = s is AuthAuthenticated ? s.user.role : 'citizen';

    // Welcome message
    _msgs.add(_Msg(
      text: _role == 'paramedic'
          ? 'مرحباً أيها المسعف! 🏥\n\nأنا مساعدك الطبي الميداني. يمكنني مساعدتك في:\n• الجرعات والبروتوكولات الطبية\n• تحليل الحالات وتحديد الأولويات\n• التفاعلات الدوائية\n• الإسعاف الميداني\n\nاسألني أي سؤال طبي.'
          : 'مرحباً! أنا مساعد نجدة الذكي 🤖\n\nيمكنني مساعدتك في:\n• تقييم الأعراض وتحديد درجة الخطورة\n• إرشادات الإسعافات الأولية\n• ماذا تفعل قبل وصول الإسعاف\n• الإجابة على أسئلتك الطبية\n\n⚠️ في الطوارئ اتصل بـ 123 فوراً!',
      isUser: false,
    ));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send([String? preset]) async {
    final text = preset ?? _ctrl.text.trim();
    if (text.isEmpty || _loading) return;
    _ctrl.clear();

    // Strip emoji prefix from suggestion chips
    final cleanText =
        text.replaceAll(RegExp(r'^[^\w\u0600-\u06FF]+'), '').trim();

    setState(() {
      _msgs.add(_Msg(text: text, isUser: true));
      _loading = true;
    });
    _scrollDown();

    try {
      final isTriage = _role == 'citizen' &&
          (cleanText.contains('أعراض') ||
              cleanText.contains('قيّم') ||
              cleanText.contains('عندي') ||
              cleanText.contains('ألم') ||
              cleanText.contains('أشعر'));

      String reply;
      if (isTriage) {
        final r = await NajdaAIService.instance.triageSymptoms(
          symptoms: cleanText,
        );
        reply = _formatTriage(r);
      } else {
        reply = await NajdaAIService.instance.askAssistant(
          message: cleanText,
          role: _role,
          history: List.from(_history),
        );
      }

      _history.add({'role': 'user', 'content': cleanText});
      _history.add({'role': 'assistant', 'content': reply});

      if (mounted) {
        setState(() {
          _msgs.add(_Msg(text: reply, isUser: false));
          _loading = false;
        });
        _scrollDown();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _msgs.add(_Msg(
            text:
                'عذراً، حدث خطأ مؤقت. تأكد من اتصالك بالإنترنت وحاول مرة أخرى.',
            isUser: false,
            isError: true,
          ));
          _loading = false;
        });
      }
    }
  }

  String _formatTriage(TriageResult r) {
    final sb = StringBuffer();
    final emoji = r.isCritical
        ? '🚨'
        : r.isHigh
            ? '⚠️'
            : '✅';
    sb.writeln('$emoji *${r.urgencyLabel}*');
    if (r.callAmbulance) {
      sb.writeln('\n📞 **اتصل بالإسعاف 123 فوراً!**');
    }
    if (r.firstAidSteps.isNotEmpty) {
      sb.writeln('\n**خطوات الإسعاف الأولي:**');
      for (var i = 0; i < r.firstAidSteps.length; i++) {
        sb.writeln('${i + 1}. ${r.firstAidSteps[i]}');
      }
    }
    if (r.doNotDo.isNotEmpty) {
      sb.writeln('\n**❌ لا تفعل:**');
      for (final d in r.doNotDo) {
        sb.writeln('• $d');
      }
    }
    if (r.waitingInstructions.isNotEmpty) {
      sb.writeln('\n**⏳ أثناء الانتظار:**\n${r.waitingInstructions}');
    }
    return sb.toString().trim();
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final suggestions =
        _role == 'paramedic' ? _paramedicSuggestions : _citizenSuggestions;
    final accentColor = _role == 'paramedic' ? NC.critical : NC.primary;

    return Scaffold(
      backgroundColor: NC.base,
      // Fixed: Removed manual keyboard padding calculation. 
      // Scaffold.resizeToAvoidBottomInset is true by default, 
      // handling the keyboard height automatically.
      appBar: AppBar(
        backgroundColor: NC.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: NC.textHigh, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(6),
                  child: SvgPicture.asset('assets/svg/chatBot.svg'),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: NC.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: NC.surface, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('مساعد نجدة الذكي',
                    style: NC.label(15, weight: FontWeight.w700)),
                Text(
                  _loading ? 'جارٍ الكتابة...' : 'متصل الآن',
                  style: NC.body(10, color: _loading ? accentColor : NC.success),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone_outlined, color: NC.critical, size: 22),
            onPressed: () => launchUrl(Uri.parse('tel:123')),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Messages ──────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: _msgs.length,
              itemBuilder: (_, i) {
                final isLast = i == _msgs.length - 1;
                return Column(
                  children: [
                    _BubbleWidget(
                      msg: _msgs[i],
                      accentColor: accentColor,
                    ),
                    if (isLast && _loading) _TypingIndicator(accentColor: accentColor),
                  ],
                );
              },
            ),
          ),

          // ── Input Area ─────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
            decoration: BoxDecoration(
              color: NC.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Suggestions
                if (_msgs.length <= 1 && !_loading)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: suggestions
                            .map((s) => Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: GestureDetector(
                                    onTap: () => _send(s),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: accentColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                            color: accentColor.withOpacity(0.3)),
                                      ),
                                      child: Text(s,
                                          style: NC.label(12, color: accentColor)),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ),

                // Text Field Row
                Row(
                  children: [
                    Expanded(
                      child: Focus(
                        child: Builder(
                          builder: (focusCtx) {
                            final isFocused = Focus.of(focusCtx).hasFocus;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: NC.card,
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: isFocused
                                      ? accentColor.withOpacity(0.7)
                                      : NC.cardBorder,
                                  width: isFocused ? 1.5 : 1.0,
                                ),
                                boxShadow: isFocused
                                    ? [
                                        BoxShadow(
                                          color: accentColor.withOpacity(0.12),
                                          blurRadius: 12,
                                          spreadRadius: 0,
                                        )
                                      ]
                                    : [],
                              ),
                              child: TextField(
                                controller: _ctrl,
                                maxLines: 4,
                                minLines: 1,
                                style: NC.inputText(),
                                textInputAction: TextInputAction.send,
                                onSubmitted: (_) => _send(),
                                decoration: InputDecoration(
                                  hintText: _role == 'paramedic'
                                      ? 'اسأل عن جرعة أو بروتوكول...'
                                      : 'صف أعراضك أو اطرح سؤالاً...',
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(28),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(28),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(28),
                                    borderSide: BorderSide.none,
                                  ),
                                  hintStyle: NC.body(14, color: NC.textLow),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => _send(),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: _role == 'paramedic'
                              ? NC.criticalGrad
                              : NC.primaryGrad,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.send_rounded,
                            color: Colors.white, size: 22),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Chat bubble ──────────────────────────────────────────────────
class _BubbleWidget extends StatelessWidget {
  final _Msg msg;
  final Color accentColor;

  const _BubbleWidget({required this.msg, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Align(
        alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: msg.isUser ? NC.primaryGrad : null,
            color: msg.isUser
                ? null
                : msg.isError
                    ? NC.criticalDim.withOpacity(0.3)
                    : NC.card,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: Radius.circular(msg.isUser ? 20 : 4),
              bottomRight: Radius.circular(msg.isUser ? 4 : 20),
            ),
            border: !msg.isUser ? Border.all(color: NC.cardBorder) : null,
          ),
          child: _FormattedText(
            text: msg.text,
            baseColor: msg.isUser ? Colors.white : NC.textHigh,
          ),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  final Color accentColor;
  const _TypingIndicator({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: NC.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: NC.cardBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TypingDot(color: accentColor, delay: 0),
            const SizedBox(width: 4),
            _TypingDot(color: accentColor, delay: 200),
            const SizedBox(width: 4),
            _TypingDot(color: accentColor, delay: 400),
          ],
        ),
      ),
    );
  }
}

/// Renders AI response with basic markdown: **bold**, numbered lists, bullets
class _FormattedText extends StatelessWidget {
  final String text;
  final Color baseColor;

  const _FormattedText({required this.text, required this.baseColor});

  @override
  Widget build(BuildContext context) {
    final lines = text.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: lines.map((line) => _buildLine(line)).toList(),
    );
  }

  Widget _buildLine(String line) {
    if (line.trim().isEmpty) return const SizedBox(height: 4);

    // Bold header: **text** or *text*
    if ((line.startsWith('**') && line.endsWith('**')) ||
        (line.startsWith('*') && line.endsWith('*'))) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 6, top: 4),
        child: Text(
          line.replaceAll('**', '').replaceAll('*', ''),
          style: TextStyle(
            fontFamily: NC.font,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: baseColor,
            height: 1.5,
          ),
        ),
      );
    }

    // Emoji urgency header
    if (RegExp(r'^[\u{1F000}-\u{1FFFF}]', unicode: true).hasMatch(line) ||
        line.startsWith('🚨') ||
        line.startsWith('⚠️') ||
        line.startsWith('✅') ||
        line.startsWith('📞')) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 4),
        child: Text(
          line,
          style: TextStyle(
            fontFamily: NC.font,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: baseColor,
            height: 1.5,
          ),
        ),
      );
    }

    // Numbered list: "1. text"
    final numMatch = RegExp(r'^(\d+)\.\s+(.+)').firstMatch(line);
    if (numMatch != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${numMatch.group(1)}. ',
                style: TextStyle(
                    fontFamily: NC.font,
                    fontWeight: FontWeight.bold,
                    color: baseColor)),
            Expanded(
              child: Text(
                numMatch.group(2)!,
                style: TextStyle(
                  fontFamily: NC.font,
                  fontSize: 14,
                  color: baseColor,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Bullet: "• text" or "- text"
    if (line.startsWith('• ') || line.startsWith('- ')) {
      final content = line.substring(2);
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• ',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: baseColor)),
            Expanded(
              child: Text(
                content,
                style: TextStyle(
                  fontFamily: NC.font,
                  fontSize: 14,
                  color: baseColor,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Normal paragraph
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Text(
        line,
        style: TextStyle(
          fontFamily: NC.font,
          fontSize: 14,
          color: baseColor,
          height: 1.6,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

// ─── Message model ────────────────────────────────────────────────
class _Msg {
  final String text;
  final bool isUser;
  final bool isError;
  _Msg({required this.text, required this.isUser, this.isError = false});
}

// ─── Animated typing dot ──────────────────────────────────────────
class _TypingDot extends StatefulWidget {
  final Color color;
  final int delay;
  const _TypingDot({required this.color, required this.delay});

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _a;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 550));
    _a = Tween<double>(begin: 0.2, end: 1.0)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _c.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _a,
        child: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
        ),
      );
}
