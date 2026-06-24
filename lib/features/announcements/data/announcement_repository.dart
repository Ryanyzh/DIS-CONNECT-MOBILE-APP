import '../../../core/network/api_client.dart';
import '../presentation/announcements_screen.dart';

class AnnouncementRepository {
  final ApiClient apiClient;

  AnnouncementRepository(this.apiClient);

  Future<List<AnnouncementEntry>> getAnnouncements() async {
    final response = await apiClient.get('/api/announcements') as List;
    return response
        .map((item) => AnnouncementEntry.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<AnnouncementEntry> getAnnouncementById(String id) async {
    final json =
        await apiClient.get('/api/announcements/$id') as Map<String, dynamic>;
    return AnnouncementEntry.fromJson(json);
  }
}
