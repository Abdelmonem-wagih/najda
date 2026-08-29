// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_svg/svg.dart';
//
// import '../../../../../core/theme/app_colors.dart';
// import '../../../../../core/theme/app_text_styles.dart';
// import '../../../../../core/theme/app_spacing.dart';
// import '../../../../../core/theme/app_radius.dart';
// import '../../../../../core/l10n/generated/app_localizations.dart';
// import '../../../../auth/presentation/cubit/auth_cubit.dart';
// import '../cubit/ai_chat_cubit.dart';
// import '../cubit/ai_chat_state.dart';
// import '../widgets/chat_bubble.dart';
// import '../../data/repositories/ai_chat_repository_impl.dart';
//
// class AiChatPage extends StatelessWidget {
//   const AiChatPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => AIChatCubit(
//         repository: AIChatRepositoryImpl(),
//       ),
//       child: const _AiChatView(),
//     );
//   }
// }
//
// class _AiChatView extends StatefulWidget {
//   const _AiChatView();
//
//   @override
//   State<_AiChatView> createState() => _AiChatViewState();
// }
//
// class _AiChatViewState extends State<_AiChatView> {
//   final _ctrl = TextEditingController();
//   final _scroll = ScrollController();
//   late String _role;
//
//   static const _citizenSuggestions = [
//     '🩺 قيّم أعراضي',
//     '🫀 كيف أعمل CPR؟',
//     '🩸 كيف أوقف نزيفاً؟',
//     '🤕 مريض فاقد الوعي',
//     '🔥 إسعاف الحروق',
//   ];
//
//   static const _paramedicSuggestions = [
//     '💊 جرعة الأدرينالين',
//     '🫀 بروتوكول الصدمة',
//     '🧠 علامات السكتة',
//     '💉 جرعة الأسبرين',
//     '🫁 إدارة المجرى',
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     final authState = context.read<AuthCubit>().state;
//     _role = authState is AuthAuthenticated ? authState.user.role : 'citizen';
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final l10n = AppLocalizations.of(context)!;
//       final welcome = _role == 'paramedic' ? l10n.paramedicWelcome : l10n.citizenWelcome;
//       context.read<AIChatCubit>().init(_role, welcome);
//     });
//   }
//
//   @override
//   void dispose() {
//     _ctrl.dispose();
//     _scroll.dispose();
//     super.dispose();
//   }
//
//   void _send([String? preset]) {
//     final text = preset ?? _ctrl.text.trim();
//     if (text.isEmpty) return;
//     context.read<AIChatCubit>().sendMessage(text, _role);
//     _ctrl.clear();
//     _scrollDown();
//   }
//
//   void _scrollDown() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scroll.hasClients) {
//         _scroll.animateTo(_scroll.position.maxScrollExtent,
//             duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final l10n = AppLocalizations.of(context)!;
//     final suggestions = _role == 'paramedic' ? _paramedicSuggestions : _citizenSuggestions;
//     final accentColor = _role == 'paramedic' ? AppColors.criticalRed : AppColors.primaryBlue;
//
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         backgroundColor: AppColors.navy,
//         leading: IconButton(
//           icon: const Icon(Icons.close),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Row(
//           children: [
//             Container(
//               width: 36,
//               height: 36,
//               padding: const EdgeInsets.all(6),
//               decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
//               child: SvgPicture.asset('assets/svg/bot.png'),
//             ),
//             const SizedBox(width: AppSpacing.md),
//             BlocBuilder<AIChatCubit, AIChatState>(
//               builder: (context, state) {
//                 return Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(l10n.aiAssistant,
//                         style: AppTextStyles.titleLarge.copyWith(color: AppColors.white)),
//                     Text(state.isLoading ? l10n.aiThinking : l10n.aiConnected,
//                         style: AppTextStyles.bodySmall
//                             .copyWith(color: AppColors.white.withOpacity(0.7))),
//                   ],
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: BlocConsumer<AIChatCubit, AIChatState>(
//               listener: (context, state) {
//                 if (!state.isLoading) _scrollDown();
//               },
//               builder: (context, state) {
//                 return ListView.builder(
//                   controller: _scroll,
//                   padding: const EdgeInsets.all(AppSpacing.lg),
//                   itemCount: state.messages.length,
//                   itemBuilder: (_, i) =>
//                       ChatBubble(msg: state.messages[i], accentColor: accentColor),
//                 );
//               },
//             ),
//           ),
//           BlocBuilder<AIChatCubit, AIChatState>(
//             builder: (context, state) {
//               if (state.isLoading) {
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
//                   child: Align(
//                     alignment: Alignment.centerRight,
//                     child: Text(l10n.aiReplying, style: AppTextStyles.bodySmall),
//                   ),
//                 );
//               }
//               return const SizedBox.shrink();
//             },
//           ),
//           Container(
//             padding: EdgeInsets.fromLTRB(
//                 AppSpacing.md,
//                 AppSpacing.sm,
//                 AppSpacing.md,
//                 MediaQuery.of(context).padding.bottom + AppSpacing.md),
//             decoration: const BoxDecoration(
//               color: AppColors.surface,
//               boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
//             ),
//             child: BlocBuilder<AIChatCubit, AIChatState>(
//               builder: (context, state) {
//                 return Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     if (state.messages.length <= 1)
//                       SingleChildScrollView(
//                         scrollDirection: Axis.horizontal,
//                         padding: const EdgeInsets.only(bottom: AppSpacing.sm),
//                         child: Row(
//                           children: suggestions
//                               .map((s) => Padding(
//                                     padding: const EdgeInsets.only(left: AppSpacing.sm),
//                                     child: ActionChip(
//                                       label: Text(s),
//                                       onPressed: () => _send(s),
//                                       labelStyle: AppTextStyles.bodySmall
//                                           .copyWith(color: AppColors.primaryBlue),
//                                       backgroundColor: AppColors.primaryBlue.withOpacity(0.05),
//                                       shape: RoundedRectangleBorder(
//                                           borderRadius: AppRadius.radiusXl),
//                                     ),
//                                   ))
//                               .toList(),
//                         ),
//                       ),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: TextField(
//                             controller: _ctrl,
//                             maxLines: 4,
//                             minLines: 1,
//                             decoration: InputDecoration(
//                               hintText: l10n.typeMessageHint,
//                               contentPadding: const EdgeInsets.symmetric(
//                                   horizontal: AppSpacing.md, vertical: AppSpacing.sm),
//                               filled: true,
//                               fillColor: AppColors.background,
//                               border: OutlineInputBorder(
//                                   borderRadius: AppRadius.radiusXl, borderSide: BorderSide.none),
//                             ),
//                             onSubmitted: (_) => _send(),
//                           ),
//                         ),
//                         const SizedBox(width: AppSpacing.sm),
//                         IconButton.filled(
//                           onPressed: () => _send(),
//                           icon: const Icon(Icons.send_rounded),
//                           style: IconButton.styleFrom(backgroundColor: accentColor),
//                         ),
//                       ],
//                     ),
//                   ],
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
