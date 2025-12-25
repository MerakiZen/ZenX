import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/design/hevy_colors.dart';
import '../../../../core/utils/share_service.dart';
import '../../domain/entities/workout_post.dart';
import '../../domain/entities/post_comment.dart';
import '../../domain/entities/suggested_athlete.dart';
import '../../../auth/domain/entities/user.dart';
import '../providers/feed_providers.dart';
import '../../../profile/presentation/providers/profile_providers.dart';

const double _kGlassBlurSigma = 22;
final ImageFilter _glassBlurFilter = ImageFilter.blur(
  sigmaX: _kGlassBlurSigma,
  sigmaY: _kGlassBlurSigma,
);

/// Home screen - Social feed for athletes (Hevy Pro style)
/// Pixel-perfect, deployment-ready implementation
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _selectedView = 'Home';
  bool _isDropdownOpen = false;
  final GlobalKey _dropdownButtonKey = GlobalKey();
  OverlayEntry? _dropdownOverlayEntry;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isVerySmallScreen = screenWidth < 320;

    return Scaffold(
      backgroundColor: HevyColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: kToolbarHeight,
        flexibleSpace: RepaintBoundary(
          child: ClipRect(
            child: BackdropFilter(
              filter: _glassBlurFilter,
              child: Container(
                decoration: BoxDecoration(
                  color: HevyColors.glassSurface,
                  border: Border(
                    bottom: BorderSide(
                      color: HevyColors.glassBorder,
                      width: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        title: _buildAppBarTitle(isSmallScreen, isVerySmallScreen),
        titleSpacing: 0,
      ),
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedView == 'Home' ? 0 : 1,
            children: const [
              _HomeView(),
              _DiscoverView(),
            ],
          ),
          // Dropdown menu will be shown via OverlayEntry (handled in _showDropdown)
        ],
      ),
    );
  }

  void _showDropdown(BuildContext context) {
    if (_dropdownOverlayEntry != null) return;

    setState(() {
      _isDropdownOpen = true;
    });

    // Wait for next frame to ensure button is rendered
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final RenderBox? buttonBox =
          _dropdownButtonKey.currentContext?.findRenderObject() as RenderBox?;
      if (buttonBox == null || !buttonBox.hasSize) {
        setState(() {
          _isDropdownOpen = false;
        });
        return;
      }

      final buttonPosition = buttonBox.localToGlobal(Offset.zero);
      final screenWidth = MediaQuery.of(context).size.width;
      final isSmallScreen = screenWidth < 360;
      final isVerySmallScreen = screenWidth < 320;

      final overlayEntry = OverlayEntry(
        builder: (context) => Stack(
          children: [
            // Backdrop
            Positioned.fill(
              child: GestureDetector(
                onTap: () => _hideDropdown(),
                child: Container(color: Colors.transparent),
              ),
            ),
            // Dropdown menustar
            Positioned(
              top: buttonPosition.dy + buttonBox.size.height + 4,
              left: buttonPosition.dx,
              child: Material(
                elevation: 0,
                color: Colors.transparent,
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth:
                        isVerySmallScreen ? 140 : (isSmallScreen ? 160 : 180),
                    minWidth: 140,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                    border: Border.all(
                      color: HevyColors.glassBorder,
                      width: 0.5,
                    ),
                    boxShadow: HevyColors.cardShadowElevated,
                  ),
                  child: RepaintBoundary(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                      child: BackdropFilter(
                        filter: _glassBlurFilter,
                        child: Container(
                          decoration: BoxDecoration(
                            color: HevyColors.glassSurface,
                            borderRadius:
                                BorderRadius.circular(DesignTokens.radiusM),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _DropdownMenuItem(
                                label: 'Home',
                                icon: Icons.home,
                                isSelected: _selectedView == 'Home',
                                onTap: () {
                                  setState(() {
                                    _selectedView = 'Home';
                                  });
                                  _hideDropdown();
                                },
                                isSmallScreen: isSmallScreen,
                              ),
                              Divider(
                                height: 1,
                                color: HevyColors.dividerGlass,
                                thickness: 0.5,
                              ),
                              _DropdownMenuItem(
                                label: 'Discover',
                                icon: Icons.explore,
                                isSelected: _selectedView == 'Discover',
                                onTap: () {
                                  setState(() {
                                    _selectedView = 'Discover';
                                  });
                                  _hideDropdown();
                                },
                                isSmallScreen: isSmallScreen,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );

      Overlay.of(context).insert(overlayEntry);
      _dropdownOverlayEntry = overlayEntry;
    });
  }

  void _hideDropdown() {
    _dropdownOverlayEntry?.remove();
    _dropdownOverlayEntry = null;
    if (mounted) {
      setState(() {
        _isDropdownOpen = false;
      });
    }
  }

  @override
  void dispose() {
    _hideDropdown();
    super.dispose();
  }

  Widget _buildAppBarTitle(bool isSmallScreen, bool isVerySmallScreen) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Dropdown button - left aligned
          Flexible(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () {
                  if (_isDropdownOpen) {
                    _hideDropdown();
                  } else {
                    _showDropdown(context);
                  }
                },
                child: Container(
                  key: _dropdownButtonKey,
                  constraints: BoxConstraints(
                    maxWidth: isVerySmallScreen ? 100 : 150,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 8 : 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: HevyColors.glassBorder,
                      width: 0.5,
                    ),
                  ),
                  child: RepaintBoundary(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: _glassBlurFilter,
                        child: Container(
                          decoration: BoxDecoration(
                            color: HevyColors.glassCard,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 8 : 12,
                            vertical: 6,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  _selectedView,
                                  style: TextStyle(
                                    color: HevyColors.textPrimary,
                                    fontSize: isSmallScreen ? 12 : 14,
                                    fontWeight: FontWeight.w300,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              SizedBox(width: isSmallScreen ? 2 : 4),
                              Icon(
                                _isDropdownOpen
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                size: isSmallScreen ? 14 : 16,
                                color: HevyColors.textPrimary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Search and notification icons - right aligned
          Flexible(
            flex: 1,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.search),
                  color: HevyColors.textPrimary,
                  iconSize: isSmallScreen ? 20 : 24,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                  onPressed: () => context.push('/search'),
                  tooltip: 'Search',
                ),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      color: HevyColors.textPrimary,
                      iconSize: isSmallScreen ? 20 : 24,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                      onPressed: () => context.push('/notifications'),
                      tooltip: 'Notifications',
                    ),
                    Positioned(
                      right: isSmallScreen ? 8 : 10,
                      top: isSmallScreen ? 8 : 10,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: HevyColors.accentRed,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownMenuItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isSmallScreen;

  const _DropdownMenuItem({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.isSmallScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 12 : 16,
          vertical: isSmallScreen ? 10 : 12,
        ),
        color: isSelected
            ? HevyColors.primary.withValues(alpha: 0.15)
            : Colors.transparent,
        child: Row(
          children: [
            Icon(
              icon,
              size: isSmallScreen ? 16 : 18,
              color: isSelected ? HevyColors.primary : HevyColors.textPrimary,
            ),
            SizedBox(width: isSmallScreen ? 10 : 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: isSmallScreen ? 13 : 14,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  color:
                      isSelected ? HevyColors.primary : HevyColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check,
                size: isSmallScreen ? 14 : 16,
                color: HevyColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}

/// Home view - Shows workout posts from followed users
class _HomeView extends ConsumerWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cacheExtent = MediaQuery.of(context).size.height * 1.5;

    final feedAsync = ref.watch(homeFeedProvider);
    return feedAsync.when(
      data: (posts) => RefreshIndicator(
        onRefresh: () => ref.refresh(homeFeedProvider.future),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          cacheExtent: cacheExtent,
          slivers: [
            SliverToBoxAdapter(child: _ProfileHeroCard()),
            SliverToBoxAdapter(child: _SuggestedAthletesSection()),
            if (posts.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: _FeedEmptyState(
                  title: 'No workouts yet',
                  subtitle: 'Log a workout to share it with your crew.',
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _WorkoutPostCard(post: posts[index]),
                  childCount: posts.length,
                ),
              ),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _FeedErrorState(
        message: 'Unable to load feed',
        onRetry: () => ref.refresh(homeFeedProvider.future),
      ),
    );
  }
}

/// Discover view - Shows posts from users not followed (like Instagram)
class _DiscoverView extends ConsumerWidget {
  const _DiscoverView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cacheExtent = MediaQuery.of(context).size.height * 1.5;

    final feedAsync = ref.watch(discoverFeedProvider);
    return feedAsync.when(
      data: (posts) => RefreshIndicator(
        onRefresh: () => ref.refresh(discoverFeedProvider.future),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          cacheExtent: cacheExtent,
          slivers: [
            if (posts.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: _FeedEmptyState(
                  title: 'Discover workouts',
                  subtitle:
                      'We will show new athletes once the community is active.',
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _DiscoverPostCard(post: posts[index]),
                  childCount: posts.length,
                ),
              ),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _FeedErrorState(
        message: 'Unable to load discover feed',
        onRetry: () => ref.refresh(discoverFeedProvider.future),
      ),
    );
  }
}

class _FeedEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;

  const _FeedEmptyState({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingXL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.dynamic_feed_outlined,
            size: 64,
            color: HevyColors.textSecondary.withValues(alpha: 0.35),
          ),
          const SizedBox(height: DesignTokens.spacingL),
          Text(
            title,
            style: const TextStyle(
              fontSize: DesignTokens.titleLarge,
              fontWeight: FontWeight.w600,
              color: HevyColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: DesignTokens.spacingS),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: DesignTokens.bodyMedium,
              color: HevyColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _FeedErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _FeedErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spacingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off,
              size: 56,
              color: HevyColors.textSecondary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: DesignTokens.spacingL),
            Text(
              message,
              style: const TextStyle(
                fontSize: DesignTokens.bodyLarge,
                color: HevyColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignTokens.spacingM),
            TextButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeroCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaQuery = MediaQuery.of(context);
    final isSmallScreen = mediaQuery.size.width < 360;
    final padding = isSmallScreen ? 14.0 : DesignTokens.paddingScreen;

    final profileAsync = ref.watch(profileViewProvider);

    return profileAsync.when(
      loading: () => const _ProfileHeroLoading(),
      error: (err, _) => const SizedBox.shrink(),
      data: (data) {
        final profile = data.profile;
        final stats = [
          _ProfileStat(label: 'Workouts', value: profile.workoutCount?.toString() ?? '0'),
          _ProfileStat(label: 'Volume', value: profile.totalVolumeKg != null 
              ? '${(profile.totalVolumeKg! / 1000).toStringAsFixed(1)}k kg' 
              : '0 kg'),
          _ProfileStat(label: 'Streak', value: '${profile.streakDays ?? 0} days'),
        ];

        return Padding(
          padding: EdgeInsets.fromLTRB(
            padding,
            DesignTokens.spacingL,
            padding,
            DesignTokens.spacingS,
          ),
          child: Container(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(DesignTokens.radiusXL),
              border: Border.all(color: HevyColors.borderGlass, width: 0.8),
              color: HevyColors.glassCard,
              boxShadow: HevyColors.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: isSmallScreen ? 60 : 72,
                      height: isSmallScreen ? 60 : 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: HevyColors.primary.withValues(alpha: 0.5),
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        backgroundColor: HevyColors.surfaceElevated,
                        backgroundImage: profile.avatarUrl != null ? NetworkImage(profile.avatarUrl!) : null,
                        child: profile.avatarUrl == null ? Text(
                          (profile.displayName ?? 'U').substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            fontSize: DesignTokens.headlineMedium,
                            color: HevyColors.primary,
                          ),
                        ) : null,
                      ),
                    ),
                    SizedBox(width: isSmallScreen ? 12 : DesignTokens.spacingM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            profile.displayName ?? 'Athlete',
                            style: TextStyle(
                              fontSize: isSmallScreen
                                  ? DesignTokens.titleLarge
                                  : DesignTokens.headlineSmall,
                              fontWeight: FontWeight.w500,
                              color: HevyColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: DesignTokens.spacingXXS),
                          Row(
                            children: [
                              Icon(
                                Icons.flash_on,
                                color: HevyColors.accentOrange,
                                size: isSmallScreen ? 14 : 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${profile.streakDays ?? 0} day streak',
                                style: TextStyle(
                                  fontSize: isSmallScreen
                                      ? DesignTokens.bodySmall
                                      : DesignTokens.bodyMedium,
                                  color: HevyColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => context.push('/profile'),
                      icon: const Icon(Icons.chevron_right),
                      color: HevyColors.textSecondary,
                    ),
                  ],
                ),
                SizedBox(height: isSmallScreen ? 12 : DesignTokens.spacingM),
                Divider(color: HevyColors.borderGlass, height: 1),
                SizedBox(height: isSmallScreen ? 12 : DesignTokens.spacingM),
                Row(
                  children: stats
                      .map(
                        (stat) => Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                stat.value,
                                style: const TextStyle(
                                  fontSize: DesignTokens.titleLarge,
                                  fontWeight: FontWeight.w500,
                                  color: HevyColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                stat.label,
                                style: const TextStyle(
                                  fontSize: DesignTokens.labelMedium,
                                  color: HevyColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProfileHeroLoading extends StatelessWidget {
  const _ProfileHeroLoading();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 180,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ProfileStat {
  final String label;
  final String value;

  const _ProfileStat({required this.label, required this.value});
}

/// Suggested athletes section - Pixel perfect
class _SuggestedAthletesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isSmallScreen = screenWidth < 360;
    final isVerySmallScreen = screenWidth < 320;
    final padding = isVerySmallScreen
        ? 8.0
        : (isSmallScreen ? 12.0 : DesignTokens.paddingScreen);

    final suggestedAthletes = _generateMockSuggestedAthletes();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            padding,
            DesignTokens.spacingL,
            padding,
            DesignTokens.spacingM,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  'Suggested Athletes',
                  style: TextStyle(
                    color: HevyColors.textPrimary,
                    fontSize: isSmallScreen
                        ? DesignTokens.titleMedium
                        : DesignTokens.headlineSmall,
                    fontWeight: FontWeight.w600,
                    letterSpacing: DesignTokens.letterSpacingTight,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              TextButton(
                onPressed: () => context.push('/invite-friends'),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 6 : 8,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add,
                      size: isSmallScreen ? 12 : 14,
                      color: HevyColors.primary,
                    ),
                    SizedBox(width: isSmallScreen ? 2 : 4),
                    Text(
                      'Invite a friend',
                      style: TextStyle(
                        color: HevyColors.primary,
                        fontSize: isSmallScreen
                            ? DesignTokens.bodyMedium
                            : DesignTokens.bodyLarge,
                        fontWeight: FontWeight.w400,
                        letterSpacing: DesignTokens.letterSpacingNormal,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: isVerySmallScreen ? 180.0 : (isSmallScreen ? 200.0 : 220.0),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: padding),
            itemCount: suggestedAthletes.length,
            itemBuilder: (context, index) {
              return _SuggestedAthleteCard(
                athlete: suggestedAthletes[index],
                isSmallScreen: isSmallScreen,
                isVerySmallScreen: isVerySmallScreen,
              );
            },
          ),
        ),
        SizedBox(height: padding),
      ],
    );
  }
}

/// Suggested athlete card - Compact, overflow-safe design
class _SuggestedAthleteCard extends StatefulWidget {
  final SuggestedAthlete athlete;
  final bool isSmallScreen;
  final bool isVerySmallScreen;

  const _SuggestedAthleteCard({
    required this.athlete,
    this.isSmallScreen = false,
    this.isVerySmallScreen = false,
  });

  @override
  State<_SuggestedAthleteCard> createState() => _SuggestedAthleteCardState();
}

class _SuggestedAthleteCardState extends State<_SuggestedAthleteCard> {
  bool _isFollowing = false;

  @override
  Widget build(BuildContext context) {
    // Card dimensions matching screenshot
    final cardWidth = widget.isVerySmallScreen
        ? 120.0
        : (widget.isSmallScreen ? 140.0 : 160.0);
    final cardHeight = widget.isVerySmallScreen
        ? 180.0
        : (widget.isSmallScreen ? 200.0 : 220.0);
    final avatarSize =
        widget.isVerySmallScreen ? 70.0 : (widget.isSmallScreen ? 80.0 : 90.0);
    final padding =
        widget.isVerySmallScreen ? 12.0 : (widget.isSmallScreen ? 14.0 : 16.0);
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final avatarCacheSize = (avatarSize * devicePixelRatio).round();

    return Container(
      width: cardWidth,
      height: cardHeight,
      margin: EdgeInsets.only(
        right: widget.isVerySmallScreen ? 10 : (widget.isSmallScreen ? 12 : 14),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DesignTokens.radiusL),
        border: Border.all(
          color: HevyColors.border,
          width: 0.5,
        ),
        color: HevyColors.surfaceElevated,
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // Main content - Column with proper constraints
          Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Avatar - circular, fixed size
                SizedBox(
                  width: avatarSize,
                  height: avatarSize,
                  child: ClipOval(
                    child: widget.athlete.user.avatarUrl != null
                        ? CachedNetworkImage(
                            imageUrl: widget.athlete.user.avatarUrl!,
                            fit: BoxFit.cover,
                            memCacheWidth: avatarCacheSize,
                            memCacheHeight: avatarCacheSize,
                            filterQuality: FilterQuality.low,
                            placeholder: (_, __) =>
                                _buildPlaceholderAvatar(avatarSize),
                            errorWidget: (_, __, ___) =>
                                _buildPlaceholderAvatar(avatarSize),
                          )
                        : _buildPlaceholderAvatar(avatarSize),
                  ),
                ),
                SizedBox(height: widget.isSmallScreen ? 10 : 12),
                // Username - constrained width
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    widget.athlete.user.name,
                    style: TextStyle(
                      fontSize: widget.isSmallScreen ? 13 : 14,
                      fontWeight: FontWeight.w500,
                      color: HevyColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 4),
                // Status (Featured/Mutual) - constrained width
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    widget.athlete.reason ?? 'Featured',
                    style: TextStyle(
                      fontSize: widget.isSmallScreen ? 11 : 12,
                      fontWeight: FontWeight.w400,
                      color: HevyColors.textSecondary,
                      letterSpacing: 0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
                const Spacer(),
                // Follow button - full width, rounded square
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _handleFollow(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isFollowing
                          ? HevyColors.glassCard
                          : HevyColors.primary,
                      foregroundColor: _isFollowing
                          ? HevyColors.textPrimary
                          : const Color(0xFFFFFFFF),
                      padding: EdgeInsets.symmetric(
                        vertical: widget.isSmallScreen ? 10 : 12,
                        horizontal: 8,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(DesignTokens.radiusS),
                        side: _isFollowing
                            ? BorderSide(color: HevyColors.border, width: 0.5)
                            : BorderSide.none,
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      _isFollowing ? 'Following' : 'Follow',
                      style: TextStyle(
                        fontSize: widget.isSmallScreen ? 13 : 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // X dismiss button - top right corner
          Positioned(
            top: 8,
            right: 8,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _handleDismiss(context),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.close,
                    size: 16,
                    color: HevyColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderAvatar(double size) {
    return Container(
      color: HevyColors.surface,
      child: Center(
        child: CircleAvatar(
          radius: size / 2,
          backgroundColor: HevyColors.primary.withValues(alpha: 0.15),
          child: Text(
            widget.athlete.user.name.isNotEmpty
                ? widget.athlete.user.name[0].toUpperCase()
                : 'A',
            style: TextStyle(
              color: HevyColors.primary,
              fontSize: size * 0.4,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  void _handleFollow(BuildContext context) {
    setState(() {
      _isFollowing = !_isFollowing;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFollowing
            ? 'Following ${widget.athlete.user.name}'
            : 'Unfollowed ${widget.athlete.user.name}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleDismiss(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Suggestion dismissed'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

/// Workout post card - Pixel perfect, no overflow
class _WorkoutPostCard extends ConsumerStatefulWidget {
  final WorkoutPost post;

  const _WorkoutPostCard({required this.post});

  @override
  ConsumerState<_WorkoutPostCard> createState() => _WorkoutPostCardState();
}

class _WorkoutPostCardState extends ConsumerState<_WorkoutPostCard> {
  bool _isLiked = false;
  int _likesCount = 0;
  bool _isTogglingLike = false;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.isLiked;
    _likesCount = widget.post.likesCount;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isSmallScreen = screenWidth < 360;
    final isVerySmallScreen = screenWidth < 320;
    final padding = isVerySmallScreen
        ? 8.0
        : (isSmallScreen ? 12.0 : DesignTokens.paddingScreen);
    final devicePixelRatio = mediaQuery.devicePixelRatio;
    final postImageCacheSize = (screenWidth * devicePixelRatio).round();

    return Container(
      margin: EdgeInsets.fromLTRB(
        padding,
        isSmallScreen ? 12 : 16,
        padding,
        isSmallScreen ? 12 : 16,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DesignTokens.radiusL),
        border: Border.all(
          color: HevyColors.glassBorder,
          width: 0.5,
        ),
        boxShadow: HevyColors.cardShadow,
      ),
      child: RepaintBoundary(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(DesignTokens.radiusL),
          child: BackdropFilter(
            filter: _glassBlurFilter,
            child: Container(
              decoration: BoxDecoration(
                color: HevyColors.glassSurface,
                borderRadius: BorderRadius.circular(DesignTokens.radiusL),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Post header
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      padding,
                      DesignTokens.spacingM,
                      padding,
                      DesignTokens.spacingM,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: isSmallScreen ? 18 : 20,
                          backgroundColor:
                              HevyColors.primary.withValues(alpha: 0.2),
                          backgroundImage: widget.post.author.avatarUrl != null
                              ? NetworkImage(widget.post.author.avatarUrl!)
                              : null,
                          child: widget.post.author.avatarUrl == null
                              ? Text(
                                  widget.post.author.name.isNotEmpty
                                      ? widget.post.author.name[0].toUpperCase()
                                      : 'A',
                                  style: TextStyle(
                                    color: HevyColors.primary,
                                    fontSize: isSmallScreen ? 14 : 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                )
                              : null,
                        ),
                        SizedBox(width: isSmallScreen ? 10 : 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.post.author.name,
                                style: TextStyle(
                                  color: HevyColors.textPrimary,
                                  fontSize: isSmallScreen
                                      ? DesignTokens.bodyMedium
                                      : DesignTokens.bodyLarge,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing:
                                      DesignTokens.letterSpacingNormal,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              const SizedBox(height: DesignTokens.spacingXXS),
                              Text(
                                _getTimeAgo(widget.post.createdAt),
                                style: TextStyle(
                                  color: HevyColors.textSecondary,
                                  fontSize: isSmallScreen
                                      ? DesignTokens.bodySmall
                                      : DesignTokens.bodyMedium,
                                  fontWeight: FontWeight.w300,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                        // Three dots menu button
                        IconButton(
                          icon: Icon(
                            Icons.more_vert,
                            color: HevyColors.textSecondary,
                            size: isSmallScreen ? 18 : 20,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          onPressed: () => _showPostMenu(context),
                        ),
                      ],
                    ),
                  ),

                  // Post image (if available)
                  if (widget.post.imageUrl != null)
                    Padding(
                      padding:
                          const EdgeInsets.only(bottom: DesignTokens.spacingM),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(DesignTokens.radiusL),
                          bottomRight: Radius.circular(DesignTokens.radiusL),
                        ),
                        child: AspectRatio(
                          aspectRatio: 1.0,
                          child: CachedNetworkImage(
                            imageUrl: widget.post.imageUrl!,
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.low,
                            memCacheWidth: postImageCacheSize,
                            memCacheHeight: postImageCacheSize,
                            placeholder: (_, __) => Container(
                              color: HevyColors.surface,
                              child: const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: HevyColors.primary,
                                  ),
                                ),
                              ),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: HevyColors.surface,
                              child: const Icon(
                                Icons.broken_image,
                                color: HevyColors.textSecondary,
                                size: 48,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Workout title
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: padding),
                    child: Text(
                      widget.post.workout.name ?? 'Workout',
                      style: TextStyle(
                        color: HevyColors.textPrimary,
                        fontSize: isSmallScreen
                            ? DesignTokens.titleMedium
                            : DesignTokens.titleLarge,
                        fontWeight: FontWeight.w600,
                        letterSpacing: DesignTokens.letterSpacingTight,
                        height: DesignTokens.lineHeightTight,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Workout metrics
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      padding,
                      DesignTokens.spacingM,
                      padding,
                      DesignTokens.spacingM,
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth < 280) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _WorkoutMetric(
                                      label: 'Time',
                                      value: _formatDuration(
                                          widget.post.workout.durationSeconds ??
                                              0),
                                      icon: Icons.access_time,
                                      isSmallScreen: isSmallScreen,
                                    ),
                                  ),
                                  Expanded(
                                    child: _WorkoutMetric(
                                      label: 'Volume',
                                      value:
                                          '${(widget.post.workout.totalVolumeKg ?? 0).toStringAsFixed(0)} kg',
                                      icon: Icons.fitness_center,
                                      isSmallScreen: isSmallScreen,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _WorkoutMetric(
                                label: 'Records',
                                value: '3',
                                icon: Icons.emoji_events,
                                iconColor: HevyColors.accentOrange,
                                isSmallScreen: isSmallScreen,
                              ),
                            ],
                          );
                        }
                        return Row(
                          children: [
                            Expanded(
                              child: _WorkoutMetric(
                                label: 'Time',
                                value: _formatDuration(
                                    widget.post.workout.durationSeconds ?? 0),
                                icon: Icons.access_time,
                                isSmallScreen: isSmallScreen,
                              ),
                            ),
                            Expanded(
                              child: _WorkoutMetric(
                                label: 'Volume',
                                value:
                                    '${(widget.post.workout.totalVolumeKg ?? 0).toStringAsFixed(0)} kg',
                                icon: Icons.fitness_center,
                                isSmallScreen: isSmallScreen,
                              ),
                            ),
                            Expanded(
                              child: _WorkoutMetric(
                                label: 'Records',
                                value: '3',
                                icon: Icons.emoji_events,
                                iconColor: HevyColors.accentOrange,
                                isSmallScreen: isSmallScreen,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  // Exercise list
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: padding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ExerciseItem(
                          name: '4 sets Triceps Rope Pushdown',
                          isSmallScreen: isSmallScreen,
                        ),
                        SizedBox(
                            height: isSmallScreen
                                ? DesignTokens.spacingS
                                : DesignTokens.spacingM),
                        _ExerciseItem(
                          name: '4 sets Reverse Bar Grip Triceps',
                          isSmallScreen: isSmallScreen,
                        ),
                        SizedBox(
                            height: isSmallScreen
                                ? DesignTokens.spacingS
                                : DesignTokens.spacingM),
                        _ExerciseItem(
                          name: '3 sets Overhead Triceps Extension (Cable)',
                          isSmallScreen: isSmallScreen,
                        ),
                        const SizedBox(height: DesignTokens.spacingXXS),
                        TextButton(
                          onPressed: () => _handleShowAllExercises(context),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 32),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'See 2 more exercises',
                            style: TextStyle(
                              color: HevyColors.textPrimary,
                              fontSize: isSmallScreen
                                  ? DesignTokens.bodyMedium
                                  : DesignTokens.bodyLarge,
                              fontWeight: FontWeight.w400,
                              letterSpacing: DesignTokens.letterSpacingNormal,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Divider
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: padding,
                      vertical: DesignTokens.spacingM,
                    ),
                    child: Divider(
                      color: HevyColors.dividerGlass,
                      height: 1,
                      thickness: 0.5,
                    ),
                  ),

                  // Interaction buttons
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      padding,
                      DesignTokens.spacingM,
                      padding,
                      DesignTokens.spacingM,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _InteractionButton(
                            icon: _isLiked
                                ? Icons.thumb_up
                                : Icons.thumb_up_outlined,
                            label: _likesCount.toString(),
                            isActive: _isLiked,
                            onTap: () => _handleLike(),
                            isSmallScreen: isSmallScreen,
                          ),
                        ),
                        SizedBox(
                            width: isSmallScreen
                                ? DesignTokens.spacingM
                                : DesignTokens.spacingL),
                        Expanded(
                          child: _InteractionButton(
                            icon: Icons.comment_outlined,
                            label: widget.post.commentsCount.toString(),
                            onTap: () => _handleComment(context),
                            isSmallScreen: isSmallScreen,
                          ),
                        ),
                        SizedBox(
                            width: isSmallScreen
                                ? DesignTokens.spacingM
                                : DesignTokens.spacingL),
                        Expanded(
                          child: _InteractionButton(
                            icon: Icons.share_outlined,
                            label: 'Share',
                            onTap: () => _handleShare(context),
                            isSmallScreen: isSmallScreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLike() async {
    if (_isTogglingLike) return;
    setState(() {
      _isTogglingLike = true;
    });
    try {
      final result =
          await ref.read(feedRepositoryProvider).toggleLike(widget.post.id);
      if (!mounted) return;
      setState(() {
        _isLiked = result.isLiked;
        _likesCount = result.likesCount;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to update like. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isTogglingLike = false;
        });
      }
    }
  }

  void _handleComment(BuildContext context) {
    _showCommentsBottomSheet(context, widget.post);
  }

  void _handleShare(BuildContext context) {
    final shareService = ShareService();
    shareService.shareWorkoutPost(
      workoutName: widget.post.workout.name ?? 'Workout',
      authorName: widget.post.author.name,
      workoutUrl: 'https://zenx.app/workout/${widget.post.workoutId}',
    );
  }

  void _showCommentsBottomSheet(BuildContext context, WorkoutPost post) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _CommentsBottomSheet(post: post),
    );
  }

  void _showPostMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => RepaintBoundary(
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(DesignTokens.radiusXL),
            topRight: Radius.circular(DesignTokens.radiusXL),
          ),
          child: BackdropFilter(
            filter: _glassBlurFilter,
            child: Container(
              decoration: BoxDecoration(
                color: HevyColors.glassSurface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(DesignTokens.radiusXL),
                  topRight: Radius.circular(DesignTokens.radiusXL),
                ),
                border: Border(
                  top: BorderSide(
                    color: HevyColors.glassBorder,
                    width: 0.5,
                  ),
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle bar
                    Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: HevyColors.textSecondary.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    // Menu items
                    _PostMenuOption(
                      icon: Icons.share_outlined,
                      label: 'Share Workout',
                      onTap: () {
                        Navigator.pop(context);
                        _handleShare(context);
                      },
                    ),
                    _PostMenuOption(
                      icon: Icons.save_outlined,
                      label: 'Save as Routine',
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Workout saved as routine'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    _PostMenuOption(
                      icon: Icons.copy_outlined,
                      label: 'Copy Workout',
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Workout copied'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    _PostMenuOption(
                      icon: Icons.edit_outlined,
                      label: 'Edit Workout',
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/workouts/${widget.post.workoutId}/edit');
                      },
                    ),
                    _PostMenuOption(
                      icon: Icons.delete_outline,
                      label: 'Delete Workout',
                      isDestructive: true,
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Workout deleted'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleShowAllExercises(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('All Exercises'),
        content: const Text('Exercise list feature coming soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    }
    return '${minutes}min';
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return 'Yesterday';
      }
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

/// Discover post card - Pixel perfect, no overflow
class _DiscoverPostCard extends ConsumerStatefulWidget {
  final WorkoutPost post;

  const _DiscoverPostCard({required this.post});

  @override
  ConsumerState<_DiscoverPostCard> createState() => _DiscoverPostCardState();
}

class _DiscoverPostCardState extends ConsumerState<_DiscoverPostCard> {
  bool _isLiked = false;
  int _likesCount = 0;
  bool _isFollowing = false;
  bool _isTogglingLike = false;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.isLiked;
    _likesCount = widget.post.likesCount;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isSmallScreen = screenWidth < 360;
    final isVerySmallScreen = screenWidth < 320;
    final padding = isVerySmallScreen
        ? 8.0
        : (isSmallScreen ? 12.0 : DesignTokens.paddingScreen);
    final devicePixelRatio = mediaQuery.devicePixelRatio;
    final postImageCacheSize = (screenWidth * devicePixelRatio).round();

    return Container(
      margin: EdgeInsets.fromLTRB(
        padding,
        isSmallScreen ? 12 : 16,
        padding,
        isSmallScreen ? 12 : 16,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DesignTokens.radiusL),
        border: Border.all(
          color: HevyColors.glassBorder,
          width: 0.5,
        ),
        boxShadow: HevyColors.cardShadow,
      ),
      child: RepaintBoundary(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(DesignTokens.radiusL),
          child: BackdropFilter(
            filter: _glassBlurFilter,
            child: Container(
              decoration: BoxDecoration(
                color: HevyColors.glassSurface,
                borderRadius: BorderRadius.circular(DesignTokens.radiusL),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Post header with Follow button
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      padding,
                      DesignTokens.spacingM,
                      padding,
                      DesignTokens.spacingM,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: isSmallScreen ? 18 : 20,
                          backgroundColor:
                              HevyColors.primary.withValues(alpha: 0.2),
                          backgroundImage: widget.post.author.avatarUrl != null
                              ? NetworkImage(widget.post.author.avatarUrl!)
                              : null,
                          child: widget.post.author.avatarUrl == null
                              ? Text(
                                  widget.post.author.name.isNotEmpty
                                      ? widget.post.author.name[0].toUpperCase()
                                      : 'A',
                                  style: TextStyle(
                                    color: HevyColors.primary,
                                    fontSize: isSmallScreen ? 14 : 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                )
                              : null,
                        ),
                        SizedBox(width: isSmallScreen ? 10 : 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.post.author.name,
                                style: TextStyle(
                                  color: HevyColors.textPrimary,
                                  fontSize: isSmallScreen
                                      ? DesignTokens.bodyMedium
                                      : DesignTokens.bodyLarge,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing:
                                      DesignTokens.letterSpacingNormal,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              const SizedBox(height: DesignTokens.spacingXXS),
                              Text(
                                _getTimeAgo(widget.post.createdAt),
                                style: TextStyle(
                                  color: HevyColors.textSecondary,
                                  fontSize: isSmallScreen
                                      ? DesignTokens.bodySmall
                                      : DesignTokens.bodyMedium,
                                  fontWeight: FontWeight.w300,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                        // Follow button and three dots menu - right aligned
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _isFollowing
                                ? TextButton(
                                    onPressed: () => _handleFollow(context),
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isSmallScreen ? 12 : 16,
                                        vertical: isSmallScreen ? 6 : 8,
                                      ),
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      backgroundColor: HevyColors.glassCard,
                                      foregroundColor: HevyColors.textPrimary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            DesignTokens.radiusM),
                                      ),
                                    ),
                                    child: Text(
                                      'Following',
                                      style: TextStyle(
                                        fontSize: isSmallScreen
                                            ? DesignTokens.bodyMedium
                                            : DesignTokens.bodyLarge,
                                        fontWeight: FontWeight.w400,
                                        letterSpacing:
                                            DesignTokens.letterSpacingNormal,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )
                                : Container(
                                    decoration: BoxDecoration(
                                      gradient: HevyColors.primaryGradient,
                                      borderRadius: BorderRadius.circular(
                                          DesignTokens.radiusM),
                                      boxShadow: HevyColors.buttonShadow,
                                    ),
                                    child: TextButton(
                                      onPressed: () => _handleFollow(context),
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: isSmallScreen ? 12 : 16,
                                          vertical: isSmallScreen ? 6 : 8,
                                        ),
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              DesignTokens.radiusM),
                                        ),
                                      ),
                                      child: Text(
                                        'Follow',
                                        style: TextStyle(
                                          fontSize: isSmallScreen
                                              ? DesignTokens.bodyMedium
                                              : DesignTokens.bodyLarge,
                                          fontWeight: FontWeight.w400,
                                          letterSpacing:
                                              DesignTokens.letterSpacingNormal,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                            SizedBox(width: isSmallScreen ? 4 : 8),
                            // Three dots menu button
                            IconButton(
                              icon: Icon(
                                Icons.more_vert,
                                color: HevyColors.textSecondary,
                                size: isSmallScreen ? 18 : 20,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              onPressed: () => _showDiscoverPostMenu(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Post image (if available)
                  if (widget.post.imageUrl != null)
                    Padding(
                      padding:
                          const EdgeInsets.only(bottom: DesignTokens.spacingM),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(DesignTokens.radiusL),
                          bottomRight: Radius.circular(DesignTokens.radiusL),
                        ),
                        child: AspectRatio(
                          aspectRatio: 1.0,
                          child: CachedNetworkImage(
                            imageUrl: widget.post.imageUrl!,
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.low,
                            memCacheWidth: postImageCacheSize,
                            memCacheHeight: postImageCacheSize,
                            placeholder: (_, __) => Container(
                              color: HevyColors.surface,
                              child: const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: HevyColors.primary,
                                  ),
                                ),
                              ),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: HevyColors.surface,
                              child: const Icon(
                                Icons.broken_image,
                                color: HevyColors.textSecondary,
                                size: 48,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Workout title
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: padding),
                    child: Text(
                      widget.post.workout.name ?? 'Workout',
                      style: TextStyle(
                        color: HevyColors.textPrimary,
                        fontSize: isSmallScreen
                            ? DesignTokens.titleMedium
                            : DesignTokens.titleLarge,
                        fontWeight: FontWeight.w600,
                        letterSpacing: DesignTokens.letterSpacingTight,
                        height: DesignTokens.lineHeightTight,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Workout metrics
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      padding,
                      DesignTokens.spacingM,
                      padding,
                      DesignTokens.spacingM,
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth < 280) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _WorkoutMetric(
                                      label: 'Time',
                                      value: _formatDuration(
                                          widget.post.workout.durationSeconds ??
                                              0),
                                      icon: Icons.access_time,
                                      isSmallScreen: isSmallScreen,
                                    ),
                                  ),
                                  Expanded(
                                    child: _WorkoutMetric(
                                      label: 'Volume',
                                      value:
                                          '${(widget.post.workout.totalVolumeKg ?? 0).toStringAsFixed(0)} kg',
                                      icon: Icons.fitness_center,
                                      isSmallScreen: isSmallScreen,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _WorkoutMetric(
                                label: 'Records',
                                value: '3',
                                icon: Icons.emoji_events,
                                iconColor: HevyColors.accentOrange,
                                isSmallScreen: isSmallScreen,
                              ),
                            ],
                          );
                        }
                        return Row(
                          children: [
                            Expanded(
                              child: _WorkoutMetric(
                                label: 'Time',
                                value: _formatDuration(
                                    widget.post.workout.durationSeconds ?? 0),
                                icon: Icons.access_time,
                                isSmallScreen: isSmallScreen,
                              ),
                            ),
                            Expanded(
                              child: _WorkoutMetric(
                                label: 'Volume',
                                value:
                                    '${(widget.post.workout.totalVolumeKg ?? 0).toStringAsFixed(0)} kg',
                                icon: Icons.fitness_center,
                                isSmallScreen: isSmallScreen,
                              ),
                            ),
                            Expanded(
                              child: _WorkoutMetric(
                                label: 'Records',
                                value: '3',
                                icon: Icons.emoji_events,
                                iconColor: HevyColors.accentOrange,
                                isSmallScreen: isSmallScreen,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  // Exercise list
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: padding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ExerciseItem(
                          name: '4 sets Triceps Rope Pushdown',
                          isSmallScreen: isSmallScreen,
                        ),
                        SizedBox(
                            height: isSmallScreen
                                ? DesignTokens.spacingS
                                : DesignTokens.spacingM),
                        _ExerciseItem(
                          name: '4 sets Reverse Bar Grip Triceps',
                          isSmallScreen: isSmallScreen,
                        ),
                        SizedBox(
                            height: isSmallScreen
                                ? DesignTokens.spacingS
                                : DesignTokens.spacingM),
                        _ExerciseItem(
                          name: '3 sets Overhead Triceps Extension (Cable)',
                          isSmallScreen: isSmallScreen,
                        ),
                        const SizedBox(height: DesignTokens.spacingXXS),
                        TextButton(
                          onPressed: () => _handleShowAllExercises(context),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 32),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'See 2 more exercises',
                            style: TextStyle(
                              color: HevyColors.textPrimary,
                              fontSize: isSmallScreen
                                  ? DesignTokens.bodyMedium
                                  : DesignTokens.bodyLarge,
                              fontWeight: FontWeight.w400,
                              letterSpacing: DesignTokens.letterSpacingNormal,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Divider
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: padding,
                      vertical: DesignTokens.spacingM,
                    ),
                    child: Divider(
                      color: HevyColors.dividerGlass,
                      height: 1,
                      thickness: 0.5,
                    ),
                  ),

                  // Interaction buttons
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      padding,
                      DesignTokens.spacingM,
                      padding,
                      DesignTokens.spacingM,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _InteractionButton(
                            icon: _isLiked
                                ? Icons.thumb_up
                                : Icons.thumb_up_outlined,
                            label: _likesCount.toString(),
                            isActive: _isLiked,
                            onTap: () => _handleLike(),
                            isSmallScreen: isSmallScreen,
                          ),
                        ),
                        SizedBox(
                            width: isSmallScreen
                                ? DesignTokens.spacingM
                                : DesignTokens.spacingL),
                        Expanded(
                          child: _InteractionButton(
                            icon: Icons.comment_outlined,
                            label: widget.post.commentsCount.toString(),
                            onTap: () => _handleComment(context),
                            isSmallScreen: isSmallScreen,
                          ),
                        ),
                        SizedBox(
                            width: isSmallScreen
                                ? DesignTokens.spacingM
                                : DesignTokens.spacingL),
                        Expanded(
                          child: _InteractionButton(
                            icon: Icons.share_outlined,
                            label: 'Share',
                            onTap: () => _handleShare(context),
                            isSmallScreen: isSmallScreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleFollow(BuildContext context) {
    setState(() {
      _isFollowing = !_isFollowing;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFollowing
            ? 'Following ${widget.post.author.name}'
            : 'Unfollowed ${widget.post.author.name}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleLike() async {
    if (_isTogglingLike) return;
    setState(() {
      _isTogglingLike = true;
    });
    try {
      final result =
          await ref.read(feedRepositoryProvider).toggleLike(widget.post.id);
      if (!mounted) return;
      setState(() {
        _isLiked = result.isLiked;
        _likesCount = result.likesCount;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to update like. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isTogglingLike = false;
        });
      }
    }
  }

  void _handleComment(BuildContext context) {
    _showCommentsBottomSheet(context, widget.post);
  }

  void _handleShare(BuildContext context) {
    final shareService = ShareService();
    shareService.shareWorkoutPost(
      workoutName: widget.post.workout.name ?? 'Workout',
      authorName: widget.post.author.name,
      workoutUrl: 'https://zenx.app/workout/${widget.post.workoutId}',
    );
  }

  void _showCommentsBottomSheet(BuildContext context, WorkoutPost post) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _CommentsBottomSheet(post: post),
    );
  }

  void _showDiscoverPostMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => RepaintBoundary(
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(DesignTokens.radiusXL),
            topRight: Radius.circular(DesignTokens.radiusXL),
          ),
          child: BackdropFilter(
            filter: _glassBlurFilter,
            child: Container(
              decoration: BoxDecoration(
                color: HevyColors.glassSurface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(DesignTokens.radiusXL),
                  topRight: Radius.circular(DesignTokens.radiusXL),
                ),
                border: Border(
                  top: BorderSide(
                    color: HevyColors.glassBorder,
                    width: 0.5,
                  ),
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle bar
                    Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: HevyColors.textSecondary.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    // Menu items - appropriate for discovered posts
                    _PostMenuOption(
                      icon: Icons.share_outlined,
                      label: 'Share Workout',
                      onTap: () {
                        Navigator.pop(context);
                        _handleShare(context);
                      },
                    ),
                    _PostMenuOption(
                      icon: Icons.save_outlined,
                      label: 'Save as Routine',
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Workout saved as routine'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    _PostMenuOption(
                      icon: Icons.copy_outlined,
                      label: 'Copy Workout',
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Workout copied'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    _PostMenuOption(
                      icon: Icons.visibility_off_outlined,
                      label: 'Hide Post',
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Post from ${widget.post.author.name} hidden'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    _PostMenuOption(
                      icon: Icons.block_outlined,
                      label: 'Block ${widget.post.author.name}',
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                '${widget.post.author.name} has been blocked'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    _PostMenuOption(
                      icon: Icons.flag_outlined,
                      label: 'Report Post',
                      isDestructive: true,
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Post reported'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleShowAllExercises(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('All Exercises'),
        content: const Text('Exercise list feature coming soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    }
    return '${minutes}min';
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return 'Yesterday';
      }
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

/// Post menu option widget for bottom sheet
class _PostMenuOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _PostMenuOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: DesignTokens.spacingL,
          vertical: isSmallScreen ? 16 : 18,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: isSmallScreen ? 20 : 22,
              color: isDestructive ? HevyColors.error : HevyColors.textPrimary,
            ),
            SizedBox(width: isSmallScreen ? 16 : DesignTokens.spacingL),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color:
                      isDestructive ? HevyColors.error : HevyColors.textPrimary,
                  fontSize: isSmallScreen
                      ? DesignTokens.bodyMedium
                      : DesignTokens.bodyLarge,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final bool isSmallScreen;

  const _WorkoutMetric({
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor,
    this.isSmallScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: isSmallScreen ? 12 : 14,
              color: iconColor ?? HevyColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: HevyColors.textSecondary,
                  fontSize: isSmallScreen
                      ? DesignTokens.bodySmall
                      : DesignTokens.bodyMedium,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
        SizedBox(height: isSmallScreen ? 6 : 8),
        Text(
          value,
          style: TextStyle(
            color: HevyColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: isSmallScreen
                ? DesignTokens.bodyLarge
                : DesignTokens.titleMedium,
            letterSpacing: DesignTokens.letterSpacingTight,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }
}

class _ExerciseItem extends StatelessWidget {
  final String name;
  final bool isSmallScreen;

  const _ExerciseItem({
    required this.name,
    this.isSmallScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: isSmallScreen ? 36 : 40,
          height: isSmallScreen ? 36 : 40,
          decoration: const BoxDecoration(
            color: HevyColors.surfaceElevated,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.fitness_center,
            size: isSmallScreen ? 18 : 20,
            color: HevyColors.textSecondary,
          ),
        ),
        SizedBox(width: isSmallScreen ? 10 : 12),
        Expanded(
          child: Text(
            name,
            style: TextStyle(
              color: HevyColors.textPrimary,
              fontSize: isSmallScreen
                  ? DesignTokens.bodyMedium
                  : DesignTokens.bodyLarge,
              fontWeight: FontWeight.w500,
              height: DesignTokens.lineHeightNormal,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _InteractionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool isSmallScreen;

  const _InteractionButton({
    required this.icon,
    required this.label,
    this.isActive = false,
    required this.onTap,
    this.isSmallScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: isSmallScreen
                ? DesignTokens.iconMedium * 0.85
                : DesignTokens.iconMedium,
            color: isActive ? HevyColors.primary : HevyColors.textPrimary,
          ),
          SizedBox(width: isSmallScreen ? 4 : 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: isActive ? HevyColors.primary : HevyColors.textPrimary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                fontSize: isSmallScreen
                    ? DesignTokens.bodyMedium
                    : DesignTokens.bodyLarge,
                letterSpacing: DesignTokens.letterSpacingNormal,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}

List<SuggestedAthlete> _generateMockSuggestedAthletes() {
  return [
    SuggestedAthlete(
      id: 'suggested_1',
      user: User(
        id: 'user_s1',
        email: 'icebrakes@example.com',
        name: 'icebrakes',
        avatarUrl:
            'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=200&h=200&fit=crop',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      reason: 'Featured',
    ),
    SuggestedAthlete(
      id: 'suggested_2',
      user: User(
        id: 'user_s2',
        email: 'ashleighxlifts@example.com',
        name: 'ashleighxlifts',
        avatarUrl:
            'https://images.unsplash.com/photo-1594381898411-846e7d193883?w=200&h=200&fit=crop',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      reason: 'Featured',
    ),
    SuggestedAthlete(
      id: 'suggested_3',
      user: User(
        id: 'user_s3',
        email: 'ge@example.com',
        name: 'ge',
        avatarUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      reason: 'Mutual',
      mutualFollowersCount: 5,
    ),
  ];
}

/// Comments bottom sheet widget
class _CommentsBottomSheet extends ConsumerStatefulWidget {
  final WorkoutPost post;

  const _CommentsBottomSheet({
    required this.post,
  });

  @override
  ConsumerState<_CommentsBottomSheet> createState() =>
      _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends ConsumerState<_CommentsBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  final List<PostComment> _comments = [];
  bool _isLoadingComments = true;
  bool _isSendingComment = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    setState(() {
      _isLoadingComments = true;
    });
    try {
      final comments =
          await ref.read(feedRepositoryProvider).fetchComments(widget.post.id);
      if (!mounted) return;
      setState(() {
        _comments
          ..clear()
          ..addAll(comments);
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to load comments. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingComments = false;
        });
      }
    }
  }

  Future<void> _addComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || _isSendingComment) return;

    setState(() {
      _isSendingComment = true;
    });

    try {
      final newComment = await ref
          .read(feedRepositoryProvider)
          .addComment(postId: widget.post.id, body: text);
      if (!mounted) return;
      setState(() {
        _comments.insert(0, newComment);
      });
      _commentController.clear();
      FocusScope.of(context).unfocus();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to add comment. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSendingComment = false;
        });
      }
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(DesignTokens.radiusXL),
          topRight: Radius.circular(DesignTokens.radiusXL),
        ),
        child: BackdropFilter(
          filter: _glassBlurFilter,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: screenHeight * 0.9,
            ),
            decoration: BoxDecoration(
              color: HevyColors.glassSurface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(DesignTokens.radiusXL),
                topRight: Radius.circular(DesignTokens.radiusXL),
              ),
              border: Border(
                top: BorderSide(
                  color: HevyColors.glassBorder,
                  width: 0.5,
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: HevyColors.textSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.paddingScreen,
                    vertical: DesignTokens.spacingM,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Comments',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: HevyColors.textPrimary,
                                  ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        color: HevyColors.textSecondary,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: HevyColors.dividerGlass,
                  height: 1,
                  thickness: 0.5,
                ),
                // Comments list
                Flexible(
                  child: _isLoadingComments
                      ? const Center(child: CircularProgressIndicator())
                      : _comments.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(
                                    DesignTokens.spacingXL),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.comment_outlined,
                                      size: 48,
                                      color: HevyColors.textSecondary
                                          .withValues(alpha: 0.5),
                                    ),
                                    const SizedBox(
                                        height: DesignTokens.spacingM),
                                    Text(
                                      'No comments yet',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            color: HevyColors.textSecondary,
                                          ),
                                    ),
                                    const SizedBox(
                                        height: DesignTokens.spacingXXS),
                                    Text(
                                      'Be the first to comment!',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: HevyColors.textTertiary,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: DesignTokens.paddingScreen,
                                vertical: DesignTokens.spacingM,
                              ),
                              itemCount: _comments.length,
                              itemBuilder: (context, index) {
                                final comment = _comments[index];
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: DesignTokens.spacingL),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundColor:
                                            HevyColors.surfaceElevated,
                                        backgroundImage:
                                            comment.author.avatarUrl != null
                                                ? CachedNetworkImageProvider(
                                                    comment.author.avatarUrl!)
                                                : null,
                                        child: comment.author.avatarUrl == null
                                            ? Text(
                                                comment.author.name[0]
                                                    .toUpperCase(),
                                                style: const TextStyle(
                                                  fontSize:
                                                      DesignTokens.bodySmall,
                                                  color:
                                                      HevyColors.textSecondary,
                                                ),
                                              )
                                            : null,
                                      ),
                                      const SizedBox(
                                          width: DesignTokens.spacingM),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(
                                                  DesignTokens.spacingM),
                                              decoration: BoxDecoration(
                                                color:
                                                    HevyColors.surfaceElevated,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        DesignTokens.radiusM),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    comment.author.name,
                                                    style: const TextStyle(
                                                      fontSize: DesignTokens
                                                          .bodyMedium,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: HevyColors
                                                          .textPrimary,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                      height: DesignTokens
                                                          .spacingXXS),
                                                  Text(
                                                    comment.content,
                                                    style: const TextStyle(
                                                      fontSize: DesignTokens
                                                          .bodyMedium,
                                                      color: HevyColors
                                                          .textPrimary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
                                                height:
                                                    DesignTokens.spacingXXS),
                                            Text(
                                              _formatTime(comment.createdAt),
                                              style: const TextStyle(
                                                fontSize:
                                                    DesignTokens.bodySmall,
                                                color: HevyColors.textTertiary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                ),
                // Input field
                Container(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                    left: DesignTokens.paddingScreen,
                    right: DesignTokens.paddingScreen,
                    top: DesignTokens.spacingM,
                  ),
                  decoration: BoxDecoration(
                    color: HevyColors.background,
                    border: Border(
                      top: BorderSide(
                        color: HevyColors.dividerGlass,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            decoration: InputDecoration(
                              hintText: 'Add a comment...',
                              hintStyle: const TextStyle(
                                color: HevyColors.textTertiary,
                              ),
                              filled: true,
                              fillColor: HevyColors.surfaceElevated,
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(DesignTokens.radiusL),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: DesignTokens.spacingM,
                                vertical: DesignTokens.spacingM,
                              ),
                            ),
                            style: const TextStyle(
                              color: HevyColors.textPrimary,
                            ),
                            maxLines: null,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _addComment(),
                          ),
                        ),
                        const SizedBox(width: DesignTokens.spacingM),
                        IconButton(
                          icon: _isSendingComment
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.send_rounded),
                          color: HevyColors.primary,
                          onPressed: _isSendingComment ? null : _addComment,
                        ),
                      ],
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
