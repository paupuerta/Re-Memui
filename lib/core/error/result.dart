import 'package:fpdart/fpdart.dart';

import 'failure.dart';

/// A type alias for results that can fail.
/// Uses Either from fpdart: Left = Failure, Right = Success.
typedef Result<T> = Either<Failure, T>;

/// Convenience alias for async results.
typedef AsyncResult<T> = Future<Result<T>>;
