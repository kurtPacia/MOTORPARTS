import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final bool useGradient;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
    this.useGradient = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: actions,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed:
                  onBackPressed ??
                  () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      // If can't pop, determine where to navigate based on current location
                      final location = GoRouterState.of(context).uri.toString();
                      if (location.startsWith('/branch')) {
                        context.go('/branch');
                      } else if (location.startsWith('/admin')) {
                        context.go('/admin');
                      } else if (location.startsWith('/driver')) {
                        context.go('/driver');
                      }
                    }
                  },
            )
          : null,
      automaticallyImplyLeading: showBackButton,
      flexibleSpace: useGradient
          ? Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
              ),
            )
          : null,
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.3),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class CustomAppBarWithSearch extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final TextEditingController? searchController;
  final Function(String)? onSearchChanged;
  final VoidCallback? onSearchTap;
  final List<Widget>? actions;

  const CustomAppBarWithSearch({
    super.key,
    required this.title,
    this.searchController,
    this.onSearchChanged,
    this.onSearchTap,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: actions,
      flexibleSpace: Container(
        decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            onTap: onSearchTap,
            decoration: InputDecoration(
              hintText: 'Search...',
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(
                Icons.search,
                color: AppTheme.textSecondary,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 60);
}
