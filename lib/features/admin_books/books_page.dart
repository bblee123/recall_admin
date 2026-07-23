import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oktoast/oktoast.dart';

import '../../core/env.dart';
import '../../core/network/api_exception.dart';
import '../../data/models/book.dart';
import '../../data/repositories/book_repository.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/word_repository.dart';
import 'books_cubit.dart';
import 'books_state.dart';
import 'widgets/book_edit_dialog.dart';

/// 书籍管理页（对照 admin-books/index.vue）。
class BooksPage extends StatelessWidget {
  const BooksPage({super.key, this.categoryId});

  final String? categoryId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BooksCubit>(
      create: (context) => BooksCubit(
        bookRepository: context.read<BookRepository>(),
        categoryRepository: context.read<CategoryRepository>(),
        initialCategoryId: categoryId,
      )..init(),
      child: const _BooksView(),
    );
  }
}

class _BooksView extends StatelessWidget {
  const _BooksView();

  Future<void> _edit(BuildContext context, {Book? initial}) async {
    final cubit = context.read<BooksCubit>();
    final wordRepo = context.read<WordRepository>();
    if (cubit.state.categoryId.isEmpty) {
      showToast('请先选择分类');
      return;
    }
    await showBookEditDialog(
      context,
      initial: initial,
      cubit: cubit,
      wordRepository: wordRepo,
    );
  }

  Future<void> _delete(BuildContext context, Book book) async {
    final cubit = context.read<BooksCubit>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await cubit.deleteBook(book.id);
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
        child: BlocBuilder<BooksCubit, BooksState>(
          builder: (context, state) {
            final cubit = context.read<BooksCubit>();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('分类：'),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 240,
                      child: DropdownButtonFormField<String>(
                        initialValue: state.categoryId.isEmpty
                            ? null
                            : state.categoryId,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: state.categories
                            .map(
                              (c) => DropdownMenuItem(
                                value: c.id,
                                child: Text(c.name),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) cubit.selectCategory(v);
                        },
                      ),
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: () => _edit(context),
                      icon: const Icon(Icons.add),
                      label: const Text('添加书籍'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (state.error != null)
                  Text(
                    '错误：${state.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    child: state.loading
                        ? const Center(child: CircularProgressIndicator())
                        : SingleChildScrollView(
                            child: DataTable(
                              dataRowMaxHeight: double.infinity,
                              columns: const [
                                // DataColumn(label: Text('ID')),
                                DataColumn(label: Text('Name')),
                                DataColumn(label: Text('封面')),
                                DataColumn(label: Text('isFree')),
                                DataColumn(label: Text('单元')),
                                DataColumn(label: Text('order')),
                                DataColumn(label: Text('操作')),
                              ],
                              rows: state.books
                                  .map((b) => _row(context, b))
                                  .toList(),
                            ),
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

  DataRow _row(BuildContext context, Book b) {
    return DataRow(
      cells: [
        // DataCell(
        //   ConstrainedBox(
        //     constraints: const BoxConstraints(maxWidth: 160),
        //     child: Text(b.id, overflow: TextOverflow.ellipsis),
        //   ),
        // ),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Title: ${b.title}'),
                Text(
                  'subtitle: ${b.subtitle}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        DataCell(
          b.coverUrl.isEmpty
              ? const SizedBox(width: 48)
              : Image.network(
                  Env.r2Url(b.coverUrl),
                  width: 48,
                  height: 64,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      const Icon(Icons.broken_image, size: 24),
                ),
        ),
        DataCell(
          b.isFree
              ? const Text('免费', style: TextStyle(color: Colors.green))
              : const Text('付费', style: TextStyle(color: Colors.red)),
        ),
        DataCell(
          Padding(
            padding: EdgeInsets.only(top: 10, bottom: 10),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 200),
              child: Wrap(
                spacing: 2,
                runSpacing: 1,
                children: b.units
                    .map(
                      (u) => Chip(
                        label: Text(
                          u.title,
                          style: const TextStyle(fontSize: 10),
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
        DataCell(Text('${b.order}')),
        DataCell(
          Row(
            children: [
              TextButton(
                onPressed: () => _edit(context, initial: b),
                child: const Text('编辑'),
              ),
              TextButton(
                onPressed: () => _delete(context, b),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('删除'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
