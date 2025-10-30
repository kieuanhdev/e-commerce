import 'package:equatable/equatable.dart';

// Một class cơ sở cho tất cả các lỗi trong ứng dụng
class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}
