import 'package:flutter/cupertino.dart';
import 'package:witsy/components/bold_icon.dart';

class Option {
  final String id;
  final String label;

  Option({required this.id, required this.label});
}

class PickerPage extends StatelessWidget {
  final String title;
  final String sectionTitle;
  final List<Option> options;
  final Option? selected;
  final ValueChanged<String> onSelected;

  const PickerPage({
    super.key,
    required this.title,
    required this.sectionTitle,
    required this.options,
    this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor:
          CupertinoColors.systemGroupedBackground.resolveFrom(context),
      navigationBar: CupertinoNavigationBar(
        middle: Text(title),
      ),
      child: SafeArea(
        bottom: false,
        child: ListView(
          children: [
            CupertinoFormSection.insetGrouped(
              header: Text(sectionTitle.toUpperCase()),
              children: options.map((option) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    onSelected(option.id);
                    Navigator.of(context).pop();
                  },
                  child: CupertinoFormRow(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    prefix: Text(option.label),
                    child: option.id == selected?.id
                        ? const BoldIcon(
                            icon: CupertinoIcons.check_mark,
                            color: CupertinoColors.activeBlue,
                          )
                        : Container(),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
