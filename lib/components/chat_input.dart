import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
// ignore: implementation_imports
import 'package:flutter_chat_ui/src/utils/chat_input_height_notifier.dart';
import 'package:provider/provider.dart';

typedef OnAttachmentTapCallback = VoidCallback;
typedef OnMicrophoneTapCallback = VoidCallback;
typedef OnMessageSendCallback = void Function(String text);

class ChatInput extends StatefulWidget {
  final double? left;
  final double? right;
  final double? top;
  final double? bottom;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final double? gap;
  final InputBorder? inputBorder;
  final bool? filled;

  const ChatInput({
    super.key,
    this.left = 24,
    this.right = 24,
    this.top,
    this.bottom = 0,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(8.0),
    this.gap = 0,
    this.inputBorder = const OutlineInputBorder(
      borderSide: BorderSide.none,
      //borderRadius: BorderRadius.all(Radius.circular(24)),
    ),
    this.filled = true,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final GlobalKey _inputKey = GlobalKey();
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateInputHeight());
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inputTheme = context.select((ChatTheme theme) => theme.inputTheme);
    final onAttachmentTap = context.read<OnAttachmentTapCallback?>();
    final onMicrophoneTap = context.read<OnMicrophoneTapCallback?>();

    return Positioned(
      left: 0,
      right: 0,
      top: widget.top,
      bottom: widget.bottom,
      child: Container(
        color: widget.backgroundColor ?? Colors.transparent,
        padding: EdgeInsets.only(
          left: widget.left ?? 0,
          right: widget.right ?? 0,
          top: 16,
        ),
        child: Container(
          key: _inputKey,
          height: 54,
          decoration: BoxDecoration(
            color: inputTheme.backgroundColor,
            borderRadius: BorderRadius.circular(32),
          ),
          padding: widget.padding ?? EdgeInsets.zero,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(CupertinoIcons.paperclip),
                color: inputTheme.hintStyle?.color,
                onPressed: onAttachmentTap,
              ),
              SizedBox(width: widget.gap),
              Expanded(
                child: CupertinoTextField(
                  controller: _textController,
                  placeholder: 'Ask me anything',
                  placeholderStyle: inputTheme.hintStyle,
                  decoration: BoxDecoration(
                    color: inputTheme.backgroundColor,
                  ),
                  style: inputTheme.textStyle,
                  onSubmitted: _handleSubmitted,
                  textInputAction: TextInputAction.send,
                ),
              ),
              IconButton(
                icon: const Icon(CupertinoIcons.mic),
                color: inputTheme.hintStyle?.color,
                onPressed: onMicrophoneTap,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateInputHeight() {
    final renderBox =
        _inputKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      context
          .read<ChatInputHeightNotifier>()
          .updateHeight(renderBox.size.height);
    }
  }

  void _handleSubmitted(String text) {
    if (text.isNotEmpty) {
      context.read<OnMessageSendCallback?>()?.call(text);
      _textController.clear();
    }
  }
}
