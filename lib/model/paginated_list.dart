import 'package:chopper/chopper.dart';
import 'package:equatable/equatable.dart';

class Paginated<T> extends Equatable {
  final List<T>? list;
  final int page;
  final int totalPageCount;
  final int totalCount;

  operator +(Paginated<T> nextPage) {
    return Paginated((list ?? []) + (nextPage.list ?? []), nextPage.page, nextPage.totalPageCount,
        nextPage.totalCount);
  }

  bool get hasMore => list != null && list!.length < totalCount && page < totalPageCount;

  @override
  String toString({bool omitList = true}) {
    return 'Paginated{page: $page, count: ${list?.length},totalPageCount: $totalPageCount,  totalCount: $totalCount${omitList == true ? '' : ', list: $list'}}';
  }

  const Paginated(
    this.list,
    this.page,
    this.totalPageCount,
    this.totalCount,
  );

  factory Paginated.fromResponse(Response<List<T>> response) => Paginated(
        response.body,
        int.tryParse(response.headers[PAGE_KEY] ?? '') ?? 0,
        int.tryParse(response.headers[TOTAL_PAGE_KEY] ?? '') ?? 0,
        int.tryParse(response.headers[COUNT_KEY] ?? '') ?? 0,
      );

  @override
  List<Object?> get props => [
        this.list,
        this.page,
        this.totalCount,
      ];

  static const String PAGE_KEY = 'x-pagination-current-page';
  static const String TOTAL_PAGE_KEY = 'x-pagination-page-count';
  static const String COUNT_KEY = 'x-pagination-total-count';
}