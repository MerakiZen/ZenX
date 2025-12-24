import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design_tokens.dart';
import '../../../../core/design/hevy_colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final Set<String> _followingIds = {};

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final horizontalPadding =
        width >= DesignTokens.breakpointTablet ? 32.0 : 20.0;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: HevyColors.background,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  DesignTokens.spacingL,
                  horizontalPadding,
                  DesignTokens.spacingS,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      color: HevyColors.textPrimary,
                      onPressed: () => context.pop(),
                      tooltip: 'Back',
                    ),
                    const SizedBox(width: DesignTokens.spacingS),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(
                          color: HevyColors.textPrimary,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.1,
                        ),
                        cursorColor: HevyColors.primary,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Search on Hevy',
                          prefixIcon: const Icon(Icons.search,
                              color: HevyColors.textSecondary),
                          suffixIcon: _controller.text.isEmpty
                              ? null
                              : IconButton(
                                  icon: const Icon(Icons.close,
                                      color: HevyColors.textSecondary),
                                  onPressed: () {
                                    _controller.clear();
                                    setState(() {});
                                  },
                                ),
                          filled: true,
                          fillColor: HevyColors.surfaceElevated,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: DesignTokens.spacingM,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              DesignTokens.radiusXL,
                            ),
                            borderSide: const BorderSide(
                              color: HevyColors.border,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              DesignTokens.radiusXL,
                            ),
                            borderSide: const BorderSide(
                              color: HevyColors.border,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              DesignTokens.radiusXL,
                            ),
                            borderSide: const BorderSide(
                              color: HevyColors.primary,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: const TabBar(
                  indicatorColor: HevyColors.primary,
                  indicatorWeight: 2,
                  labelColor: HevyColors.textPrimary,
                  unselectedLabelColor: HevyColors.textSecondary,
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.1,
                  ),
                  tabs: [
                    Tab(text: 'Search'),
                    Tab(text: 'Contacts'),
                  ],
                ),
              ),
              const SizedBox(height: DesignTokens.spacingM),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildSearchResults(horizontalPadding),
                    _buildContactsPlaceholder(horizontalPadding),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(double horizontalPadding) {
    final results = _mockSearchResults;
    final filtered = _controller.text.isEmpty
        ? results
        : results
            .where((result) =>
                result.name
                    .toLowerCase()
                    .contains(_controller.text.toLowerCase()) ||
                result.username
                    .toLowerCase()
                    .contains(_controller.text.toLowerCase()))
            .toList();

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        0,
        horizontalPadding,
        DesignTokens.spacingXL,
      ),
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _InviteFriendCard(padding: horizontalPadding);
        }

        final result = filtered[index - 1];
        final isFollowing = _followingIds.contains(result.id);

        return _SearchResultTile(
          result: result,
          isFollowing: isFollowing,
          onFollowTap: () {
            setState(() {
              if (isFollowing) {
                _followingIds.remove(result.id);
              } else {
                _followingIds.add(result.id);
              }
            });
          },
        );
      },
      separatorBuilder: (_, __) => const Divider(
        height: DesignTokens.spacingXL,
        color: HevyColors.divider,
      ),
      itemCount: filtered.length + 1,
    );
  }

  Widget _buildContactsPlaceholder(double horizontalPadding) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.contacts_outlined,
              color: HevyColors.textSecondary, size: 48),
          SizedBox(height: DesignTokens.spacingM),
          Text(
            'Sync contacts coming soon',
            style: TextStyle(
              color: HevyColors.textPrimary,
              fontSize: DesignTokens.titleLarge,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: DesignTokens.spacingS),
          Text(
            'We will notify you once contact suggestions are ready.',
            style: TextStyle(
              color: HevyColors.textSecondary,
              fontSize: DesignTokens.bodyLarge,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _InviteFriendCard extends StatelessWidget {
  final double padding;

  const _InviteFriendCard({required this.padding});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: HevyColors.surfaceElevated,
            borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
            border: Border.all(color: HevyColors.border),
          ),
          child: const Icon(Icons.send_rounded,
              color: HevyColors.textPrimary, size: 20),
        ),
        const SizedBox(width: DesignTokens.spacingM),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Invite a friend',
                style: TextStyle(
                  color: HevyColors.textPrimary,
                  fontSize: DesignTokens.titleLarge,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Share Hevy with friends',
                style: TextStyle(
                  color: HevyColors.textSecondary,
                  fontSize: DesignTokens.bodyLarge,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final _SearchResult result;
  final bool isFollowing;
  final VoidCallback onFollowTap;

  const _SearchResultTile({
    required this.result,
    required this.isFollowing,
    required this.onFollowTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Avatar(imageUrl: result.avatarUrl),
        const SizedBox(width: DesignTokens.spacingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                result.name,
                style: const TextStyle(
                  color: HevyColors.textPrimary,
                  fontSize: DesignTokens.titleLarge,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                result.username,
                style: const TextStyle(
                  color: HevyColors.textSecondary,
                  fontSize: DesignTokens.bodyLarge,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: DesignTokens.spacingS),
        _FollowButton(
          isFollowing: isFollowing,
          onTap: onFollowTap,
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.close, color: HevyColors.textSecondary),
          tooltip: 'Dismiss suggestion',
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? imageUrl;

  const _Avatar({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: HevyColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl == null
          ? const CircleAvatar(
              backgroundColor: HevyColors.surfaceElevated,
              child: Icon(Icons.person, color: HevyColors.textSecondary),
            )
          : Image.network(
              imageUrl!,
              fit: BoxFit.cover,
            ),
    );
  }
}

class _FollowButton extends StatelessWidget {
  final bool isFollowing;
  final VoidCallback onTap;

  const _FollowButton({
    required this.isFollowing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isFollowing ? HevyColors.glassCard : HevyColors.primary,
        borderRadius: BorderRadius.circular(DesignTokens.radiusM),
        border: Border.all(
          color: isFollowing ? HevyColors.border : Colors.transparent,
        ),
      ),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          isFollowing ? 'Following' : 'Follow',
          style: TextStyle(
            color: isFollowing ? HevyColors.textPrimary : Colors.white,
            fontSize: DesignTokens.bodyLarge,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
          ),
        ),
      ),
    );
  }
}

class _SearchResult {
  final String id;
  final String name;
  final String username;
  final String? avatarUrl;

  const _SearchResult({
    required this.id,
    required this.name,
    required this.username,
    this.avatarUrl,
  });
}

const List<_SearchResult> _mockSearchResults = [
  _SearchResult(
    id: 'aneta',
    name: 'aneta',
    username: 'aneta',
    avatarUrl:
        'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=200&h=200&fit=crop',
  ),
  _SearchResult(
    id: 'ade',
    name: 'ade',
    username: 'Adeoluwa',
    avatarUrl:
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&h=200&fit=crop',
  ),
  _SearchResult(
    id: 'mario',
    name: 'mario',
    username: 'Mario de Isidro',
    avatarUrl:
        'https://images.unsplash.com/photo-1463453091185-61582044d556?w=200&h=200&fit=crop',
  ),
  _SearchResult(
    id: 'bharat',
    name: 'b4bharat',
    username: 'Bharat Poptwani',
    avatarUrl:
        'https://images.unsplash.com/photo-1463453091185-61582044d556?w=200&h=200&fit=crop',
  ),
  _SearchResult(
    id: 'mona',
    name: 'mona',
    username: 'Mona Flores',
    avatarUrl:
        'https://images.unsplash.com/photo-1544723795-3fb6469f5b39?w=200&h=200&fit=crop',
  ),
];

