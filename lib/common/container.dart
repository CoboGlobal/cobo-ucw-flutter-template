import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

class _Styles {
  static const titleText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );
  static const infoText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );
}

class StepSection extends StatelessWidget {
  final int? order;
  final String? title;
  final String? desc;
  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets? margin;

  const StepSection({
    super.key,
    required this.child,
    this.order = 1,
    this.title = "",
      this.desc = "",
    this.padding = const EdgeInsets.all(16),
      this.margin = const EdgeInsets.fromLTRB(16, 0, 16, 12)
  });

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    if (title!.isNotEmpty) {
      final titleItems = <Widget>[];
      if (order != 0) {
        titleItems.addAll([
          TDTag('$order',
              shape: TDTagShape.round,
              fontWeight: FontWeight.bold,
              theme: TDTagTheme.primary),
          const SizedBox(width: 8)
        ]);
      }
      titleItems.add(TDText(
        title,
        font: TDTheme.of(context).fontTitleLarge,
        textColor: TDTheme.of(context).fontGyColor1,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ));
      items.addAll([
        Row(
          children: titleItems,
        ),
        const SizedBox(height: 8)
      ]);
    }
    if (desc!.isNotEmpty) {
      items.addAll([
        TDText(
          desc,
          font: TDTheme.of(context).fontBodySmall,
          textColor: TDTheme.of(context).fontGyColor3,
          maxLines: 5,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8)
      ]);
    }
    items.add(child);

    return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        margin: margin,
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items,
        ));
  }
}

class InfoSection extends StatelessWidget {
  final String? title;
  final String? desc;
  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets? margin;

  const InfoSection({
    super.key,
    required this.child,
    this.title = "",
    this.desc = "",
    this.padding = const EdgeInsets.all(8),
    this.margin = const EdgeInsets.all(0),
  });

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    if (title!.isNotEmpty) {
      items.addAll([
        TDText(
          title,
          font: TDTheme.of(context).fontTitleMedium,
          textColor: TDTheme.of(context).fontGyColor1,
        ),
        const SizedBox(height: 8)
      ]);
    }
    if (desc!.isNotEmpty) {
      items.addAll([
        TDText(
          desc,
          font: TDTheme.of(context).fontBodyMedium,
          textColor: TDTheme.of(context).fontGyColor3,
        ),
        const SizedBox(height: 8)
      ]);
    } 
    items.add(child);

    return Container(
        width: double.infinity,
        margin: margin,
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items,
        ));
  }
}

class ContextItem extends StatelessWidget {
  final String? title;
  final String? info;
  final Widget? child;

  const ContextItem({super.key, this.title, this.info, this.child})
      : assert(!(info != null && child != null));

  @override
  Widget build(BuildContext context) {
    Widget? childItem = child;
    if (info != null) {
      childItem = Text(
        info!,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.end,
        style:
            _Styles.infoText.copyWith(color: TDTheme.of(context).fontGyColor2),
      );
    }
    final items = <Widget>[
      Container(
        padding: const EdgeInsets.only(right: 8),
        constraints: const BoxConstraints(maxWidth: 136, minWidth: 80),
        child: Text(title ?? "",
            style: _Styles.titleText
                  .copyWith(color: TDTheme.of(context).fontGyColor2))
      ),
      Flexible(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [Flexible(child: childItem ?? const SizedBox.shrink())],
        ),
      ),
    ];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: items,
    );
  }
}
