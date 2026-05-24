import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════
// APP DESIGN SYSTEM — iOS-inspired
// ═══════════════════════════════════════════════════════════════

// ─── Colors ────────────────────────────────────────────────────
class AppColors {
  AppColors._();

  // Backgrounds
  static const Color bg         = Color(0xFFF2F2F7); // iOS systemGray6
  static const Color surface    = Color(0xFFFFFFFF);
  static const Color fill       = Color(0xFFEFEFF0); // input fill
  static const Color fillSecond = Color(0xFFE8E8ED); // pressed fill

  // Text
  static const Color label      = Color(0xFF1C1C1E); // primary text
  static const Color label2     = Color(0xFF3C3C43); // secondary
  static const Color subLabel   = Color(0xFF8E8E93); // muted
  static const Color placeholder= Color(0xFFC7C7CC); // hint

  // Separator / Border
  static const Color separator  = Color(0xFFE5E5EA);
  static const Color border     = Color(0xFFD1D1D6);

  // Brand
  static const Color primary    = Color(0xFF0D47A1);
  static const Color accent     = Color(0xFF1976D2);
  static const Color primaryBg  = Color(0xFFE8EEF9); // primary with 10% opacity

  // Semantic
  static const Color success    = Color(0xFF34C759); // iOS green
  static const Color successBg  = Color(0xFFE8F8EC);
  static const Color warning    = Color(0xFFFF9500); // iOS orange
  static const Color warningBg  = Color(0xFFFFF3E0);
  static const Color danger     = Color(0xFFFF3B30); // iOS red
  static const Color dangerBg   = Color(0xFFFFEBEA);
  static const Color info       = Color(0xFF007AFF); // iOS blue
  static const Color infoBg     = Color(0xFFE5F1FF);
}

// ─── Text Styles ───────────────────────────────────────────────
class AppText {
  AppText._();

  static const TextStyle largeTitle = TextStyle(
    fontSize: 34, fontWeight: FontWeight.w700,
    color: AppColors.label, letterSpacing: 0.37,
  );
  static const TextStyle title1 = TextStyle(
    fontSize: 28, fontWeight: FontWeight.w700,
    color: AppColors.label, letterSpacing: 0.36,
  );
  static const TextStyle title2 = TextStyle(
    fontSize: 22, fontWeight: FontWeight.w600,
    color: AppColors.label, letterSpacing: 0.35,
  );
  static const TextStyle title3 = TextStyle(
    fontSize: 20, fontWeight: FontWeight.w600,
    color: AppColors.label, letterSpacing: 0.38,
  );
  static const TextStyle headline = TextStyle(
    fontSize: 17, fontWeight: FontWeight.w600,
    color: AppColors.label, letterSpacing: -0.41,
  );
  static const TextStyle body = TextStyle(
    fontSize: 17, fontWeight: FontWeight.w400,
    color: AppColors.label, letterSpacing: -0.41,
  );
  static const TextStyle callout = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w400,
    color: AppColors.label, letterSpacing: -0.32,
  );
  static const TextStyle subhead = TextStyle(
    fontSize: 15, fontWeight: FontWeight.w400,
    color: AppColors.label, letterSpacing: -0.24,
  );
  static const TextStyle footnote = TextStyle(
    fontSize: 13, fontWeight: FontWeight.w400,
    color: AppColors.subLabel, letterSpacing: -0.08,
  );
  static const TextStyle caption = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w400,
    color: AppColors.subLabel, letterSpacing: 0,
  );
}

// ─── BoxDecoration Presets ─────────────────────────────────────
class AppDecor {
  AppDecor._();

  static BoxDecoration get card => BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.06),
        blurRadius: 12,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration get input => BoxDecoration(
    color: AppColors.fill,
    borderRadius: BorderRadius.circular(12),
  );

  static BoxDecoration get thinCard => BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.04),
        blurRadius: 8,
        offset: const Offset(0, 1),
      ),
    ],
  );
}

// ─── AppBar factory ────────────────────────────────────────────
PreferredSizeWidget iosAppBar({
  required String title,
  Widget? leading,
  List<Widget>? actions,
  bool automaticallyImplyLeading = true,
  Color? backgroundColor,
}) {
  return AppBar(
    backgroundColor: backgroundColor ?? AppColors.surface,
    foregroundColor: AppColors.primary,
    elevation: 0,
    scrolledUnderElevation: 0.5,
    shadowColor: Colors.black.withValues(alpha: 0.08),
    surfaceTintColor: Colors.transparent,
    centerTitle: true,
    automaticallyImplyLeading: automaticallyImplyLeading,
    leading: leading,
    title: Text(title, style: AppText.headline),
    actions: actions,
  );
}

// ─── IosSection — grouped card section ─────────────────────────
class IosSection extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  final EdgeInsetsGeometry? margin;

  const IosSection({
    super.key,
    this.title,
    required this.children,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 6),
              child: Text(
                title!.toUpperCase(),
                style: AppText.caption.copyWith(
                  color: AppColors.subLabel,
                  letterSpacing: 0.6,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          Container(
            decoration: AppDecor.card,
            clipBehavior: Clip.hardEdge,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── IosCell — standard list cell ──────────────────────────────
class IosCell extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showSeparator;
  final EdgeInsetsGeometry? contentPadding;

  const IosCell({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showSeparator = true,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: AppColors.primary.withValues(alpha: 0.05),
            highlightColor: AppColors.fill,
            child: Padding(
              padding: contentPadding ??
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              child: Row(
                children: [
                  if (leading != null) ...[
                    leading!,
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: AppText.body),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            style: AppText.footnote,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: 8),
                    trailing!,
                  ] else if (onTap != null) ...[
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.border,
                      size: 20,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        if (showSeparator)
          const Padding(
            padding: EdgeInsets.only(left: 16),
            child: Divider(
              height: 0.5,
              thickness: 0.5,
              color: AppColors.separator,
            ),
          ),
      ],
    );
  }
}

// ─── StatusChip ────────────────────────────────────────────────
class StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final double fontSize;

  const StatusChip(this.label, this.color, {super.key, this.fontSize = 12});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: color,
          height: 1.2,
        ),
      ),
    );
  }
}

// ─── SectionHeader — label above grouped section ───────────────
class SectionHeader extends StatelessWidget {
  final String text;
  const SectionHeader(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 16, 8),
      child: Text(
        text.toUpperCase(),
        style: AppText.caption.copyWith(
          letterSpacing: 0.6,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ─── InitialsAvatar ────────────────────────────────────────────
class InitialsAvatar extends StatelessWidget {
  final String name;
  final double size;
  final Color? color;

  const InitialsAvatar({
    super.key,
    required this.name,
    this.size = 40,
    this.color,
  });

  String _initials() {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final bg = color ?? AppColors.primary;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          _initials(),
          style: TextStyle(
            fontSize: size * 0.38,
            fontWeight: FontWeight.w700,
            color: bg,
          ),
        ),
      ),
    );
  }
}

// ─── IosMenuCard — feature grid card ──────────────────────────
class IosMenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final String? badge;

  const IosMenuCard({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: AppDecor.card,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 26),
                ),
                if (badge != null)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.danger,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        badge!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: AppText.caption.copyWith(
                color: AppColors.label,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── StatCard — compact stat display ──────────────────────────
class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final IconData? icon;

  const StatCard({
    super.key,
    required this.value,
    required this.label,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecor.card,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
          if (icon != null) const SizedBox(height: 10),
          Text(
            value,
            style: AppText.title2.copyWith(color: color),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppText.caption),
        ],
      ),
    );
  }
}

// ─── GreetingCard — top header card ───────────────────────────
class GreetingCard extends StatelessWidget {
  final String greeting;
  final String name;
  final String? subtitle;
  final Widget? trailing;
  final Color? accentColor;

  const GreetingCard({
    super.key,
    required this.greeting,
    required this.name,
    this.subtitle,
    this.trailing,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppColors.primary;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, Color.lerp(color, Colors.black, 0.18)!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.30),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: AppText.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  style: AppText.title3.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: AppText.caption.copyWith(
                      color: Colors.white.withValues(alpha: 0.70),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 12),
            trailing!,
          ],
        ],
      ),
    );
  }
}

// ─── IosSearchBar ─────────────────────────────────────────────
class IosSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;

  const IosSearchBar({
    super.key,
    required this.controller,
    this.hint = 'Tìm kiếm',
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: AppDecor.input,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppText.body,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppText.body.copyWith(color: AppColors.placeholder),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.subLabel,
            size: 20,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.cancel,
                    color: AppColors.subLabel,
                    size: 18,
                  ),
                  onPressed: () {
                    controller.clear();
                    onChanged?.call('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 13,
          ),
        ),
      ),
    );
  }
}

// ─── PrimaryButton ────────────────────────────────────────────
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? color;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final bg = color ?? AppColors.primary;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: (isLoading || onPressed == null) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: Colors.white,
          disabledBackgroundColor: bg.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(label, style: AppText.headline.copyWith(color: Colors.white)),
                ],
              ),
      ),
    );
  }
}

// ─── OutlineButton ────────────────────────────────────────────
class AppOutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final IconData? icon;

  const AppOutlineButton({
    super.key,
    required this.label,
    this.onPressed,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final fg = color ?? AppColors.primary;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: fg,
          side: BorderSide(color: AppColors.separator, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: fg),
              const SizedBox(width: 8),
            ],
            Text(label, style: AppText.headline.copyWith(color: fg)),
          ],
        ),
      ),
    );
  }
}

// ─── EmptyState ───────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.fill,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 38, color: AppColors.subLabel),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: AppText.headline.copyWith(color: AppColors.label),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: AppText.subhead.copyWith(color: AppColors.subLabel),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
