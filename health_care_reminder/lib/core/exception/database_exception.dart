abstract class DatabaseException implements Exception {
  final String message;
  DatabaseException(this.message);
}

class DatabaseOpenException extends DatabaseException {
  DatabaseOpenException(super.message);
}

class DatabaseInsertException extends DatabaseException {
  DatabaseInsertException(super.message);
}

class DatabaseReadException extends DatabaseException {
  DatabaseReadException(super.message);
}

class DatabaseUpdateException extends DatabaseException {
  DatabaseUpdateException(super.message);
}

class DatabaseDeleteException extends DatabaseException {
  DatabaseDeleteException(super.message);
}
