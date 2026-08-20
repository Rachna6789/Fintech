import 'package:flutter/widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final imageCacheServiceProvider = Provider<ImageCacheService>((ref) {
  return ImageCacheService();
});

class ImageCacheService {
  ImageCacheService();

  ImageProvider cachedImage(String url, {String? cacheKey}) {
    return CachedNetworkImageProvider(url, cacheKey: cacheKey);
  }

  Future<void> evict(String url, {String? cacheKey}) async {
    final provider = CachedNetworkImageProvider(url, cacheKey: cacheKey);
    await provider.evict();
  }

  void clearMemoryCache() {
    imageCache.clear();
    imageCache.clearLiveImages();
  }

  Future<void> clearDiskCache() async {
    await CachedNetworkImage.evictFromCache('');
  }
}
