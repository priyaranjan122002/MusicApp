
abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure() : super('NO INTERNET CONNECTION');
}

class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);
}
