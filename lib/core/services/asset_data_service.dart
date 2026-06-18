import '../models/artist_profile.dart';
import '../models/daily_quote.dart';
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

  /// 每日一言列表。现为写死占位,将来可改为从 Firebase / 接口拉取,
  /// 方法签名(Future)不变,调用方无需改动。
  Future<List<DailyQuote>> loadDailyQuotes() async {
    return const [
      DailyQuote(
        background: 'assets/images/bgs/1.jpeg',
        lines: ['I never needed you to love me,', 'I just wanted you near me.'],
        source: 'MAGIC MAN · 2022',
      ),
      DailyQuote(
        background: 'assets/images/bgs/2.jpeg',
        lines: ['Dreams are made', 'to be chased.'],
        source: 'TEAM WANG · 2021',
      ),
      DailyQuote(
        background: 'assets/images/bgs/3.jpeg',
        lines: ['Stay true', 'to yourself.'],
        source: 'JACKSON WANG · 2020',
      ),
      DailyQuote(
        background: 'assets/images/bgs/4.jpeg',
        lines: ['Pretty in pink,', 'tough in heart.'],
        source: 'PRETTY IN PINK · 2023',
      ),
      DailyQuote(
        background: 'assets/images/bgs/5.jpeg',
        lines: ['Light it up', 'and never stop.'],
        source: 'MAGIC MAN · 2022',
      ),
      DailyQuote(
        background: 'assets/images/bgs/6.jpeg',
        lines: ['Keep moving,', 'keep shining.'],
        source: 'TEAM WANG · 2024',
      ),
    ];
  }
}
