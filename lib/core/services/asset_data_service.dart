import '../models/artist_profile.dart';
import '../models/gallery_photo.dart';
import '../models/work_item.dart';

class AssetDataService {
  const AssetDataService();

  Future<ArtistProfile> loadArtistProfile() async {
    return const ArtistProfile(
      name: 'Jackson Wang',
      chineseName: '王嘉尔',
      bio: '音乐人、唱作人、舞台表演者。这里之后会改成 assets/data 里的真实简介。',
      avatar: '',
      heroImages: [],
    );
  }

  Future<List<WorkItem>> loadWorks() async {
    return const [];
  }

  Future<List<GalleryPhoto>> loadGalleryPhotos() async {
    return const [];
  }
}
