import '../../../../core/error/failures.dart';
import '../../../../core/platform/link_opener.dart';
import '../../../../core/utils/result.dart';
import '../repositories/home_repository.dart';

/// Opens a WhatsApp chat with the support team, with [message] ready to send.
class ContactSupport {
  const ContactSupport(this._repository, this._opener);

  final HomeRepository _repository;
  final LinkOpener _opener;

  Future<Result<void>> call(String message) async {
    final contact = await _repository.getSupportContact();
    return switch (contact) {
      Err(:final failure) => Err(failure),
      Success(:final data) =>
        await _opener.open(data.whatsappChat(message))
            ? const Success(null)
            : const Err(UnknownFailure('Could not open WhatsApp')),
    };
  }
}
