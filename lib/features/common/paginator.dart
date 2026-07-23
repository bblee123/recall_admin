import 'package:flutter/material.dart';

/// 通用分页条（对照 el-pagination：total/sizes/prev/pager/next/jumper）。
class Paginator extends StatelessWidget {
  const Paginator({
    super.key,
    required this.page,
    required this.pageSize,
    required this.total,
    required this.onPageChanged,
    required this.onPageSizeChanged,
    this.pageSizeOptions = const [20, 50, 100, 200],
  });

  final int page;
  final int pageSize;
  final int total;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onPageSizeChanged;
  final List<int> pageSizeOptions;

  int get _lastPage => total <= 0 ? 1 : ((total + pageSize - 1) ~/ pageSize);

  @override
  Widget build(BuildContext context) {
    final lastPage = _lastPage;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text('共 $total 条'),
          const SizedBox(width: 16),
          const Text('每页'),
          const SizedBox(width: 6),
          DropdownButton<int>(
            value: pageSizeOptions.contains(pageSize)
                ? pageSize
                : pageSizeOptions.first,
            items: pageSizeOptions
                .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                .toList(),
            onChanged: (v) {
              if (v != null) onPageSizeChanged(v);
            },
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: page > 1 ? () => onPageChanged(page - 1) : null,
          ),
          Text('$page / $lastPage'),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: page < lastPage ? () => onPageChanged(page + 1) : null,
          ),
        ],
      ),
    );
  }
}
