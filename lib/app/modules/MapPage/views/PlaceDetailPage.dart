import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:smart_tourism_guide/app/modules/MapPage/models/TouristPlace.dart';

class PlaceDetailPage extends StatefulWidget {
  final TouristPlace place;
  const PlaceDetailPage({Key? key, required this.place}) : super(key: key);

  @override
  State<PlaceDetailPage> createState() => _PlaceDetailPageState();
}

class _PlaceDetailPageState extends State<PlaceDetailPage>
    with TickerProviderStateMixin {
  final PageController _pageCtrl = PageController();
  final ScrollController _scrollCtrl = ScrollController();

  int _currentImage = 0;
  int _currentVideo = 0;
  bool _isFavorite = false;
  bool _showVideo = false;
  bool _descExpanded = false;
  double _scrollOffset = 0;

  late AnimationController _fadeCtrl;
  late AnimationController _slideCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  TouristPlace get place => widget.place;

  PlaceCategory get _cat => TouristPlace.parseCategory(place.category);

  Color get _accent {
    switch (_cat) {
      case PlaceCategory.touristic:
        return const Color(0xFFFF6B35);
      case PlaceCategory.cultural:
        return const Color(0xFFB06AE8);
      case PlaceCategory.nature:
        return const Color(0xFF3ECF8E);
      case PlaceCategory.beach:
        return const Color(0xFF38BDF8);
      case PlaceCategory.market:
        return const Color(0xFFFF8C42);
      case PlaceCategory.historic:
        return const Color(0xFFD4A843);
    }
  }

  Color get _accentDark {
    switch (_cat) {
      case PlaceCategory.touristic:
        return const Color(0xFFCC4A1A);
      case PlaceCategory.cultural:
        return const Color(0xFF7C3CAD);
      case PlaceCategory.nature:
        return const Color(0xFF1E9E63);
      case PlaceCategory.beach:
        return const Color(0xFF0286C3);
      case PlaceCategory.market:
        return const Color(0xFFCC5A10);
      case PlaceCategory.historic:
        return const Color(0xFFA07820);
    }
  }

  String get _categoryLabel {
    switch (_cat) {
      case PlaceCategory.touristic:
        return 'TOURISTIC';
      case PlaceCategory.cultural:
        return 'CULTURAL';
      case PlaceCategory.nature:
        return 'NATURE';
      case PlaceCategory.beach:
        return 'BEACH';
      case PlaceCategory.market:
        return 'MARKET';
      case PlaceCategory.historic:
        return 'HISTORIC';
    }
  }

  IconData get _categoryIcon {
    switch (_cat) {
      case PlaceCategory.touristic:
        return Icons.location_city_outlined;
      case PlaceCategory.cultural:
        return Icons.account_balance_outlined;
      case PlaceCategory.nature:
        return Icons.forest_outlined;
      case PlaceCategory.beach:
        return Icons.beach_access_outlined;
      case PlaceCategory.market:
        return Icons.storefront_outlined;
      case PlaceCategory.historic:
        return Icons.history_edu_outlined;
    }
  }

  String get _address {
    if (place.localisation.isEmpty) return '';
    return place.localisation.join(', ');
  }

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));
    _scrollCtrl.addListener(
      () => setState(() => _scrollOffset = _scrollCtrl.offset),
    );
    Future.delayed(const Duration(milliseconds: 100), () {
      _fadeCtrl.forward();
      _slideCtrl.forward();
    });
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _scrollCtrl.dispose();
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final heroH = MediaQuery.of(context).size.height * 0.52;
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollCtrl,
            slivers: [
              SliverToBoxAdapter(child: _buildHero(heroH)),
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: _buildContent(),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
          _buildTopBar(),
          Positioned(bottom: 0, left: 0, right: 0, child: _buildBottomBar()),
        ],
      ),
    );
  }

  // ── HERO ──────────────────────────────────────────────────────────────────

  Widget _buildHero(double heroH) {
    final parallax = _scrollOffset * 0.4;
    final allImages = [
      if (place.imageAsset.isNotEmpty) place.imageAsset,
      ...place.images,
    ];

    return SizedBox(
      height: heroH,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Transform.translate(
            offset: Offset(0, -parallax),
            child: SizedBox(
              height: heroH + 80,
              child: _showVideo && place.videoUrls.isNotEmpty
                  ? _buildVideoArea()
                  : _buildImageCarousel(allImages),
            ),
          ),

          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    const Color(0xFF0D0D0D).withOpacity(0.6),
                    const Color(0xFF0D0D0D),
                  ],
                  stops: const [0, 0.45, 0.75, 1],
                ),
              ),
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 100,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black54, Colors.transparent],
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 56,
            left: 20,
            child: Row(
              children: [
                _Pill(
                  label: _categoryLabel,
                  icon: _categoryIcon,
                  color: _accent,
                ),
                const SizedBox(width: 8),
                _Pill(
                  label: '${place.rating} ★',
                  icon: null,
                  color: const Color(0xFFFFC107),
                ),
              ],
            ),
          ),

          if (place.videoUrls.isNotEmpty)
            Positioned(
              bottom: 48,
              right: 20,
              child: GestureDetector(
                onTap: () => setState(() => _showVideo = !_showVideo),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _showVideo ? _accent : Colors.black54,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _accent.withOpacity(0.6),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    _showVideo
                        ? Icons.image_outlined
                        : Icons.play_circle_outline,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),

          if (!_showVideo && allImages.length > 1)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  math.min(allImages.length, 8),
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: _currentImage == i ? 20 : 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: _currentImage == i ? _accent : Colors.white38,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),

          if (_showVideo && place.videoUrls.length > 1)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  place.videoUrls.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: _currentVideo == i ? 20 : 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: _currentVideo == i ? _accent : Colors.white38,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel(List<String> allImages) {
    if (allImages.isEmpty) {
      return Container(
        color: const Color(0xFF1A1A1A),
        child: Icon(_categoryIcon, size: 80, color: _accent.withOpacity(0.25)),
      );
    }
    return PageView.builder(
      controller: _pageCtrl,
      itemCount: allImages.length,
      onPageChanged: (i) => setState(() => _currentImage = i),
      itemBuilder: (_, i) {
        final src = allImages[i];
        final isNet = src.startsWith('http://') || src.startsWith('https://');
        return isNet
            ? Image.network(
                src,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) => progress == null
                    ? child
                    : Container(
                        color: const Color(0xFF1A1A1A),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: _accent,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFF1A1A1A),
                  child: Icon(
                    _categoryIcon,
                    size: 80,
                    color: _accent.withOpacity(0.25),
                  ),
                ),
              )
            : Image.asset(
                src,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFF1A1A1A),
                  child: Icon(
                    _categoryIcon,
                    size: 80,
                    color: _accent.withOpacity(0.25),
                  ),
                ),
              );
      },
    );
  }

  // ── Video area — real video_player ────────────────────────────────────────
  Widget _buildVideoArea() {
    return PageView.builder(
      itemCount: place.videoUrls.length,
      onPageChanged: (i) => setState(() => _currentVideo = i),
      itemBuilder: (_, i) => _VideoPlayerCard(
        url: place.videoUrls[i],
        accent: _accent,
        index: i,
        total: place.videoUrls.length,
        autoPlay: i == _currentVideo,
      ),
    );
  }

  // ── CONTENT ───────────────────────────────────────────────────────────────

  Widget _buildContent() {
    final allImages = [
      if (place.imageAsset.isNotEmpty) place.imageAsset,
      ...place.images,
    ];

    return Container(
      color: const Color(0xFF0D0D0D),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    place.name,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.1,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => setState(() => _isFavorite = !_isFavorite),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _isFavorite
                          ? _accent.withOpacity(0.15)
                          : Colors.white.withOpacity(0.06),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _isFavorite
                            ? _accent.withOpacity(0.5)
                            : Colors.white12,
                      ),
                    ),
                    child: Icon(
                      _isFavorite ? Icons.bookmark : Icons.bookmark_border,
                      color: _isFavorite ? _accent : Colors.white54,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          if (_address.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 13, color: _accent),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      _address,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white54,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _StatBox(
                  label: 'Distance',
                  value: place.distance,
                  icon: Icons.directions_walk,
                  accent: _accent,
                ),
                const SizedBox(width: 10),
                _StatBox(
                  label: 'Opens',
                  value: place.openingHours.contains('–')
                      ? place.openingHours.split('–')[0].trim()
                      : place.openingHours,
                  icon: Icons.access_time_outlined,
                  accent: _accent,
                ),
                const SizedBox(width: 10),
                _StatBox(
                  label: 'Rating',
                  value: '${place.rating}/5',
                  icon: Icons.star_outline_rounded,
                  accent: const Color(0xFFFFC107),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _ARButton(
              accent: _accent,
              accentDark: _accentDark,
              placeName: place.name,
            ),
          ),

          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionTitle(title: 'About this place', accent: _accent),
                const SizedBox(height: 10),
                AnimatedCrossFade(
                  firstChild: Text(
                    place.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      height: 1.7,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  secondChild: Text(
                    place.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      height: 1.7,
                    ),
                  ),
                  crossFadeState: _descExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => setState(() => _descExpanded = !_descExpanded),
                  child: Text(
                    _descExpanded ? 'Show less ↑' : 'Read more ↓',
                    style: TextStyle(
                      fontSize: 13,
                      color: _accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionTitle(title: 'Quick Info', accent: _accent),
                const SizedBox(height: 12),
                _InfoGrid(place: place, accent: _accent),
              ],
            ),
          ),

          const SizedBox(height: 28),

          if (allImages.length > 1) ...[
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
              child: _SectionTitle(title: 'Gallery', accent: _accent),
            ),
            _Gallery(
              images: allImages,
              accent: _accent,
              onTap: (i) {
                setState(() => _showVideo = false);
                _pageCtrl.animateToPage(
                  i,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                );
                _scrollCtrl.animateTo(
                  0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              },
            ),
            const SizedBox(height: 28),
          ],

          if (place.videoUrls.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
              child: _SectionTitle(
                title: 'Videos (${place.videoUrls.length})',
                accent: _accent,
              ),
            ),
            _VideoList(
              videoUrls: place.videoUrls,
              accent: _accent,
              currentIndex: _currentVideo,
              onTap: (i) {
                setState(() {
                  _currentVideo = i;
                  _showVideo = true;
                });
                _scrollCtrl.animateTo(
                  0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              },
            ),
            const SizedBox(height: 28),
          ],

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionTitle(title: 'Content Available', accent: _accent),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _ContentCard(
                      icon: Icons.videocam_outlined,
                      value: '${place.videoUrls.length}',
                      label: 'Videos',
                      accent: _accent,
                    ),
                    const SizedBox(width: 10),
                    _ContentCard(
                      icon: Icons.photo_library_outlined,
                      value: '${allImages.length}',
                      label: 'Photos',
                      accent: _accent,
                    ),
                    const SizedBox(width: 10),
                    _ContentCard(
                      icon: Icons.view_in_ar_outlined,
                      value: 'AR',
                      label: 'Experience',
                      accent: _accentDark,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _TagsRow(category: place.category, accent: _accent),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── TOP BAR ───────────────────────────────────────────────────────────────

  Widget _buildTopBar() {
    final opacity = (_scrollOffset / 100).clamp(0.0, 1.0);
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 8,
          left: 16,
          right: 16,
          bottom: 8,
        ),
        color: const Color(0xFF0D0D0D).withOpacity(opacity),
        child: Row(
          children: [
            _CircleBtn(icon: Icons.arrow_back_ios_new, onTap: () => Get.back()),
            const Spacer(),
            if (opacity > 0.5)
              Expanded(
                child: Text(
                  place.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            const Spacer(),
            _CircleBtn(icon: Icons.share_outlined, onTap: _onShare),
          ],
        ),
      ),
    );
  }

  void _onShare() => Get.snackbar(
    'Share',
    'Sharing ${place.name}...',
    snackPosition: SnackPosition.TOP,
    backgroundColor: const Color(0xFF1A1A1A),
    colorText: Colors.white,
    margin: const EdgeInsets.all(16),
    borderRadius: 12,
    duration: const Duration(seconds: 2),
  );

  // ── BOTTOM BAR ────────────────────────────────────────────────────────────

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06))),
      ),
      child: Row(
        children: [
          if (place.videoUrls.isNotEmpty)
            Expanded(
              child: _ActionButton(
                label: '${place.videoUrls.length} Videos',
                icon: Icons.play_circle_outline,
                color: Colors.white.withOpacity(0.08),
                textColor: Colors.white,
                borderColor: Colors.white12,
                onTap: () => setState(() => _showVideo = true),
              ),
            ),
          if (place.videoUrls.isNotEmpty) const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: _ActionButton(
              label: 'Explore Now',
              icon: Icons.explore_outlined,
              color: _accent,
              textColor: Colors.white,
              borderColor: Colors.transparent,
              onTap: _onExplore,
            ),
          ),
        ],
      ),
    );
  }

  void _onExplore() => Get.snackbar(
    '🗺️ Explore',
    'Starting guided tour of ${place.name}',
    snackPosition: SnackPosition.TOP,
    backgroundColor: _accent,
    colorText: Colors.white,
    margin: const EdgeInsets.all(16),
    borderRadius: 12,
  );
}

// ─── Real Video Player Card ───────────────────────────────────────────────────
// Add to pubspec.yaml:  video_player: ^2.9.1

class _VideoPlayerCard extends StatefulWidget {
  final String url;
  final Color accent;
  final int index, total;
  final bool autoPlay;

  const _VideoPlayerCard({
    required this.url,
    required this.accent,
    required this.index,
    required this.total,
    this.autoPlay = false,
  });

  @override
  State<_VideoPlayerCard> createState() => _VideoPlayerCardState();
}

class _VideoPlayerCardState extends State<_VideoPlayerCard> {
  VideoPlayerController? _ctrl;
  bool _initialized = false;
  bool _error = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      final uri = Uri.parse(widget.url);
      _ctrl = VideoPlayerController.networkUrl(uri);
      await _ctrl!.initialize();
      if (!mounted) return;
      setState(() => _initialized = true);
      if (widget.autoPlay) _ctrl!.play();
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = true);
    }
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (_ctrl == null || !_initialized) return;
    setState(() {
      _ctrl!.value.isPlaying ? _ctrl!.pause() : _ctrl!.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: widget.accent, size: 48),
              const SizedBox(height: 12),
              const Text(
                'Failed to load video',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    if (!_initialized) {
      return Container(
        color: Colors.black,
        child: Center(
          child: CircularProgressIndicator(
            color: widget.accent,
            strokeWidth: 2,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        _togglePlay();
        setState(() => _showControls = true);
      },
      child: Container(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video
            Center(
              child: AspectRatio(
                aspectRatio: _ctrl!.value.aspectRatio,
                child: VideoPlayer(_ctrl!),
              ),
            ),

            // Play/pause overlay
            if (_showControls)
              Center(
                child: GestureDetector(
                  onTap: _togglePlay,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black54,
                      border: Border.all(color: widget.accent, width: 2),
                    ),
                    child: ValueListenableBuilder<VideoPlayerValue>(
                      valueListenable: _ctrl!,
                      builder: (_, v, __) => Icon(
                        v.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: widget.accent,
                        size: 36,
                      ),
                    ),
                  ),
                ),
              ),

            // Progress bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ValueListenableBuilder<VideoPlayerValue>(
                valueListenable: _ctrl!,
                builder: (_, v, __) {
                  final total = v.duration.inMilliseconds;
                  final pos = v.position.inMilliseconds;
                  final progress = total > 0 ? pos / total : 0.0;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Scrubber
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 3,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 12,
                            ),
                            activeTrackColor: widget.accent,
                            inactiveTrackColor: Colors.white24,
                            thumbColor: widget.accent,
                          ),
                          child: Slider(
                            value: progress.clamp(0.0, 1.0),
                            onChanged: (val) {
                              final newPos = Duration(
                                milliseconds: (total * val).toInt(),
                              );
                              _ctrl!.seekTo(newPos);
                            },
                          ),
                        ),
                      ),
                      // Time + index label
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                        child: Row(
                          children: [
                            Text(
                              _fmt(v.position),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'Video ${widget.index + 1} / ${widget.total}',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 11,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _fmt(v.duration),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

// ─── Video thumbnail list ─────────────────────────────────────────────────────

class _VideoList extends StatelessWidget {
  final List<String> videoUrls;
  final Color accent;
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _VideoList({
    required this.videoUrls,
    required this.accent,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: videoUrls.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => onTap(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 130,
            height: 90,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: currentIndex == i ? accent : Colors.white12,
                width: currentIndex == i ? 2 : 1,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.play_circle_outline,
                  color: currentIndex == i ? accent : Colors.white38,
                  size: 32,
                ),
                Positioned(
                  bottom: 6,
                  left: 8,
                  child: Text(
                    'Video ${i + 1}',
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (currentIndex == i)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── AR Button ────────────────────────────────────────────────────────────────

class _ARButton extends StatefulWidget {
  final Color accent, accentDark;
  final String placeName;
  const _ARButton({
    required this.accent,
    required this.accentDark,
    required this.placeName,
  });

  @override
  State<_ARButton> createState() => _ARButtonState();
}

class _ARButtonState extends State<_ARButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.snackbar(
          '🥽 AR Experience',
          'Launching AR for ${widget.placeName}...',
          snackPosition: SnackPosition.TOP,
          backgroundColor: widget.accent,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 3),
        );
      },
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (_, __) => Container(
          height: 58,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                widget.accent.withOpacity(0.15 + _pulse.value * 0.08),
                widget.accentDark.withOpacity(0.1 + _pulse.value * 0.05),
              ],
            ),
            border: Border.all(
              color: widget.accent.withOpacity(0.4 + _pulse.value * 0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.accent.withOpacity(0.15),
                  boxShadow: [
                    BoxShadow(
                      color: widget.accent.withOpacity(0.4 * _pulse.value),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.view_in_ar_outlined,
                  color: widget.accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Launch AR Experience',
                    style: TextStyle(
                      color: widget.accent,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  Text(
                    'Point camera · Discover in 3D',
                    style: TextStyle(
                      color: widget.accent.withOpacity(0.6),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'NEW',
                  style: TextStyle(
                    color: widget.accent,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(width: 14),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Gallery ──────────────────────────────────────────────────────────────────

class _Gallery extends StatelessWidget {
  final List<String> images;
  final Color accent;
  final ValueChanged<int> onTap;
  const _Gallery({
    required this.images,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: images.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final src = images[i];
          final isNet = src.startsWith('http://') || src.startsWith('https://');
          return GestureDetector(
            onTap: () => onTap(i),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  isNet
                      ? Image.network(
                          src,
                          width: 140,
                          height: 110,
                          fit: BoxFit.cover,
                          loadingBuilder: (_, child, progress) =>
                              progress == null
                              ? child
                              : Container(
                                  width: 140,
                                  height: 110,
                                  color: const Color(0xFF1A1A1A),
                                ),
                          errorBuilder: (_, __, ___) => Container(
                            width: 140,
                            height: 110,
                            color: const Color(0xFF1A1A1A),
                            child: Icon(
                              Icons.image_outlined,
                              color: accent.withOpacity(0.3),
                              size: 30,
                            ),
                          ),
                        )
                      : Image.asset(
                          src,
                          width: 140,
                          height: 110,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 140,
                            height: 110,
                            color: const Color(0xFF1A1A1A),
                            child: Icon(
                              Icons.image_outlined,
                              color: accent.withOpacity(0.3),
                              size: 30,
                            ),
                          ),
                        ),
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${i + 1}/${images.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Info grid ────────────────────────────────────────────────────────────────

class _InfoGrid extends StatelessWidget {
  final TouristPlace place;
  final Color accent;
  const _InfoGrid({required this.place, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _InfoRow(
              icon: Icons.access_time_outlined,
              label: 'Hours',
              value: place.openingHours,
              accent: accent,
            ),
            const SizedBox(width: 10),
            _InfoRow(
              icon: Icons.directions_walk,
              label: 'Distance',
              value: place.distance,
              accent: accent,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _InfoRow(
              icon: Icons.star_outline_rounded,
              label: 'Rating',
              value: '${place.rating} / 5.0',
              accent: const Color(0xFFFFC107),
            ),
            const SizedBox(width: 10),
            _InfoRow(
              icon: Icons.videocam_outlined,
              label: 'Videos',
              value: '${place.videoUrls.length} available',
              accent: accent,
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color accent;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 15, color: accent),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 9,
                      color: Colors.white38,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Content card ─────────────────────────────────────────────────────────────

class _ContentCard extends StatelessWidget {
  final IconData icon;
  final String value, label;
  final Color accent;
  const _ContentCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Column(
          children: [
            Icon(icon, color: accent, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: accent,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white38,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tags ─────────────────────────────────────────────────────────────────────

class _TagsRow extends StatelessWidget {
  final String category;
  final Color accent;
  const _TagsRow({required this.category, required this.accent});

  static const _tagsByCategory = {
    'touristic': ['Must Visit', 'Photography', 'Iconic', 'Guided Tours'],
    'cultural': ['Art & Culture', 'Museum', 'Heritage', 'Education'],
    'nature': ['Outdoor', 'Eco-Tourism', 'Wildlife', 'Trekking'],
    'beach': ['Swimming', 'Snorkeling', 'Sunset Views', 'Water Sports'],
    'market': ['Shopping', 'Street Food', 'Local Crafts', 'Bargains'],
    'historic': ['UNESCO', 'Ancient', 'Architecture', 'History'],
  };

  @override
  Widget build(BuildContext context) {
    final tags =
        _tagsByCategory[category] ??
        ['Must Visit', 'Photography', 'Family Friendly', 'Accessible'];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags
          .map(
            (t) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: accent.withOpacity(0.2)),
              ),
              child: Text(
                t,
                style: TextStyle(
                  fontSize: 11,
                  color: accent.withOpacity(0.9),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

// ─── Stat box ─────────────────────────────────────────────────────────────────

class _StatBox extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color accent;
  const _StatBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: accent),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                color: Colors.white38,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Pill ─────────────────────────────────────────────────────────────────────

class _Pill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;
  const _Pill({required this.label, this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section title ────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  final Color accent;
  const _SectionTitle({required this.title, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

// ─── Circle button ────────────────────────────────────────────────────────────

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white12),
        ),
        child: Icon(icon, size: 17, color: Colors.white),
      ),
    );
  }
}

// ─── Action button ────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color, textColor, borderColor;
  final VoidCallback onTap;
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.textColor,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 17),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
