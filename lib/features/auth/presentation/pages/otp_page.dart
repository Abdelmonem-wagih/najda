import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/route/app_routes.dart';
import '../../../../core/theme/design.dart';
import '../cubit/auth_cubit.dart';

class OtpPage extends StatefulWidget {
  final String verificationId;
  const OtpPage({super.key, required this.verificationId});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final List<TextEditingController> _ctrls =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(6, (_) => FocusNode());

  int _secondsLeft = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nodes[0].requestFocus();
    });
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft == 0) {
        _timer?.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    for (final c in _ctrls) c.dispose();
    for (final n in _nodes) n.dispose();
    _timer?.cancel();
    super.dispose();
  }

  String get _otp => _ctrls.map((c) => c.text).join();

  void _verify() {
    if (_otp.length < 6) return;
    context.read<AuthCubit>().verifyOtp(_otp, widget.verificationId);
  }

  void _onChanged(String val, int index) {
    if (val.isNotEmpty && index < 5) {
      _nodes[index + 1].requestFocus();
    } else if (val.isEmpty && index > 0) {
      _nodes[index - 1].requestFocus();
    }
    if (_otp.length == 6) _verify();
  }

  @override
  Widget build(BuildContext context) {
    final phone = (context.watch<AuthCubit>().state is OtpSent)
        ? (context.watch<AuthCubit>().state as OtpSent).phoneNumber
        : '';

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            state.user.isCitizen
                ? AppRoutes.citizenHome
                : AppRoutes.paramedicHome,
            (r) => false,
          );
        } else if (state is AuthNeedsRegistration) {
          Navigator.pushReplacementNamed(context, AppRoutes.registration,
              arguments: {'uid': state.uid, 'phoneNumber': state.phone});
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(state.message, style: TextStyle(fontFamily: NC.font)),
              backgroundColor: NC.critical,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: NC.base,
        appBar: AppBar(
          backgroundColor: NC.surface,
          elevation: 0,
          leading: IconButton(
            icon:
                const Icon(Icons.arrow_back_ios_rounded, color: NC.textHigh, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('تحقق من الرقم', style: NC.display(16)),
        ),
        body: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: NC.primaryGrad,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: NC.primary.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.sms_outlined,
                        color: NC.base, size: 36),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'كود التحقق',
                    style: NC.display(24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    phone.isNotEmpty ? 'أدخل الرمز المكون من 6 أرقام المرسل إلى $phone' : '',
                    style: NC.body(14, color: NC.textMid),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // OTP inputs
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      6,
                      (i) => Container(
                        width: 48,
                        height: 56,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: NC.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _nodes[i].hasFocus
                                ? NC.primary
                                : NC.cardBorder,
                            width: _nodes[i].hasFocus ? 1.5 : 1,
                          ),
                        ),
                        child: TextFormField(
                          controller: _ctrls[i],
                          focusNode: _nodes[i],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: const InputDecoration(
                            counterText: '',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            filled: false,
                          ),
                          style: TextStyle(
                            fontFamily: NC.font,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: NC.textHigh,
                          ),
                          onChanged: (v) => _onChanged(v, i),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Verify button
                  GradientButton(
                    label: 'تحقق الآن',
                    onTap: isLoading ? null : _verify,
                    loading: isLoading,
                  ),
                  const SizedBox(height: 24),

                  // Resend
                  if (_secondsLeft > 0)
                    Text(
                      'يمكنك إعادة الإرسال بعد $_secondsLeft ثانية',
                      style: NC.body(12, color: NC.textLow),
                    )
                  else
                    TextButton(
                      onPressed: () {
                        // Pop back and let user re-enter phone
                        Navigator.pop(context);
                      },
                      child: Text('إعادة إرسال الرمز',
                          style: NC.label(14, color: NC.primary)),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
