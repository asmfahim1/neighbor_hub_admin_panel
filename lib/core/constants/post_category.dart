/// Mirrors `posts/{postId}.category` in `05_FIRESTORE_DATABASE.md` §3.5.
///
/// `null` on the document means uncategorized — modeled here as [none];
/// use [valueOrNull] when writing back to Firestore.
enum PostCategory {
  discussion,
  recommendation,
  help,
  service,
  none;

  String? get valueOrNull => switch (this) {
        PostCategory.discussion => 'discussion',
        PostCategory.recommendation => 'recommendation',
        PostCategory.help => 'help',
        PostCategory.service => 'service',
        PostCategory.none => null,
      };

  static PostCategory fromValue(String? value) => switch (value) {
        'discussion' => PostCategory.discussion,
        'recommendation' => PostCategory.recommendation,
        'help' => PostCategory.help,
        'service' => PostCategory.service,
        _ => PostCategory.none,
      };
}
