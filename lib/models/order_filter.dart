import 'package:meta/meta.dart';

class OrderFilter {
  final bool completed;
  final DateTime lastDate;

  OrderFilter({@required this.completed, this.lastDate});

  @override
  String toString() {
    return 'OrderFilter{completed: $completed, lastDate: $lastDate}';
  }

}
