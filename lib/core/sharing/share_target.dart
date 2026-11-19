/// Where a link can be sent, in the order the share sheet shows them.
enum ShareTarget {
  whatsapp,
  facebook,
  instagram,
  snapchat,
  messenger,
  x,
  copyLink,
  more,
}

/// What happened when the customer picked a [ShareTarget].
enum ShareOutcome {
  /// Another app took the link.
  opened,

  /// The link is on the clipboard (to paste where there is no share address).
  copied,

  /// The target app is missing or refused the link.
  failed,
}
