import 'package:flutter/material.dart';
import '../../utils/vib3_colors.dart';

class BezelTabBar extends StatefulWidget {
  final List<BezelTab> tabs;
  final double collapsedHeight;
  final double expandedHeight;

  const BezelTabBar({
    super.key,
    required this.tabs,
    this.collapsedHeight = 50,
    this.expandedHeight = 300,
  });

  @override
  State<BezelTabBar> createState() => _BezelTabBarState();
}

class _BezelTabBarState extends State<BezelTabBar> with SingleTickerProviderStateMixin {
  int _selectedTabIndex = 0;
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _heightAnimation = Tween<double>(
      begin: widget.collapsedHeight,
      end: widget.expandedHeight,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _selectTab(int index) {
    setState(() {
      _selectedTabIndex = index;
      if (!_isExpanded) {
        _isExpanded = true;
        _animationController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _heightAnimation,
      builder: (context, child) {
        return Container(
          height: _heightAnimation.value,
          decoration: BoxDecoration(
            color: VIB3Colors.darkNavy.withOpacity(0.85),
            border: Border(
              top: BorderSide(
                color: VIB3Colors.glassBorder,
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Column(
            children: [
              // Tab selector bar
              Container(
                height: widget.collapsedHeight,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    // Tab buttons
                    Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.tabs.length,
                        itemBuilder: (context, index) {
                          final tab = widget.tabs[index];
                          final isSelected = index == _selectedTabIndex;
                          return GestureDetector(
                            onTap: () => _selectTab(index),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? VIB3Colors.cyan.withOpacity(0.2)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? VIB3Colors.cyan
                                      : VIB3Colors.glassBorder,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    tab.icon,
                                    color: isSelected ? VIB3Colors.cyan : Colors.white70,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    tab.label,
                                    style: TextStyle(
                                      color: isSelected ? VIB3Colors.cyan : Colors.white70,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Expand/collapse button
                    IconButton(
                      onPressed: _toggleExpand,
                      icon: Icon(
                        _isExpanded ? Icons.expand_more : Icons.expand_less,
                        color: VIB3Colors.cyan,
                      ),
                    ),
                  ],
                ),
              ),
              // Tab content
              if (_isExpanded)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: widget.tabs[_selectedTabIndex].content,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class BezelTab {
  final String label;
  final IconData icon;
  final Widget content;

  const BezelTab({
    required this.label,
    required this.icon,
    required this.content,
  });
}
