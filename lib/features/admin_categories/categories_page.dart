import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:oktoast/oktoast.dart';

import '../../core/network/api_exception.dart';
import '../../data/models/category.dart';
import '../../data/repositories/category_repository.dart';
import 'category_cubit.dart';
import 'category_state.dart';

/// 书籍分类管理页（对照 admin-categories/index.vue）。
class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CategoryCubit>(
      create: (context) =>
          CategoryCubit(context.read<CategoryRepository>())..load(),
      child: const _CategoriesView(),
    );
  }
}

class _CategoriesView extends StatelessWidget {
  const _CategoriesView();

  Future<void> _openDialog(BuildContext context, {Category? row}) async {
    final cubit = context.read<CategoryCubit>();
    final nameCtrl = TextEditingController(text: row?.name ?? '');
    final slugCtrl = TextEditingController(text: row?.slug ?? '');
    final formKey = GlobalKey<FormState>();
    final isEdit = row != null;

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        var submitting = false;
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: Text(isEdit ? '修改分类' : '添加分类'),
              content: SizedBox(
                width: 460,
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isEdit)
                        TextFormField(
                          initialValue: row.id,
                          enabled: false,
                          decoration: const InputDecoration(
                            labelText: 'id',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      if (isEdit) const SizedBox(height: 12),
                      TextFormField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? '请输入分类名称' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: slugCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Slug',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? '请输入分类slug' : null,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      submitting ? null : () => Navigator.of(ctx).pop(),
                  child: const Text('取消'),
                ),
                FilledButton(
                  onPressed: submitting
                      ? null
                      : () async {
                          if (!(formKey.currentState?.validate() ?? false)) {
                            return;
                          }
                          setState(() => submitting = true);
                          try {
                            await cubit.saveCategory(
                              name: nameCtrl.text.trim(),
                              slug: slugCtrl.text.trim(),
                            );
                            if (ctx.mounted) Navigator.of(ctx).pop();
                            showToast('保存成功');
                          } on ApiException catch (e) {
                            showToast(e.message);
                            setState(() => submitting = false);
                          }
                        },
                  child: const Text('确认'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _delete(BuildContext context, Category row) async {
    final cubit = context.read<CategoryCubit>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除吗？'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('删除')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await cubit.deleteCategory(row.id);
      showToast('删除成功');
    } on ApiException catch (e) {
      showToast(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocBuilder<CategoryCubit, CategoryState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton.icon(
                    onPressed: () => _openDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('添加分类'),
                  ),
                ),
                const SizedBox(height: 12),
                if (state.error != null)
                  Text('错误：${state.error}',
                      style: const TextStyle(color: Colors.red)),
                Expanded(
                  child: state.loading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('ID')),
                              DataColumn(label: Text('Name')),
                              DataColumn(label: Text('slug')),
                              DataColumn(label: Text('order')),
                              DataColumn(label: Text('操作')),
                            ],
                            rows: state.items
                                .map(
                                  (c) => DataRow(cells: [
                                    DataCell(Text(c.id)),
                                    DataCell(
                                      InkWell(
                                        onTap: () => context.go(
                                          '/admin/books?categoryId=${c.id}',
                                        ),
                                        child: Text(
                                          c.name,
                                          style: const TextStyle(
                                            color: Colors.indigo,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(Text(c.slug)),
                                    DataCell(Text('${c.order}')),
                                    DataCell(Row(
                                      children: [
                                        TextButton(
                                          onPressed: () =>
                                              _openDialog(context, row: c),
                                          child: const Text('编辑'),
                                        ),
                                        TextButton(
                                          onPressed: () => _delete(context, c),
                                          style: TextButton.styleFrom(
                                              foregroundColor: Colors.red),
                                          child: const Text('删除'),
                                        ),
                                      ],
                                    )),
                                  ]),
                                )
                                .toList(),
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
