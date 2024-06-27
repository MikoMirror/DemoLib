import 'package:flutter/material.dart';

import '../services/theme_provider.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final ValueChanged<String>? onSearch;
  final VoidCallback? onBackPressed;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.onSearch,
    this.onBackPressed,
  });

  @override
  CustomAppBarState createState() => CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class CustomAppBarState extends State<CustomAppBar> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final themeProvider = ThemeProvider.of(context);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return AppBar(
      leading: widget.onBackPressed != null
          ? IconButton(
              icon: Icon(Icons.arrow_back, color: theme.textTheme.bodyLarge?.color),
              onPressed: widget.onBackPressed,
            )
          : null,
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: isDarkMode ? Colors.grey[500]! : Colors.grey[500]!,
                  ),
                ),
                hintStyle: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6)),
                filled: true,
                fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
              ),
              style: TextStyle(color: theme.textTheme.bodyMedium?.color),
              onChanged: widget.onSearch,
            )
          : Text(widget.title, style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
      backgroundColor: isDarkMode ? Colors.grey[850] : Colors.grey[300],
      actions: [
        ...?widget.actions,
        if (widget.onSearch != null)
          _isSearching
              ? IconButton(
                  icon: Icon(Icons.clear, color: theme.textTheme.bodyLarge?.color),
                  onPressed: () {
                    setState(() {
                      _isSearching = false;
                      _searchController.clear();
                    });
                    widget.onSearch?.call('');
                  },
                )
              : IconButton(
                  icon: Icon(Icons.search, color: theme.textTheme.bodyLarge?.color),
                  onPressed: () {
                    setState(() {
                      _isSearching = true;
                    });
                  },
                ),
        IconButton(
          icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode, color: theme.textTheme.bodyLarge?.color),
          onPressed: themeProvider.toggleTheme,
        ),
      ],
    );
  }
}