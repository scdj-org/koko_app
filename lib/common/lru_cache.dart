import 'dart:async';
import 'dart:collection';

import 'package:synchronized/synchronized.dart';

/// LRU缓存
class LruCache<K, V> {
  /// 缓存最大个数
  final int maxSize;
  final LinkedHashMap<K, V> _cache = LinkedHashMap();

  /// 锁
  final _lock = Lock();

  LruCache(this.maxSize);

  /// 获取缓存数据，并更新顺序（LRU 机制）
  Future<V?> get(K key) async {
    return await _lock.synchronized<V?>(() {
      if (!_cache.containsKey(key)) return null;
      // 将当前 key 移到最后，表示最近访问
      V value = _cache.remove(key) as V;
      _cache[key] = value;
      return value;
    });
  }

  /// 存储数据，并维护 LRU 规则
  Future<void> put(K key, V value) async {
    await _lock.synchronized<void>(() {
      if (_cache.length >= maxSize) {
        _cache.remove(_cache.keys.first); // 移除最久未使用的项
      }
      _cache[key] = value;
    });
  }

  /// 移除指定 key
  Future<void> remove(K key) async {
    await _lock.synchronized<void>(() {
      _cache.remove(key);
    });
  }

  /// 清空缓存
  Future<void> clear() async {
    await _lock.synchronized(() {
      _cache.clear();
    });
  }

  /// 获取当前缓存大小
  int get size => _cache.length;

  /// 获取所有的 keys
  Iterable<K> get keys => _cache.keys;

  /// 获取所有的 values
  Iterable<V> get values => _cache.values;
}
