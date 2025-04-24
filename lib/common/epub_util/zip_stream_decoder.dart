import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:koko/common/global.dart';
import 'package:koko/models/epub_models/central_directory_entry.dart';

/// http range流式解析epub
///
/// epub的文件单独放一个文件夹，方便后续归类出来单独开源到flutter pub
class ZipStreamDecoder {
  /// 单例实例
  ///
  /// XXX约定项目的所有单例以instance的形式获取
  static ZipStreamDecoder? _instance;
  static ZipStreamDecoder get instance =>
      _instance ??= ZipStreamDecoder._internal();
  ZipStreamDecoder._internal();

  // End of Central Directory 标志
  static const int eocdSignature = 0x06054b50;
  // Central Directory 标志
  static const int centralDirSignature = 0x02014b50;
  // Local File Header 标志
  static const int localFileHeaderSignature = 0x04034b50;

  /// 读取压缩包末尾的CentralDirectory文件头信息，并返回所有的头信息Map
  ///
  /// [zipDate] 压缩包内容（包含64k包尾的分片），[totalContentLe] 压缩包总长度
  Future<Map<String, CentralDirectoryEntry>> parseZipDirectory(
    Uint8List zipData,
    int totalContentLen,
  ) async {
    return await Global.instance.loadBalancer.run((arguments) {
      Uint8List zipData = arguments[0] as Uint8List;
      int totalContentLen = arguments[1] as int;
      assert(zipData.length >= 65536, "请传入64kb以上的包尾");
      // 1. **寻找 EOCD 记录（End of Central Directory）**
      int eocdOffset = -1;
      for (int i = zipData.length - 22; i >= 0; i--) {
        if (_readUint32(zipData, i) == eocdSignature) {
          eocdOffset = i;
          break;
        }
      }
      if (eocdOffset == -1) {
        throw ArgumentError("未找到 ZIP 目录索引");
      }

      // 2. **读取 Central Directory 偏移**
      // 整个文件的实际的offset
      int centralDirectoryOffset = _readUint32(zipData, eocdOffset + 16);
      // print("Central Directory 偏移量: $centralDirectoryOffset");

      // 3. **解析 Central Directory，寻找 container.xml**
      // 相对于zipData的offset
      // 离末尾的长度
      // int len = (totalContentLen - centralDirectoryOffset - 1);
      // 在zipdata的坐标
      // int offset = zipData.length - len - 1;
      // 公式可以化简为
      int offset = zipData.length - totalContentLen + centralDirectoryOffset;

      Map<String, CentralDirectoryEntry> centralDirectoryMap = {};

      CentralDirectoryEntry? entry;

      /// 解析文件头
      while (offset < zipData.length - 46) {
        if (_readUint32(zipData, offset) == centralDirSignature) {
          /// Central Directory 文件头
          // 压缩大小
          int compressedSize = _readUint32(zipData, offset + 20);
          // 解压大小
          int uncompressedSize = _readUint32(zipData, offset + 24);
          // 文件偏移量，最终用来找文件位置的
          int fileOffset = _readUint32(zipData, offset + 42);
          // 文件名长度
          int fileNameLength = _readUint16(zipData, offset + 28);
          // 额外字段长度
          int extraFieldLength = _readUint16(zipData, offset + 30);
          // 注释长度
          int fileCommentLength = _readUint16(zipData, offset + 32);
          // 压缩方式 8 = 无损
          bool isInflate = _readUint16(zipData, offset + 10) == 8;

          // 读取文件名
          String fileName = utf8.decode(
            zipData.sublist(offset + 46, offset + 46 + fileNameLength),
          );

          // 记录 Map
          // 更新entry的len
          if (entry != null) {
            entry.lenth = fileOffset - entry.offset;
            // 加入map
            centralDirectoryMap[entry.filePath] = entry;
          }
          // 更新entry的指针
          entry = CentralDirectoryEntry(
            filePath: fileName,
            offset: fileOffset,
            lenth: 0,
            compressedSize: compressedSize,
            uncompressedSize: uncompressedSize,
            isInflate: isInflate,
          );

          /// 更新offset
          offset += 46 + fileNameLength + extraFieldLength + fileCommentLength;
        } else {
          break;
        }
      }
      // 写入最后一个entry
      if (entry != null) {
        entry.lenth = centralDirectoryOffset - entry.offset;
        centralDirectoryMap[entry.filePath] = entry;
      }
      return centralDirectoryMap;
    }, [zipData, totalContentLen]);
  }

  /// 解包 ZIP 片段，并返回解包后的 [Uint8List]
  ///
  /// 记得读全，可以多读不能少读
  Future<Uint8List> extractZipEntry(Uint8List data) async {
    return await Global.instance.loadBalancer.run((zipData) {
      if (zipData.length < 30) {
        throw ArgumentError("数据长度不足，无法解析 ZIP 结构");
      }

      int offset = 0;

      // 检查 ZIP 本地文件头
      if (_readUint32(zipData, offset) != localFileHeaderSignature) {
        throw ArgumentError("不是 ZIP 本地文件头");
      }

      // 解析头部信息
      // 压缩方式
      int compressionMethod = _readUint16(zipData, offset + 8);
      // 压缩后大小
      int compressedSize = _readUint32(zipData, offset + 18);
      // 文件名长度
      int fileNameLength = _readUint16(zipData, offset + 26);
      // 额外字段长度
      int extraFieldLength = _readUint16(zipData, offset + 28);

      // print("压缩方式: $compressionMethod");
      // print("压缩后大小: $compressedSize");
      // print("未压缩大小: $uncompressedSize");

      // 计算数据开始位置
      int dataOffset = offset + 30 + fileNameLength + extraFieldLength;

      if (dataOffset + compressedSize > zipData.length) {
        throw ArgumentError("数据不足，无法提取文件内容");
      }

      // 提取文件数据
      Uint8List fileData = zipData.sublist(
        dataOffset,
        dataOffset + compressedSize,
      );

      // 处理压缩
      if (compressionMethod == 0) {
        // 0: 存储（无压缩），直接返回数据
        return fileData;
      } else if (compressionMethod == 8) {
        // 8: DEFLATE，需要手动解压
        try {
          // HACK: 我不想手写Huffman树，用一下包
          return Uint8List.fromList(Inflate(fileData).getBytes());
        } catch (e) {
          throw ("DEFLATE 解压失败: $e");
        }
      } else {
        throw ("不支持的压缩方式: $compressionMethod");
      }
    }, data);
  }

  /// dart默认为大端读取，因此反过来组合

  /// **读取 Uint32（小端序）**
  static int _readUint32(Uint8List data, int offset) {
    return data[offset] |
        (data[offset + 1] << 8) |
        (data[offset + 2] << 16) |
        (data[offset + 3] << 24);
  }

  /// **读取 Uint16（小端序）**
  static int _readUint16(Uint8List data, int offset) {
    return data[offset] | (data[offset + 1] << 8);
  }
}
