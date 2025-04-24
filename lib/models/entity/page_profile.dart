import 'package:json_annotation/json_annotation.dart';
import 'package:koko/enums/file_mode_enum.dart';
import 'package:koko/enums/page_style_mode_enum.dart';
import 'package:koko/enums/page_sorted_mode_enum.dart';

@JsonSerializable()
class PageProfile {
  PageProfile({this.pageSortedMode, this.pageStyleMode, this.gridCrossCount, this.fileModeMap});

  PageStyleModeEnum? pageStyleMode;
  PageSortedModeEnum? pageSortedMode;
  int? gridCrossCount;
  Map<String, FileModeEnum>? fileModeMap;

  factory PageProfile.fromJson(
    Map<String, dynamic> json, {
    bool global = false,
  }) {
    var pageStyleMode = PageStyleModeEnum.fromModeId(
      json['pageStyleMode'] as int?,
    );
    var pageSortedMode = PageSortedModeEnum.fromSortedModeId(
      json['pageSortedMode'] as int?,
    );
    var gridCrossCount = json['gridCrossCount'] as int?;
    if (global) {
      return PageProfile(
        pageSortedMode: pageSortedMode ?? PageSortedModeEnum.byName,
        pageStyleMode: pageStyleMode ?? PageStyleModeEnum.simpleList,
        gridCrossCount: gridCrossCount ?? 3,
        fileModeMap: null,
      );
    }
    var fileModeMapOrigin = (json['fileModeMap'] as Map<String, dynamic>?);
    Map<String, FileModeEnum>? fileModeMap;
    if (fileModeMapOrigin == null) {
      fileModeMap = null;
    } else {
      fileModeMap = fileModeMapOrigin.map(
        (key, value) =>
            MapEntry(key, FileModeEnum.fromFileModeId(value as int)!),
      );
    }
    return PageProfile(
      pageSortedMode: pageSortedMode,
      pageStyleMode: pageStyleMode,
      gridCrossCount: gridCrossCount,
      fileModeMap: fileModeMap,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'pageStyleMode': pageStyleMode?.modeNum,
      'pageSortedMode': pageSortedMode?.modeNum,
      'gridCrossCount': gridCrossCount,
      'fileModeMap': fileModeMap?.map(
        (key, value) => MapEntry(key, value.fileModeId),
      ),
    };
  }
}
