import '../error/exceptions.dart';
import '../error/failures.dart';

/// Either a [Success] with data or an [Err] with a [Failure].
sealed class Result<T> {
  const Result();

  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) => switch (this) {
    Success<T>(:final data) => success(data),
    Err<T>(failure: final f) => failure(f),
  };
}

class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;
}

class Err<T> extends Result<T> {
  const Err(this.failure);
  final Failure failure;
}

/// Runs a data-source call and converts thrown [AppException]s to [Err].
/// Use it inside repository implementations.
Future<Result<T>> guard<T>(Future<T> Function() call) async {
  try {
    return Success(await call());
  } on AppException catch (e) {
    return Err(Failure.fromException(e));
  } catch (_) {
    return const Err(UnknownFailure());
  }
}
