import 'package:flutter/material.dart';
import 'package:koko/models/entity/view_page_entity.dart';

/// 移动文件的model
class MoveFileModel extends ChangeNotifier {
  bool _isMoving = false;
  bool get isMoving => _isMoving;
  set isMoving(bool value) {
    if (value == _isMoving) return;
    _isMoving = value;
    notifyListeners();
  }

  Set<ViewPageEntity> sourceEntities = {};
  ViewPageEntity? sourceDir;

  void clear() {
    sourceEntities.clear();
    sourceDir = null;
    isMoving = false;
  }

  void init({required ViewPageEntity source, required Set<ViewPageEntity> entities}) {
    sourceDir = source;
    sourceEntities = Set.from(entities);
    isMoving = true;
  }
}
