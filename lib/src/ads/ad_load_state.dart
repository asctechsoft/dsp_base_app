/// Trạng thái tải một quảng cáo toàn màn hình (Interstitial/Rewarded/
/// AppOpen). Banner/Native có widget tự quản vòng đời riêng nên không cần
/// state này.
///
/// `sealed` để nơi dùng bắt buộc xử lý đủ nhánh qua pattern matching
/// (`switch`), tránh sót trường hợp như khi dùng enum + if-else rải rác.
sealed class AdLoadState {
  const AdLoadState();
}

/// Chưa gọi `load()` lần nào.
class AdIdle extends AdLoadState {
  const AdIdle();
}

class AdLoading extends AdLoadState {
  const AdLoading();
}

class AdLoaded extends AdLoadState {
  const AdLoaded();
}

class AdFailed extends AdLoadState {
  const AdFailed(this.error);
  final String error;
}

/// Đang hiện toàn màn hình (Interstitial/Rewarded/AppOpen).
class AdShown extends AdLoadState {
  const AdShown();
}
