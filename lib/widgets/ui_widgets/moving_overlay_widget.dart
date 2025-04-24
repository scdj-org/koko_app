import 'dart:async';

import 'package:flutter/material.dart';
import 'package:koko/l10n/l10n.dart';
import 'package:koko/models/model/move_file_model.dart';

/// 为移动操作定制的ui
class MovingOverlayWidget extends StatefulWidget {
  const MovingOverlayWidget({super.key, required this.moveFileModel, required this.onConfirm});

  final MoveFileModel moveFileModel;

  final FutureOr<void> Function()? onConfirm;

  @override
  State<MovingOverlayWidget> createState() => _MovingOverlayWidgetState();
}

class _MovingOverlayWidgetState extends State<MovingOverlayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
      ),
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: MediaQuery.of(context).viewInsets.bottom + 120,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _offsetAnimation,
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).scaffoldBackgroundColor.withOpacity(0.90),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 5,
                ),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: widget.onConfirm,
                        child: Text(AppLocalizations.of(context).confirmText),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 12, bottom: 12, right: 4),
                        width: 0.5,
                        color: Colors.grey[500],
                      ),
                      Text(
                        AppLocalizations.of(context).moveFilesCount(
                          widget.moveFileModel.sourceEntities.length,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 12, bottom: 12, left: 4),
                        width: 0.5,
                        color: Colors.grey[500],
                      ),
                      TextButton(
                        onPressed: () async {
                          await _controller.reverse();
                          widget.moveFileModel.clear();
                        },
                        child: Text(AppLocalizations.of(context).cancleText),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
