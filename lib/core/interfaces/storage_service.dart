abstract class StorageService {
  Future<void> initialize();
  Future<String?> uploadImage(String filePath, String folder);
  Future<void> deleteImage(String url);
  Future<String> getImageUrl(String path);
  Future<List<String>> getImageUrls(List<String> paths);
  Future<void> downloadAndCache(String url, String localPath);
}
