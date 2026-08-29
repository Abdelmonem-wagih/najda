import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/services/groq_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/shared/widgets/app_widgets.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';

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

  static const _citizenSuggestions = [
    '🩺 قيّم أعراضي',
    '🫀 كيف أعمل CPR؟',
    '🩸 كيف أوقف نزيفاً؟',
    '🤕 مريض فاقد الوعي',
    '🔥 إسعاف الحروق',
  ];

  static const _paramedicSuggestions = [
    '💊 جرعة الأدرينالين',
    '🫀 بروتوكول الصدمة',
    '🧠 علامات السكتة',
    '💉 جرعة الأسبرين',
    '🫁 إدارة المجرى',
  ];

  @override
  void initState() {
    super.initState();
    final s = context.read<AuthCubit>().state;
    _role = s is AuthAuthenticated ? s.user.role : 'citizen';

    _msgs.add(_Msg(
      text: _role == 'paramedic'
          ? 'مرحباً أيها المسعف! 🏥\n\nأنا مساعدك الطبي الميداني. يمكنني مساعدتك في البروتوكولات والجرعات والتفاعلات الدوائية.\n\nاسألني أي سؤال طبي.'
          : 'مرحباً! أنا مساعد نجدة الذكي 🤖\n\nيمكنني مساعدتك في تقييم الأعراض وإرشادات الإسعافات الأولية.\n\n⚠️ في الطوارئ اتصل بـ 123 فوراً!',
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

    final cleanText = text.replaceAll(RegExp(r'^[^\w\u0600-\u06FF]+'), '').trim();

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
        final rawResult = await NajdaAIService.instance.triageSymptomsDirect(
          symptoms: cleanText,
        );
        final r = TriageResult.fromMap( rawResult);
        reply = _formatTriage(r);
      } else {
        reply = await NajdaAIService.instance.askAssistantDirect(
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
      // Print actual error for debugging
      debugPrint('AI Chat Error: $e');
      debugPrint('Error type: ${e.runtimeType}');

      String errorMsg;
      final errStr = e.toString().toLowerCase();

      if (errStr.contains('unauthenticated') || errStr.contains('permission')) {
        errorMsg = 'خطأ في الصلاحيات. تأكد من تسجيل الدخول.';
      } else if (errStr.contains('not-found') || errStr.contains('not found')) {
        errorMsg = 'الخدمة غير متاحة حالياً. تأكد من نشر Firebase Functions.';
      } else if (errStr.contains('groq') ||
          errStr.contains('api key') ||
          errStr.contains('internal')) {
        errorMsg = 'خطأ في خادم الذكاء الاصطناعي. تحقق من إعداد GROQ_API_KEY في Firebase.';
      } else if (errStr.contains('timeout') || errStr.contains('deadline')) {
        errorMsg = 'انتهت مهلة الاتصال. حاول مرة أخرى.';
      } else if (errStr.contains('network') || errStr.contains('socket')) {
        errorMsg = 'تحقق من اتصالك بالإنترنت.';
      } else {
        errorMsg = 'خطأ: $e'; // Show actual error during development
      }

      if (mounted) {
        setState(() {
          _msgs.add(_Msg(
            text: errorMsg,
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
    final emoji = r.isCritical ? '🚨' : r.isHigh ? '⚠️' : '✅';
    sb.writeln('$emoji *${r.urgencyLabel}*');
    if (r.callAmbulance) sb.writeln('\n📞 **اتصل بالإسعاف 123 فوراً!**');
    if (r.firstAidSteps.isNotEmpty) {
      sb.writeln('\n**إرشادات الإسعاف:**');
      for (var i = 0; i < r.firstAidSteps.length; i++) {
        sb.writeln('${i + 1}. ${r.firstAidSteps[i]}');
      }
    }
    return sb.toString().trim();
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = _role == 'paramedic' ? _paramedicSuggestions : _citizenSuggestions;
    final accentColor = _role == 'paramedic' ? AppColors.criticalRed : AppColors.primaryBlue;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
              child:  Image.asset(
                'assets/svg/bot.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('مساعد نجدة', style: AppTextStyles.titleLarge.copyWith(color: AppColors.white)),
                Text(_loading ? 'جارٍ التفكير...' : 'متصل الآن',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.white.withOpacity(0.7))),
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
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: _msgs.length,
              itemBuilder: (_, i) => _Bubble(msg: _msgs[i], accentColor: accentColor),
            ),
          ),
          if (_loading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text('جارٍ الرد...', style: AppTextStyles.bodySmall),
              ),
            ),
          Container(
            padding: EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, MediaQuery.of(context).padding.bottom + AppSpacing.md),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_msgs.length <= 1)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Row(
                      children: suggestions
                          .map((s) => Padding(
                                padding: const EdgeInsets.only(left: AppSpacing.sm),
                                child: ActionChip(
                                  label: Text(s),
                                  onPressed: () => _send(s),
                                  labelStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.primaryBlue),
                                  backgroundColor: AppColors.primaryBlue.withOpacity(0.05),
                                  shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusXl),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _ctrl,
                        maxLines: 4,
                        minLines: 1,
                        decoration: InputDecoration(
                          hintText: 'اكتب سؤالك هنا...',
                          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(borderRadius: AppRadius.radiusXl, borderSide: BorderSide.none),
                        ),
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    IconButton.filled(
                      onPressed: () => _send(),
                      icon: const Icon(Icons.send_rounded),
                      style: IconButton.styleFrom(backgroundColor: accentColor),
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

class _Bubble extends StatelessWidget {
  final _Msg msg;
  final Color accentColor;
  const _Bubble({required this.msg, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: msg.isUser ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: msg.isUser ? AppColors.white : accentColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(AppRadius.lg),
            topRight: const Radius.circular(AppRadius.lg),
            bottomLeft: Radius.circular(msg.isUser ? 0 : AppRadius.lg),
            bottomRight: Radius.circular(msg.isUser ? AppRadius.lg : 0),
          ),
          boxShadow: [const BoxShadow(color: Colors.black54, blurRadius: 5)],
        ),
        child: Text(
          msg.text,
          style: AppTextStyles.bodyMedium.copyWith(color: msg.isUser ? AppColors.textPrimary : AppColors.white),
        ),
      ),
    );
  }
}

class _Msg {
  final String text;
  final bool isUser;
  final bool isError;
  _Msg({required this.text, required this.isUser, this.isError = false});
}
