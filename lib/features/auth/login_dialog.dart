import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:oktoast/oktoast.dart';

import 'auth_cubit.dart';
import 'auth_state.dart';

/// 管理端登录弹窗（对照 Vue 项目 LoginDialog.vue）。
///
/// 由 [AuthState.dialogVisible] 驱动，覆盖在整个 app 之上。
class LoginDialog extends StatefulWidget {
  const LoginDialog({super.key});

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: '515656712@qq.com');
  final _passwordController = TextEditingController();

  static final RegExp _emailRegex =
      RegExp(r'^[a-zA-Z0-9_-]+@[a-zA-Z0-9_-]+(\.[a-zA-Z0-9_-]+)+$');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AuthCubit>();
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (p, c) => p.loggedIn != c.loggedIn || p.error != c.error,
      listener: (context, state) {
        if (state.error != null) {
          showToast(state.error!);
        }
        if (state.loggedIn) {
          showToast('登录成功');
          context.go(state.redirectPath);
        }
      },
      child: Material(
        color: Colors.black54,
        child: Center(
          child: SizedBox(
            width: 460,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    return Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '管理端登录',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: cubit.closeDialog,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _ReadonlyField(label: 'deviceId', value: cubit.deviceId),
                          const SizedBox(height: 8),
                          _ReadonlyField(
                              label: 'deviceName', value: cubit.deviceName),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: '用户名（邮箱）',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return '请输入邮箱';
                              if (!_emailRegex.hasMatch(v)) return '请输入正确的邮箱';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: '密码',
                              border: OutlineInputBorder(),
                            ),
                            onFieldSubmitted: (_) => _submit(),
                            validator: (v) =>
                                (v == null || v.isEmpty) ? '请输入密码' : null,
                          ),
                          const SizedBox(height: 20),
                          FilledButton(
                            onPressed: state.submitting ? null : _submit,
                            child: state.submitting
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Text('登录'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReadonlyField extends StatelessWidget {
  const _ReadonlyField({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: true,
      controller: TextEditingController(text: value),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      style: const TextStyle(fontSize: 12, color: Colors.grey),
    );
  }
}
