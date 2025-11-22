import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final String? label; // optional label above
  const CustomTextField({super.key, required this.hintText,required this.controller,this.keyboardType=TextInputType.text,this.obscureText=false, this.validator, this.prefixIcon, this.label});

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool isvisible=true;
  bool isFocused=false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (mounted) {
        setState(() { isFocused = _focusNode.hasFocus; });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.0),
      borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
    );

    final focusBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.0),
      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.6),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.label != null) ...[
            Text(widget.label!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
          ],
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: isFocused ? [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.18),
                  blurRadius: 18,
                  spreadRadius: 1,
                  offset: const Offset(0, 6),
                ),
              ] : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TextFormField(
              controller: widget.controller,
              keyboardType: widget.keyboardType,
              obscureText: widget.obscureText ? isvisible : false,
              validator: widget.validator,
              focusNode: _focusNode,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: InputDecoration(
                prefixIcon: widget.prefixIcon,
                filled: true,
                fillColor: Theme.of(context).inputDecorationTheme.fillColor ?? const Color(0xFFF8F6F2),
                hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                hintText: widget.hintText,
                suffixIcon: widget.obscureText ? IconButton(
                  icon: Icon(
                    isvisible ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                    color: isFocused ? Theme.of(context).colorScheme.primary : Colors.black38,
                  ),
                  onPressed: toggleVisibility,
                ) : null,
                border: baseBorder,
                enabledBorder: baseBorder,
                focusedBorder: focusBorder,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void toggleVisibility(){
    setState(() { isvisible=!isvisible; });
  }
}
