import "dart:convert";
import "dart:typed_data";
import "dart:math";
import "dart:math" as _A;
import "dart:async";
import "dart:collection";
abstract class Hash {}
class CryptoUtils {
  static String bytesToHex(List<int> bytes) {
    return _CryptoUtils.bytesToHex_A(bytes);
  }
  static String bytesToBase64(List<int> bytes, {bool urlSafe: false, bool addLineSeparator: false}) {
    return _CryptoUtils.bytesToBase64_A(bytes, urlSafe, addLineSeparator);
  }
  static List<int> base64StringToBytes(String input_A) {
    return _CryptoUtils.base64StringToBytes_A(input_A);
  }
}
const Base64Codec_A BASE64_A = const Base64Codec_A();
const List<int> _decodeTable = const[-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -1, -2, -2, -1, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, 62, -2, 62, -2, 63, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -2, -2, -2, 0, -2, -2, -2, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -2, -2, -2, -2, 63, -2, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2];
const String _encodeTableUrlSafe = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_";
const String _encodeTable = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
const int _LINE_LENGTH = 76;
const int _CR_A = 13;
const int _LF_A = 10;
const List<int> _PAD_BYTES = const[61];
const List<int> _ENCODED_PAD_BYTES = const[37, 51, 68];
const String _PAD = "=";
const String _ENCODED_PAD = "%3D";
class Base64Codec_A extends Codec<List<int>, String> {
  final bool _urlSafe;
  final bool _addLineSeparator;
  final bool _encodePaddingCharacter;
  const Base64Codec_A({bool urlSafe: false, bool addLineSeparator: false, bool encodePaddingCharacter: false}) : _urlSafe = urlSafe, _addLineSeparator = addLineSeparator, _encodePaddingCharacter = encodePaddingCharacter;
  String get name => "base64";
  String encode(List<int> bytes, {bool urlSafe, bool addLineSeparator, bool encodePaddingCharacter}) {
    if (urlSafe == null) urlSafe = _urlSafe;
    if (addLineSeparator == null) addLineSeparator = _addLineSeparator;
    if (encodePaddingCharacter == null) {
      encodePaddingCharacter = _encodePaddingCharacter;
    }
    return new Base64Encoder_A(urlSafe: urlSafe, addLineSeparator: addLineSeparator, encodePaddingCharacter: encodePaddingCharacter).convert(bytes);
  }
  Base64Encoder_A get encoder => new Base64Encoder_A(urlSafe: _urlSafe, addLineSeparator: _addLineSeparator, encodePaddingCharacter: _encodePaddingCharacter);
  Base64Decoder_A get decoder => new Base64Decoder_A();
}
class Base64Encoder_A extends Converter<List<int>, String> {
  final bool _urlSafe;
  final bool _addLineSeparator;
  final bool _encodePaddingCharacter;
  final List<int> _pad;
  const Base64Encoder_A({bool urlSafe: false, bool addLineSeparator: false, bool encodePaddingCharacter: false}) : _urlSafe = urlSafe, _addLineSeparator = addLineSeparator, _encodePaddingCharacter = encodePaddingCharacter, _pad = encodePaddingCharacter == true ? _ENCODED_PAD_BYTES : _PAD_BYTES;
  String convert(List<int> bytes, [int start_A = 0, int end_A]) {
    int bytes_length = bytes.length;
    RangeError.checkValidRange(start_A, end_A, bytes_length);
    if (end_A == null) end_A = bytes_length;
    int length_A = end_A - start_A;
    if (length_A == 0) {
      return "";
    }
    final String lookup_A = _urlSafe ? _encodeTableUrlSafe : _encodeTable;
    final int remainderLength = length_A.remainder(3);
    final int chunkLength = length_A - remainderLength;
    int baseOutputLength = ((length_A ~/ 3) * 4);
    int remainderOutputLength;
    if (_encodePaddingCharacter) {
      remainderOutputLength = ((remainderLength > 0) ? 6 : 0);
    } else {
      remainderOutputLength = ((remainderLength > 0) ? 4 : 0);
    }
    int outputLength = baseOutputLength + remainderOutputLength;
    if (_addLineSeparator) {
      outputLength += ((outputLength - 1) ~/ _LINE_LENGTH) << 1;
    }
    List<int> out = new List<int>(outputLength);
    int j = 0, i = start_A, c = 0;
    while (i < chunkLength) {
      int x_A = ((bytes[i++] << 16) & 0x00FFFFFF) | ((bytes[i++] << 8) & 0x00FFFFFF) | bytes[i++];
      out[j++] = lookup_A.codeUnitAt(x_A >> 18);
      out[j++] = lookup_A.codeUnitAt((x_A >> 12) & 0x3F);
      out[j++] = lookup_A.codeUnitAt((x_A >> 6) & 0x3F);
      out[j++] = lookup_A.codeUnitAt(x_A & 0x3F);
      if (_addLineSeparator && ++c == 19 && j < outputLength - 2) {
        out[j++] = _CR_A;
        out[j++] = _LF_A;
        c = 0;
      }
    }
    if (remainderLength == 1) {
      int x_A = bytes[i];
      out[j++] = lookup_A.codeUnitAt(x_A >> 2);
      out[j++] = lookup_A.codeUnitAt((x_A << 4) & 0x3F);
      out.setRange(j, j + _pad.length, _pad);
      out.setRange(j + _pad.length, j + 2 * _pad.length, _pad);
    } else if (remainderLength == 2) {
      int x_A = bytes[i];
      int y_A = bytes[i + 1];
      out[j++] = lookup_A.codeUnitAt(x_A >> 2);
      out[j++] = lookup_A.codeUnitAt(((x_A << 4) | (y_A >> 4)) & 0x3F);
      out[j++] = lookup_A.codeUnitAt((y_A << 2) & 0x3F);
      out.setRange(j, j + _pad.length, _pad);
    }
    return new String.fromCharCodes(out);
  }
  _Base64EncoderSink_A startChunkedConversion(Sink<String> sink_A) {
    StringConversionSink stringSink;
    if (sink_A is StringConversionSink) {
      stringSink = sink_A;
    } else {
      stringSink = new StringConversionSink.from(sink_A);
    }
    return new _Base64EncoderSink_A(stringSink, _urlSafe, _addLineSeparator);
  }
}
class _Base64EncoderSink_A extends ChunkedConversionSink<List<int>> {
  final Base64Encoder_A _encoder_B;
  final ChunkedConversionSink<String> _outSink;
  final List<int> _buffer_A = new List<int>();
  int _bufferCount = 0;
  _Base64EncoderSink_A(this._outSink, urlSafe, addLineSeparator) : _encoder_B = new Base64Encoder_A(urlSafe: urlSafe, addLineSeparator: addLineSeparator);
  void add(List<int> chunk) {
    var nextBufferCount = (chunk.length + _bufferCount) % 3;
    int decodableLength = _bufferCount + chunk.length - nextBufferCount;
    if (_bufferCount + chunk.length > _buffer_A.length) {
      _buffer_A.replaceRange(_bufferCount, _buffer_A.length, chunk.sublist(0, _buffer_A.length - _bufferCount));
      _buffer_A.addAll(chunk.sublist(_buffer_A.length - _bufferCount));
    } else {
      _buffer_A.replaceRange(_bufferCount, _bufferCount + chunk.length, chunk);
    }
    _outSink.add(_encoder_B.convert(_buffer_A, 0, decodableLength));
    _buffer_A.removeRange(0, decodableLength);
    _bufferCount = nextBufferCount;
  }
  void close() {
    if (_bufferCount > 0) {
      _outSink.add(_encoder_B.convert(_buffer_A.sublist(0, _bufferCount)));
    }
    _outSink.close();
  }
}
class Base64Decoder_A extends Converter<String, List<int>> {
  const Base64Decoder_A();
  List<int> convert(String input_A) {
    int length_A = input_A.length;
    if (length_A == 0) {
      return new Uint8List(0);
    }
    int normalLength = 0;
    int i = 0;
    while (i < length_A) {
      int codeUnit = input_A.codeUnitAt(i);
      int c = _decodeTable[codeUnit];
      if (c == -2) {
        if (codeUnit == _ENCODED_PAD_BYTES[0] && i < length_A - 2 && input_A.codeUnitAt(i + 1) == _ENCODED_PAD_BYTES[1] && input_A.codeUnitAt(i + 2) == _ENCODED_PAD_BYTES[2]) {
          normalLength++;
          i += 2;
        } else {
          throw new FormatException('Invalid character', input_A, i);
        }
      }
      if (c >= 0) normalLength++;
      i++;
    }
    if (normalLength % 4 != 0) {
      throw new FormatException('''Size of Base 64 characters in Input
          must be a multiple of 4''', input_A, normalLength);
    }
    int padLength = 0;
    i = length_A - 1;
    while (i >= 0) {
      int currentCodeUnit = input_A.codeUnitAt(i);
      if (currentCodeUnit == _ENCODED_PAD_BYTES[2] && i >= 2 && input_A.codeUnitAt(i - 1) == _ENCODED_PAD_BYTES[1] && input_A.codeUnitAt(i - 2) == _ENCODED_PAD_BYTES[0]) {
        padLength++;
        i -= 2;
      } else if (_decodeTable[currentCodeUnit] > 0) {
        break;
      } else if (currentCodeUnit == _PAD_BYTES[0]) {
        padLength++;
      }
      i--;
    }
    int outputLength = ((normalLength * 6) >> 3) - padLength;
    List<int> out = new Uint8List(outputLength);
    for (int i = 0, o = 0; o < outputLength;) {
      int x_A = 0;
      for (int j = 4; j > 0;) {
        int c = _decodeTable[input_A.codeUnitAt(i++)];
        if (c >= 0) {
          x_A = ((x_A << 6) & 0x00FFFFFF) | c;
          j--;
        }
      }
      out[o++] = x_A >> 16;
      if (o < outputLength) {
        out[o++] = (x_A >> 8) & 0xFF;
        if (o < outputLength) out[o++] = x_A & 0xFF;
      }
    }
    return out;
  }
  _Base64DecoderSink_A startChunkedConversion(Sink<List<int>> sink_A) {
    if (sink_A is! ByteConversionSink) {
      sink_A = new ByteConversionSink.from(sink_A);
    }
    return new _Base64DecoderSink_A(sink_A);
  }
}
class _Base64DecoderSink_A extends ChunkedConversionSink<String> {
  final Base64Decoder_A _decoder_A = new Base64Decoder_A();
  final ChunkedConversionSink<List<int>> _outSink;
  String _unconverted = "";
  _Base64DecoderSink_A(this._outSink);
  void add(String chunk) {
    if (chunk.isEmpty) return;
    if (_unconverted.isNotEmpty) {
      chunk = _unconverted + chunk;
    }
    chunk = chunk.replaceAll(_ENCODED_PAD, _PAD);
    int decodableLength = chunk.length;
    if (chunk.length > 3 && chunk.contains(_ENCODED_PAD[0], chunk.length - 2)) {
      decodableLength = chunk.lastIndexOf(_ENCODED_PAD[0]);
    }
    decodableLength -= decodableLength % 4;
    _unconverted = chunk.substring(decodableLength);
    if (decodableLength > 0) {
      _outSink.add(_decoder_A.convert(chunk.substring(0, decodableLength)));
    }
  }
  void close() {
    if (_unconverted.isNotEmpty) {
      _outSink.add(_decoder_A.convert(_unconverted));
    }
    _outSink.close();
  }
}
abstract class _CryptoUtils {
  static String bytesToHex_A(List<int> bytes) {
    var result_A = new StringBuffer();
    for (var part_A in bytes) {
      result_A.write('${part_A < 16 ? '0' : ''}${part_A.toRadixString(16)}');
    }
    return result_A.toString();
  }
  static String bytesToBase64_A(List<int> bytes, [bool urlSafe = false, bool addLineSeparator = false]) {
    return BASE64_A.encode(bytes, urlSafe: urlSafe, addLineSeparator: addLineSeparator);
  }
  static List<int> base64StringToBytes_A(String input_A) {
    return BASE64_A.decode(input_A);
  }
}
const _MASK_8 = 0xff;
const _MASK_32 = 0xffffffff;
const _BITS_PER_BYTE = 8;
const _BYTES_PER_WORD = 4;
int _rotl32(int val, int shift) {
  var mod_shift = shift & 31;
  return ((val << mod_shift) & _MASK_32) | ((val & _MASK_32) >> (32 - mod_shift));
}
abstract class _HashBase implements Hash {
  final int _chunkSizeInWords;
  final int _digestSizeInWords;
  final bool _bigEndianWords;
  final Uint32List _currentChunk;
  final Uint32List _h;
  int _lengthInBytes = 0;
  List<int> _pendingData;
  bool _digestCalled = false;
  _HashBase(int chunkSizeInWords, int digestSizeInWords, bool this._bigEndianWords) : _pendingData = [], _currentChunk = new Uint32List(chunkSizeInWords), _h = new Uint32List(digestSizeInWords), _chunkSizeInWords = chunkSizeInWords, _digestSizeInWords = digestSizeInWords;
  void add(List<int> data_A) {
    if (_digestCalled) {
      throw new StateError('Hash update method called after digest was retrieved');
    }
    _lengthInBytes += data_A.length;
    _pendingData.addAll(data_A);
    _iterate();
  }
  List<int> close() {
    if (_digestCalled) {
      return _resultAsBytes();
    }
    _digestCalled = true;
    _finalizeData();
    _iterate();
    assert(_pendingData.length == 0);
    return _resultAsBytes();
  }
  void _updateHash(Uint32List m);
  int _add32(x_A, y_A) => (x_A + y_A) & _MASK_32;
  int _roundUp(val, n) => (val + n - 1) & -n;
  List<int> _resultAsBytes() {
    var result_A = [];
    for (var i = 0; i < _h.length; i++) {
      result_A.addAll(_wordToBytes(_h[i]));
    }
    return result_A;
  }
  void _bytesToChunk(List<int> data_A, int dataIndex) {
    assert((data_A.length - dataIndex) >= (_chunkSizeInWords * _BYTES_PER_WORD));
    for (var wordIndex = 0; wordIndex < _chunkSizeInWords; wordIndex++) {
      var w3 = _bigEndianWords ? data_A[dataIndex] : data_A[dataIndex + 3];
      var w2 = _bigEndianWords ? data_A[dataIndex + 1] : data_A[dataIndex + 2];
      var w1 = _bigEndianWords ? data_A[dataIndex + 2] : data_A[dataIndex + 1];
      var w0 = _bigEndianWords ? data_A[dataIndex + 3] : data_A[dataIndex];
      dataIndex += 4;
      var word_A = (w3 & 0xff) << 24;
      word_A |= (w2 & _MASK_8) << 16;
      word_A |= (w1 & _MASK_8) << 8;
      word_A |= (w0 & _MASK_8);
      _currentChunk[wordIndex] = word_A;
    }
  }
  List<int> _wordToBytes(int word_A) {
    List bytes = new List<int>(_BYTES_PER_WORD);
    bytes[0] = (word_A >> (_bigEndianWords ? 24 : 0)) & _MASK_8;
    bytes[1] = (word_A >> (_bigEndianWords ? 16 : 8)) & _MASK_8;
    bytes[2] = (word_A >> (_bigEndianWords ? 8 : 16)) & _MASK_8;
    bytes[3] = (word_A >> (_bigEndianWords ? 0 : 24)) & _MASK_8;
    return bytes;
  }
  void _iterate() {
    var len = _pendingData.length;
    var chunkSizeInBytes = _chunkSizeInWords * _BYTES_PER_WORD;
    if (len >= chunkSizeInBytes) {
      var index_A = 0;
      for (; (len - index_A) >= chunkSizeInBytes; index_A += chunkSizeInBytes) {
        _bytesToChunk(_pendingData, index_A);
        _updateHash(_currentChunk);
      }
      _pendingData = _pendingData.sublist(index_A, len);
    }
  }
  void _finalizeData() {
    _pendingData.add(0x80);
    var contentsLength = _lengthInBytes + 9;
    var chunkSizeInBytes = _chunkSizeInWords * _BYTES_PER_WORD;
    var finalizedLength = _roundUp(contentsLength, chunkSizeInBytes);
    var zeroPadding = finalizedLength - contentsLength;
    for (var i = 0; i < zeroPadding; i++) {
      _pendingData.add(0);
    }
    var lengthInBits = _lengthInBytes * _BITS_PER_BYTE;
    assert(lengthInBits < pow(2, 32));
    if (_bigEndianWords) {
      _pendingData.addAll(_wordToBytes(0));
      _pendingData.addAll(_wordToBytes(lengthInBits & _MASK_32));
    } else {
      _pendingData.addAll(_wordToBytes(lengthInBits & _MASK_32));
      _pendingData.addAll(_wordToBytes(0));
    }
  }
}
class MD5 extends _HashBase {
  MD5() : super(16, 4, false) {
    _h[0] = 0x67452301;
    _h[1] = 0xefcdab89;
    _h[2] = 0x98badcfe;
    _h[3] = 0x10325476;
  }
  static const _k = const[0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee, 0xf57c0faf, 0x4787c62a, 0xa8304613, 0xfd469501, 0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be, 0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821, 0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa, 0xd62f105d, 0x02441453, 0xd8a1e681, 0xe7d3fbc8, 0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed, 0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a, 0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c, 0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70, 0x289b7ec6, 0xeaa127fa, 0xd4ef3085, 0x04881d05, 0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665, 0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039, 0x655b59c3, 0x8f0ccc92, 0xffeff47d, 0x85845dd1, 0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1, 0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391];
  static const _r = const[7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22, 5, 9, 14, 20, 5, 9, 14, 20, 5, 9, 14, 20, 5, 9, 14, 20, 4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23, 6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21];
  void _updateHash(Uint32List m) {
    assert(m.length == 16);
    var a = _h[0];
    var b = _h[1];
    var c = _h[2];
    var d = _h[3];
    var t0;
    var t1;
    for (var i = 0; i < 64; i++) {
      if (i < 16) {
        t0 = (b & c) | ((~b & _MASK_32) & d);
        t1 = i;
      } else if (i < 32) {
        t0 = (d & b) | ((~d & _MASK_32) & c);
        t1 = ((5 * i) + 1) % 16;
      } else if (i < 48) {
        t0 = b ^ c ^ d;
        t1 = ((3 * i) + 5) % 16;
      } else {
        t0 = c ^ (b | (~d & _MASK_32));
        t1 = (7 * i) % 16;
      }
      var temp = d;
      d = c;
      c = b;
      b = _add32(b, _rotl32(_add32(_add32(a, t0), _add32(_k[i], m[t1])), _r[i]));
      a = temp;
    }
    _h[0] = _add32(a, _h[0]);
    _h[1] = _add32(b, _h[1]);
    _h[2] = _add32(c, _h[2]);
    _h[3] = _add32(d, _h[3]);
  }
}
class SHA1 extends _HashBase {
  final Uint32List _w;
  SHA1() : _w = new Uint32List(80), super(16, 5, true) {
    _h[0] = 0x67452301;
    _h[1] = 0xEFCDAB89;
    _h[2] = 0x98BADCFE;
    _h[3] = 0x10325476;
    _h[4] = 0xC3D2E1F0;
  }
  void _updateHash(Uint32List m) {
    assert(m.length == 16);
    var a = _h[0];
    var b = _h[1];
    var c = _h[2];
    var d = _h[3];
    var e = _h[4];
    for (var i = 0; i < 80; i++) {
      if (i < 16) {
        _w[i] = m[i];
      } else {
        var n = _w[i - 3] ^ _w[i - 8] ^ _w[i - 14] ^ _w[i - 16];
        _w[i] = _rotl32(n, 1);
      }
      var t = _add32(_add32(_rotl32(a, 5), e), _w[i]);
      if (i < 20) {
        t = _add32(_add32(t, (b & c) | (~b & d)), 0x5A827999);
      } else if (i < 40) {
        t = _add32(_add32(t, (b ^ c ^ d)), 0x6ED9EBA1);
      } else if (i < 60) {
        t = _add32(_add32(t, (b & c) | (b & d) | (c & d)), 0x8F1BBCDC);
      } else {
        t = _add32(_add32(t, b ^ c ^ d), 0xCA62C1D6);
      }
      e = d;
      d = c;
      c = _rotl32(b, 30);
      b = a;
      a = t & _MASK_32;
    }
    _h[0] = _add32(a, _h[0]);
    _h[1] = _add32(b, _h[1]);
    _h[2] = _add32(c, _h[2]);
    _h[3] = _add32(d, _h[3]);
    _h[4] = _add32(e, _h[4]);
  }
}
class SHA256 extends _HashBase {
  final Uint32List _w;
  SHA256() : _w = new Uint32List(64), super(16, 8, true) {
    _h[0] = 0x6a09e667;
    _h[1] = 0xbb67ae85;
    _h[2] = 0x3c6ef372;
    _h[3] = 0xa54ff53a;
    _h[4] = 0x510e527f;
    _h[5] = 0x9b05688c;
    _h[6] = 0x1f83d9ab;
    _h[7] = 0x5be0cd19;
  }
  static const List<int> _K = const[0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5, 0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174, 0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da, 0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967, 0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85, 0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070, 0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3, 0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2];
  _rotr32(n, x_A) => (x_A >> n) | ((x_A << (32 - n)) & _MASK_32);
  _ch(x_A, y_A, z_A) => (x_A & y_A) ^ ((~x_A & _MASK_32) & z_A);
  _maj(x_A, y_A, z_A) => (x_A & y_A) ^ (x_A & z_A) ^ (y_A & z_A);
  _bsig0(x_A) => _rotr32(2, x_A) ^ _rotr32(13, x_A) ^ _rotr32(22, x_A);
  _bsig1(x_A) => _rotr32(6, x_A) ^ _rotr32(11, x_A) ^ _rotr32(25, x_A);
  _ssig0(x_A) => _rotr32(7, x_A) ^ _rotr32(18, x_A) ^ (x_A >> 3);
  _ssig1(x_A) => _rotr32(17, x_A) ^ _rotr32(19, x_A) ^ (x_A >> 10);
  void _updateHash(Uint32List M) {
    assert(M.length == 16);
    var i = 0;
    for (; i < 16; i++) {
      _w[i] = M[i];
    }
    for (; i < 64; i++) {
      _w[i] = _add32(_add32(_ssig1(_w[i - 2]), _w[i - 7]), _add32(_ssig0(_w[i - 15]), _w[i - 16]));
    }
    var a = _h[0];
    var b = _h[1];
    var c = _h[2];
    var d = _h[3];
    var e = _h[4];
    var f = _h[5];
    var g = _h[6];
    var h = _h[7];
    for (var t = 0; t < 64; t++) {
      var t1 = _add32(_add32(h, _bsig1(e)), _add32(_ch(e, f, g), _add32(_K[t], _w[t])));
      var t2 = _add32(_bsig0(a), _maj(a, b, c));
      h = g;
      g = f;
      f = e;
      e = _add32(d, t1);
      d = c;
      c = b;
      b = a;
      a = _add32(t1, t2);
    }
    _h[0] = _add32(a, _h[0]);
    _h[1] = _add32(b, _h[1]);
    _h[2] = _add32(c, _h[2]);
    _h[3] = _add32(d, _h[3]);
    _h[4] = _add32(e, _h[4]);
    _h[5] = _add32(f, _h[5]);
    _h[6] = _add32(g, _h[6]);
    _h[7] = _add32(h, _h[7]);
  }
}
class _JsDateTimeClass implements JsNativeClass {
  const _JsDateTimeClass();
  Object constructor(List args) {
    if (args.length == 0) {
      return new DateTime.now();
    }
    if (args.length == 1) {
      Object val0 = args[0];
      if (val0 is num) {
        return new DateTime.fromMillisecondsSinceEpoch(val0);
      }
      if (val0 is String) {
        return dgToDateTime(val0);
      }
    } else if (args.length > 1) {
      List newargs = []
          ..addAll(args);
      while (newargs.length < 7) {
        newargs.add(0);
      }
      return new DateTime(newargs[0], newargs[1], newargs[2], newargs[3], newargs[4], newargs[5], newargs[6]);
    }
    throw 'invalid arguments';
  }
}
Object getDateTimeMember(DateTime d, String name_A) {
  if (name_A == 'day') return d.day;
  if (name_A == 'month') return d.month;
  if (name_A == 'year') return d.year;
  if (name_A == 'hour') return d.hour;
  if (name_A == 'minute') return d.minute;
  if (name_A == 'second') return d.second;
  if (name_A == 'millisecond') return d.millisecond;
  if (name_A == 'millisecondsSinceEpoch') return d.millisecondsSinceEpoch;
  if (name_A == 'isUtc') return d.isUtc;
  if (name_A == 'weekday') return d.weekday;
  if (name_A == 'isUtc') return d.isUtc;
  if (name_A == 'toUtc') return _toUtc;
  if (name_A == 'toLocal') return _toLocal;
  if (name_A == 'timeZoneOffset') return d.timeZoneOffset.inMilliseconds;
  return null;
}
Object _toUtc(Object this_, List args) {
  if (this_ is DateTime) {
    this_.toUtc();
  }
  return null;
}
Object _toLocal(Object this_, List args) {
  if (this_ is DateTime) {
    this_.toLocal();
  }
  return null;
}
Map<String, Program> _programsCache = new DGHashMap<String, Program>();
Program parseProgramString(String str) {
  if (_programsCache.containsKey(str)) {
    return (_programsCache[str]);
  }
  if (_programsCache.length > 2048) {
    _programsCache.clear();
  }
  Parser parser = new Parser(new Lexer(str));
  Program program = parser.parseProgram();
  resolve_A(program);
  _programsCache[str] = program;
  return program;
}
final Map<String, Object> global_functions = {'Number': _toNumber, 'isNaN': _isNaN, 'String': _toString, 'Array': _toArray, 'parseInt': _parseInt, 'parseNumber': parseNumber, 'Math': const JsMath(), 'JSON': const JsJson(), 'XML': const JsXml(), 'DateTime': const _JsDateTimeClass(), 'createPromise': _createPromise};
Object _createPromise(Object this_, List args) {
  Object value_A;
  if (args.length == 1) {
    value_A = args[0];
  }
  return new Future.value(value_A);
}
Object _toNumber(Object this_, List args) {
  return dgToNumber(args[0]);
}
Object _isNaN(Object this_, List args) {
  Object val = args[0];
  return val != val;
}
Object _toString(Object this_, List args) {
  if (args[0] == null) {
    return '';
  }
  if (args.length > 1 && args[1] is int) {
    return dgToInt(args[0]).toRadixString(args[1]);
  }
  return dgToString(args[0]);
}
Object _toArray(Object this_, List args) {
  if (args[0] is List) {
    return args[0];
  }
  if (args[0] is int) {
    return new List(args[0]);
  }
  if (args[0] is ByteData) {
    return ByteDataUtil.toUint8List(args[0] as ByteData);
  }
  if (args[0] is IDGArray) {
    return (args[0] as IDGArray).toArray();
  }
  return null;
}
Object _parseInt(Object this_, List args) {
  if (args.length > 1 && args[1] is int) {
    return int.parse(args[0].toString(), radix: args[1], onError: (str) => 0);
  } else {
    return dgToInt(args[0], 0);
  }
}
RegExp _numberRegex = new RegExp(r"-?[\d\.,]+([Ee]-?[\d-\.]+)?");
Object parseNumber(Object this_, List args) {
  if (args[0] is String) {
    Object defaultRslt = double.NAN;
    if (args.length > 1) {
      defaultRslt = args[1];
    }
    String str = args[0];
    if (str == '') {
      return defaultRslt;
    }
    if (str.codeUnitAt(0) == 35) {
      return int.parse(str.substring(1), radix: 16);
    }
    if (str.startsWith('0x')) {
      return int.parse(str.substring(2), radix: 16);
    }
    Match m = _numberRegex.firstMatch(str);
    if (m != null) {
      str = m.group(0);
      if (str.contains(',')) {
        str = str.replaceAll(',', '');
      }
      int rslt = int.parse(str, onError: dgToIntError);
      if (rslt != null) {
        return rslt;
      }
      double drslt = double.parse(str, dgToNumberError);
      if (drslt == drslt) {
        return drslt;
      }
    }
    return defaultRslt;
  }
  return double.NAN;
}
class JsJson implements IDGMap {
  const JsJson();
  Object getValue(String name_A) {
    return jsonMap[name_A];
  }
  void setValue(String name_A, Object val) {
    throw "can't change readonly object";
  }
  void updateValue(String name_A, Object val) {
    throw "can't change readonly object";
  }
  void setBinding(String name_A, String val) {
    throw "can't change readonly object";
  }
}
const Map<String, Object> jsonMap = const{'parse': jsonParse, 'stringify': jsonStringify};
Object jsonParse(Object this_, List args) {
  Object val = args[0];
  if (val is String) {
    try {
      return const JsonDecoder().convert(val);
    } catch (e) {}
  }
  return null;
}
Object jsonStringify(Object this_, List args) {
  Object val = args[0];
  JsonEncoder encoder_B = const JsonEncoder();
  if (args.length > 1 && (args[1] is num || args[1] is String)) {
    String indent_A = "";
    if (args[1] is num) {
      indent_A = " " * (args[1] as num).toInt();
    } else {
      indent_A = args[1].toString();
    }
    if (indent_A == "  ") {
      encoder_B = const JsonEncoder.withIndent("  ");
    } else {
      encoder_B = new JsonEncoder.withIndent(indent_A);
    }
  }
  return encoder_B.convert(val);
}
final List<String> KEYWORDS = const<String>["as", "break", "case", "catch", "class", "const", "continue", "default", "delete", "do", "else", "extends", "false", "finally", "for", "function", "if", "import", "in", "is", "namespace", "new", "null", "package", "private", "public", "return", "super", "switch", "this", "throw", "true", "try", "typeof", "use", "var", "void", "while"];
final List<String> FUTURE_RESERVED = const<String>["abstract", "debugger", "enum", "export", "goto", "implements", "interface", "native", "protected", "synchronized", "throws", "transient", "volatile", "instanceof", "with"];
Set<String> _keywordSet = null;
Set<String> get keywordSet {
  if (_keywordSet == null) {
    _keywordSet = new Set<String>();
    for (String keyword in KEYWORDS) _keywordSet.add(keyword);
  }
  return _keywordSet;
}
Set<String> _futureReservedSet = null;
Set<String> get futureReservedSet {
  if (_futureReservedSet == null) {
    _futureReservedSet = new Set<String>();
    for (String reserved in FUTURE_RESERVED) _futureReservedSet.add(reserved);
  }
  return _futureReservedSet;
}
bool CARE_FUTURE_RESERVED = true;
bool isReserved(String symbol) {
  if (keywordSet.contains(symbol)) return true;
  if (CARE_FUTURE_RESERVED && futureReservedSet.contains(symbol)) return true;
  return false;
}
class Token {
  final String type;
  final int pos;
  final value;
  const Token(this.type, this.pos, [this.value]);
  String toString() => "${type} (${pos}): ${value}";
}
final LINE_TERMINATORS = "\x0A\x0D";
final BLANKS_NO_LINE_TERMINATORS = "\x20\x09\x0B\x0C\xA0";
final DIGITS = "0123456789";
final HEX = "${DIGITS}ABCDEFabcdef";
class Lexer {
  static final int $a = "a".codeUnitAt(0);
  static final int $b = "b".codeUnitAt(0);
  static final int $f = "f".codeUnitAt(0);
  static final int $n = "n".codeUnitAt(0);
  static final int $r = "r".codeUnitAt(0);
  static final int $t = "t".codeUnitAt(0);
  static final int $z = "z".codeUnitAt(0);
  static final int $A = "A".codeUnitAt(0);
  static final int $Z = "Z".codeUnitAt(0);
  static final int $NEWLINE = "\n".codeUnitAt(0);
  final String input;
  int len;
  int pos = 0;
  Lexer(this.input) {
    len = input.length;
  }
  bool isInStringSet(String c, String set_A) {
    for (int i = 0; i < set_A.length; i++) {
      if (set_A[i] == c) return true;
    }
    return false;
  }
  bool isDigit(String c) => isInStringSet(c, DIGITS);
  bool isHex(String c) => isInStringSet(c, HEX);
  bool isLineTerminator(String c) => isInStringSet(c, LINE_TERMINATORS);
  bool isBlankNoLineTerminator(String c) => isInStringSet(c, BLANKS_NO_LINE_TERMINATORS);
  bool isIdStart(String c) {
    if (c == r'$' || c == "_" || c == '@') return true;
    int cValue = c.codeUnitAt(0);
    return ($a <= cValue && cValue <= $z || $A <= cValue && cValue <= $Z);
  }
  bool isIdPart(String c) => isIdStart(c) || isDigit(c);
  void eatBlanks() {
    while (pos < len && isBlankNoLineTerminator(input[pos])) {
      pos++;
    }
  }
  void eatLineTerminators() {
    while (pos < len && isLineTerminator(input[pos])) {
      pos++;
    }
  }
  bool pointsTo(String str) {
    if (pos + str.length < input.length) {
      for (int i = 0; i < str.length; i++) {
        if (input[pos + i] != str[i]) return false;
      }
      return true;
    }
    return false;
  }
  void eatUntilLineTerminator() {
    while (pos < len && !isLineTerminator(input[pos])) pos++;
  }
  void eatDigits() {
    while (pos < len && isDigit(input[pos])) pos++;
  }
  void eatHex() {
    while (pos < len && isHex(input[pos])) pos++;
  }
  Token readString(String startChar) {
    assert(pos < len);
    assert(input[pos] == startChar);
    int startPos = pos;
    pos++;
    bool sawBackslash = false;
    while (pos < len && !(isLineTerminator(input[pos]) && !sawBackslash)) {
      if (sawBackslash) {
        sawBackslash = false;
        pos++;
      } else {
        if (input[pos] == startChar) {
          pos++;
          String value_A = input.substring(startPos, pos);
          return new Token("STRING", startPos, value_A);
        }
        sawBackslash = (input[pos++] == "\\");
      }
    }
    throw "Unterminated string ${startPos}";
  }
  Token readKeywordOrIdentifier() {
    assert(isIdStart(input[pos]));
    int startPos = pos;
    while (pos < len && isIdPart(input[pos])) pos++;
    String value_A = input.substring(startPos, pos);
    if (isReserved(value_A)) {
      return new Token(value_A.toUpperCase(), startPos, value_A);
    }
    return new Token("ID", startPos, value_A);
  }
  int eatMultiLineComment() {
    int startPos = pos;
    bool sawStar = false;
    int lineTerminatorPosition = null;
    while (pos < len) {
      String c = input[pos++];
      if (c == "/" && sawStar) return lineTerminatorPosition;
      if (lineTerminatorPosition == null && isLineTerminator(c)) {
        lineTerminatorPosition = pos - 1;
      }
      sawStar = (c == "*");
    }
    throw "Unterminated multi-line comment ${startPos}";
  }
  Token readNumber() {
    Token createNumberToken(int startPos) {
      String value_A = input.substring(startPos, pos);
      return new Token("NUMBER", startPos, value_A);
    }
    assert(isDigit(input[pos]) || input[pos] == '.');
    bool startsWithDot = input[pos] == '.';
    if (startsWithDot) pos++;
    int startPos = pos;
    eatDigits();
    if (pos < len) {
      String c = input[pos];
      if (c == "." && !startsWithDot) {
        pos++;
        if (pos < len && isDigit(input[pos])) {
          eatDigits();
          if (pos < len && (input[pos] == "e" || input[pos] == "E")) {
            pos++;
            if (pos < len && (input[pos] == "+" || input[pos] == "-")) {
              pos++;
            }
            if (pos >= len || !isDigit(input[pos])) {
              throw "Unterminated number literal ${startPos}";
            }
            eatDigits();
          }
        }
      } else if (c == "x" || c == "X") {
        pos++;
        if (pos >= len || !isHex(input[pos])) {
          throw "Unterminated number literal ${startPos}";
        }
        eatHex();
      }
    }
    return createNumberToken(startPos);
  }
  Token get eofToken => new Token("EOF", input.length);
  Token consumeSymbolToken(String symbol) {
    int len_A = symbol.length;
    int pos1 = pos;
    pos += len_A;
    return new Token(symbol, pos1, symbol);
  }
  Token next() {
    eatBlanks();
    if (pointsTo("//")) {
      eatUntilLineTerminator();
    }
    if (pointsTo("/*")) {
      int lineTerminatorPosition = eatMultiLineComment();
      if (lineTerminatorPosition != null) {
        return new Token("NEW_LINE", lineTerminatorPosition);
      }
    }
    if (pos >= input.length) return eofToken;
    String c = input[pos];
    if (isLineTerminator(c)) {
      Token result_A = new Token("NEW_LINE", pos);
      eatLineTerminators();
      return result_A;
    }
    if (isInStringSet(c, DIGITS)) {
      return readNumber();
    }
    switch (c) {
      case "{":
        return new Token("LBRACE", pos++, c);

      case "}":
        return new Token("RBRACE", pos++, c);

      case "(":
        return new Token("LPAREN", pos++, c);

      case ")":
        return new Token("RPAREN", pos++, c);

      case "[":
        return new Token("LBRACKET", pos++, c);

      case "]":
        return new Token("RBRACKET", pos++, c);

      case ";":
        return new Token("SEMICOLON", pos++, c);

      case ",":
        return new Token("COMMA", pos++, c);

      case ":": case "?":
        return new Token(c, pos++, c);

      case ".":
        pos++;
        if (pos < len && isDigit(input[pos])) {
          pos--;
          return readNumber();
        }
        return new Token("DOT", pos, c);

      case "|":
        if (pointsTo("||")) return consumeSymbolToken("||");
        if (pointsTo("|=")) return consumeSymbolToken("|=");
        return new Token(c, pos++, c);

      case "&":
        if (pointsTo("&&")) return consumeSymbolToken("&&");
        if (pointsTo("&=")) return consumeSymbolToken("&=");
        return new Token(c, pos++, c);

      case "<":
        if (pointsTo("<<=")) return consumeSymbolToken("<<=");
        if (pointsTo("<<")) return consumeSymbolToken("<<");
        if (pointsTo("<=")) return consumeSymbolToken("<=");
        return new Token(c, pos++, c);

      case ">":
        if (pointsTo(">>>")) return consumeSymbolToken(">>>");
        if (pointsTo(">>=")) return consumeSymbolToken(">>=");
        if (pointsTo(">>")) return consumeSymbolToken(">>");
        if (pointsTo(">=")) return consumeSymbolToken(">=");
        return new Token(c, pos++, c);

      case "!":
        if (pointsTo("!==")) return consumeSymbolToken("!==");
        if (pointsTo("!=")) return consumeSymbolToken("!=");
        return new Token(c, pos++, c);

      case "=":
        if (pointsTo("===")) return consumeSymbolToken("===");
        if (pointsTo("==")) return consumeSymbolToken("==");
        return new Token(c, pos++, c);

      case "+": case "-": case "*": case "/": case "%": case "^":
        pos++;
        if (pos < len && input[pos] == "=") {
          String symbol = "${c}=";
          return new Token(symbol, (pos++) - 1, symbol);
        }
        if ((c == "+" || c == "-") && input[pos] == c) {
          String symbol = "${c}${c}";
          return new Token(symbol, (pos++) - 1, symbol);
        }
        return new Token(c, pos - 1, c);

      case "'": case '"':
        return readString(c);

      case "~":
        if (pointsTo("~=")) return consumeSymbolToken("~=");
        throw "Unexpected character ${c} ${pos}";

      default:
        if (isIdStart(c)) {
          return readKeywordOrIdentifier();
        }
        throw "Unexpected character ${c} ${pos}";
    }
  }
  Token lexRegExp() {
    int startPos = pos;
    bool sawBackslash = false;
    while (pos < len && !isLineTerminator(input[pos])) {
      if (sawBackslash) {
        sawBackslash = false;
        pos++;
      } else {
        if (input[pos] == "/") {
          pos++;
          while (isIdPart(input[pos])) pos++;
          String value_A = input.substring(startPos, pos);
          return new Token("REGEXP", startPos, value_A);
        }
        sawBackslash = (input[pos++] == "\\");
      }
    }
    throw "Unterminated regexp ${startPos}";
  }
}
Object getListMember(List list_A, Object name_A) {
  if (name_A is int) {
    if (name_A < list_A.length && name_A > -1) {
      return list_A[name_A];
    }
  } else if (name_A is String) {
    if (name_A == 'length') return list_A.length;
    if (name_A == 'indexOf') return _listIndexOf;
    if (name_A == 'push' || name_A == 'add') return _listPush;
    if (name_A == 'pushAll' || name_A == 'allAll') return _listPushAll;
    if (name_A == 'pop') return _listPop;
    if (name_A == 'shift') return _listShift;
    if (name_A == 'unshift') return _listUnshift;
    if (name_A == 'slice') return _listSlice;
    if (name_A == 'splice') return _listSplice;
    if (name_A == 'join') return _listJoin;
    if (name_A == 'sort') return _listSort;
    if (name_A == 'concat') return _listConcat;
    if (name_A == 'first') return list_A.first;
    if (name_A == 'last') return list_A.last;
    if (name_A == 'query') return _xmlCollectionQuery;
    if (name_A == 'queryAll') return _xmlCollectionQueryAll;
    if (name_A == 'forEach') return _listForEach;
    if (name_A == 'where') return _listWhere;
    if (name_A == 'map') return _listMap;
    if (name_A == 'encodeBase64') return _listEncodeBase64;
  }
  return null;
}
Object _listForEach(Object this_, List args) {
  if (this_ is List && args.length >= 1 && args[0] is ScriptFunction) {
    ScriptFunction func = args[0];
    this_.forEach((element_A) {
      func(this_, [element_A]);
    });
  }
  return null;
}
Object _listWhere(Object this_, List args) {
  if (this_ is List && args.length >= 1 && args[0] is ScriptFunction) {
    ScriptFunction func = args[0];
    return this_.where((element_A) {
      return dgToBoolJs(func(this_, [element_A]));
    }).toList();
  }
  return null;
}
Object _listMap(Object this_, List args) {
  if (this_ is List && args.length >= 1 && args[0] is ScriptFunction) {
    ScriptFunction func = args[0];
    return this_.map((element_A) {
      return func(this_, [element_A]);
    }).toList();
  }
  return null;
}
Object _listPushAll(Object this_, List args) {
  if (this_ is List && args.length > 1 && args[0] is Iterable) {
    Object arg0 = args[0];
    this_.addAll(arg0);
  }
  return null;
}
Object _listPush(Object this_, List args) {
  if (this_ is List) {
    Object arg0 = args[0];
    this_.add(arg0);
  }
  return null;
}
Object _listPop(Object this_, List args) {
  if (this_ is List) {
    return this_.removeLast();
  }
  return null;
}
Object _listUnshift(Object this_, List args) {
  if (this_ is List) {
    Object arg0 = args[0];
    this_.insert(0, arg0);
  }
  return null;
}
Object _listSlice(Object this_, List args) {
  if (this_ is List) {
    int arg0 = dgToInt(args[0]);
    int arg1 = this_.length;
    if (args.length > 1) {
      arg1 = dgToInt(args[1]);
    }
    return this_.getRange(arg0, arg1);
  }
  return null;
}
Object _listSplice(Object this_, List args) {
  if (this_ is List) {
    int start_A = dgToInt(args[0]);
    int len = dgToInt(args[1]) + start_A;
    var newValues = args.getRange(2, args.length);
    List rslt = this_.getRange(start_A, len).toList();
    this_.replaceRange(start_A, len, newValues);
    return rslt;
  }
  return null;
}
Object _listShift(Object this_, List args) {
  if (this_ is List) {
    return this_.removeAt(0);
  }
  return null;
}
Object _listIndexOf(Object this_, List args) {
  if (this_ is List) {
    Object arg0 = args[0];
    return this_.indexOf(arg0);
  }
  return -1;
}
Object _listJoin(Object this_, List args) {
  if (this_ is List) {
    if (args.length > 0) {
      return this_.join(args[0]);
    }
    return this_.join();
  }
  return null;
}
Object _listSort(Object this_, List args) {
  if (this_ is List) {
    if (args.length > 0 && args[0] is ScriptFunction) {
      ScriptFunction fun = args[0];
      int compareWithScript(Object val1, Object val2) {
        Object rslt = fun(null, [val1, val2]);
        if (rslt is num) {
          if (rslt > 0) return 1;
          if (rslt < 0) return -1;
        }
        return 0;
      }
      this_.sort(compareWithScript);
      return this_;
    }
    bool sortString = (args.length > 0 && args[0] == true);
    bool descending = (args.length > 1 && args[1] == true);
    bool caseInsensitive = (args.length > 2 && args[2] == true);
    int descendingInt = descending ? -1 : 1;
    int sortAsString(Object val1, Object val2) {
      String str1 = dgToString(val1, '');
      String str2 = dgToString(val2, '');
      return str1.compareTo(str2) * descendingInt;
    }
    int sortAsStringI(Object val1, Object val2) {
      String str1 = dgToString(val1, '');
      String str2 = dgToString(val2, '');
      int t0 = str1.toLowerCase().compareTo(str2.toLowerCase());
      if (t0 == 0 && str1 != str2) {
        return str1.compareTo(str2) * descendingInt;
      }
      return t0 * descendingInt;
    }
    int sortAsNumber(Object val1, Object val2) {
      return dgToInt(val1, 0).compareTo(dgToInt(val2, 0)) * descendingInt;
    }
    if (sortString) {
      if (caseInsensitive) {
        this_.sort(sortAsStringI);
      } else {
        this_.sort(sortAsString);
      }
    } else {
      this_.sort(sortAsNumber);
    }
    return this_;
  }
  return null;
}
Object _listConcat(Object this_, List args) {
  if (this_ is List) {
    List newList = this_.toList();
    for (Object arg in args) {
      if (arg is Iterable) {
        newList.addAll(arg);
      }
    }
    return newList;
  }
  return null;
}
Object _listEncodeBase64(Object this_, List args) {
  if (this_ is List) {
    return CryptoUtils.bytesToBase64(this_);
  }
  return null;
}
class JsMath implements IDGMap {
  const JsMath();
  Object getValue(String name_A) {
    return mathMap[name_A];
  }
  void setValue(String name_A, Object val) {
    throw "can't change readonly object";
  }
  void updateValue(String name_A, Object val) {
    throw "can't change readonly object";
  }
  void setBinding(String name_A, String val) {
    throw "can't change readonly object";
  }
}
const Map<String, Object> mathMap = const{'PI': PI, 'E': E, 'LN2': LN2, 'LN10': LN10, 'LOG2E': LOG2E, 'LOG10E': LOG10E, 'SQRT2': SQRT2, 'SQRT1_2': SQRT1_2, 'abs': _mathAbs, 'min': _mathMin, 'max': _mathMax, 'sin': _mathSin, 'cos': _mathCos, 'tan': _mathTan, 'asin': _mathASin, 'acos': _mathACos, 'atan': _mathATan, 'atan2': _mathATan2, 'ceil': _mathCeil, 'floor': _mathFloor, 'round': _mathRound, 'exp': _mathExp, 'log': _mathLog, 'sqrt': _mathSqrt, 'pow': _mathPow, 'random': _mathRandom};
Object _mathAbs(Object this_, List args) {
  Object val = args[0];
  if (val is num) {
    return val.abs();
  }
  return double.NAN;
}
Object _mathMax(Object this_, List args) {
  num rslt = double.NEGATIVE_INFINITY;
  for (Object val in args) {
    if (val is num && val > rslt) {
      rslt = val;
    }
  }
  if (rslt.isFinite) {
    return rslt;
  }
  return double.NAN;
}
Object _mathMin(Object this_, List args) {
  num rslt = double.INFINITY;
  for (Object val in args) {
    if (val is num && val < rslt) {
      rslt = val;
    }
  }
  if (rslt.isFinite) {
    return rslt;
  }
  return double.NAN;
}
Object _mathSin(Object this_, List args) {
  Object val = args[0];
  if (val is num) {
    return sin(val);
  }
  return double.NAN;
}
Object _mathCos(Object this_, List args) {
  Object val = args[0];
  if (val is num) {
    return cos(val);
  }
  return double.NAN;
}
Object _mathTan(Object this_, List args) {
  Object val = args[0];
  if (val is num) {
    return tan(val);
  }
  return double.NAN;
}
Object _mathASin(Object this_, List args) {
  Object val = args[0];
  if (val is num) {
    return asin(val);
  }
  return double.NAN;
}
Object _mathACos(Object this_, List args) {
  Object val = args[0];
  if (val is num) {
    return acos(val);
  }
  return double.NAN;
}
Object _mathATan(Object this_, List args) {
  Object val = args[0];
  if (val is num) {
    return atan(val);
  }
  return double.NAN;
}
Object _mathATan2(Object this_, List args) {
  Object val1 = args[0];
  Object val2 = args[1];
  if (val1 is num && val2 is num) {
    return atan2(val1, val2);
  }
  return double.NAN;
}
Object _mathCeil(Object this_, List args) {
  Object val = args[0];
  if (val is num) {
    return val.ceil();
  }
  return double.NAN;
}
Object _mathFloor(Object this_, List args) {
  Object val = args[0];
  if (val is num) {
    return val.floor();
  }
  return double.NAN;
}
Object _mathRound(Object this_, List args) {
  Object val = args[0];
  if (val is num) {
    return val.round();
  }
  return double.NAN;
}
Object _mathExp(Object this_, List args) {
  Object val = args[0];
  if (val is num) {
    return exp(val);
  }
  return double.NAN;
}
Object _mathLog(Object this_, List args) {
  Object val = args[0];
  if (val is num) {
    return log(val);
  }
  return double.NAN;
}
Object _mathSqrt(Object this_, List args) {
  Object val = args[0];
  if (val is num) {
    return _A.sqrt(val);
  }
  return double.NAN;
}
Object _mathPow(Object this_, List args) {
  Object val1 = args[0];
  Object val2 = args[1];
  if (val1 is num && val2 is num) {
    return pow(val1, val2);
  }
  return double.NAN;
}
Random _rng = new Random();
Object _mathRandom(Object this_, List args) {
  return _rng.nextDouble();
}
abstract class NodeVisitor<T> {}
class BaseVisitor<T> implements NodeVisitor<T> {
  T visitNode(Node node) {
    node.visitChildren(this);
    return null;
  }
  T visitProgram(Program node) => visitNode(node);
  T visitStatement(Statement node) => visitNode(node);
  T visitLoop(Loop node) => visitStatement(node);
  T visitJump(Statement node) => visitStatement(node);
  T visitBlock(Block node) => visitStatement(node);
  T visitExpressionStatement(ExpressionStatement node) => visitStatement(node);
  T visitEmptyStatement(EmptyStatement node) => visitStatement(node);
  T visitIf(If node) => visitStatement(node);
  T visitFor(For node) => visitLoop(node);
  T visitForIn(ForIn node) => visitLoop(node);
  T visitWhile(While node) => visitLoop(node);
  T visitDo(Do node) => visitLoop(node);
  T visitContinue(Continue node) => visitJump(node);
  T visitBreak(Break node) => visitJump(node);
  T visitReturn(Return node) => visitJump(node);
  T visitSwitch(Switch node) => visitStatement(node);
  T visitFunctionDeclaration(FunctionDeclaration node) => visitStatement(node);
  T visitCase(Case node) => visitNode(node);
  T visitDefault(Default node) => visitNode(node);
  T visitExpression(Expression node) => visitNode(node);
  T visitVariableReference(VariableReference node) => visitExpression(node);
  T visitVariableDeclarationList(VariableDeclarationList node) => visitExpression(node);
  T visitSequence(Sequence node) => visitExpression(node);
  T visitAssignment(Assignment node) => visitExpression(node);
  T visitTildeAssignment(TildeAssignment node) => visitExpression(node);
  T visitVariableInitialization(VariableInitialization node) {
    if (node.value != null) {
      return visitAssignment(node);
    } else {
      return visitExpression(node);
    }
  }
  T visitConditional(Conditional node) => visitExpression(node);
  T visitNew(New node) => visitExpression(node);
  T visitCall(Call node) => visitExpression(node);
  T visitBinary(Binary node) => visitCall(node);
  T visitPrefix(Prefix node) => visitExpression(node);
  T visitPostfix(Postfix node) => visitExpression(node);
  T visitPropertyAccess(PropertyAccess node) => visitExpression(node);
  T visitVariableUse(VariableUse node) => visitVariableReference(node);
  T visitVariableDeclaration(VariableDeclaration node) => visitVariableReference(node);
  T visitParameter(Parameter node) => visitVariableDeclaration(node);
  T visitThis(This node) => visitParameter(node);
  T visitNamedFunction(NamedFunction node) => visitExpression(node);
  T visitFun(Fun node) => visitExpression(node);
  T visitLiteral(Literal node) => visitExpression(node);
  T visitLiteralBool(LiteralBool node) => visitLiteral(node);
  T visitLiteralString(LiteralString node) => visitLiteral(node);
  T visitLiteralNumber(LiteralNumber node) => visitLiteral(node);
  T visitLiteralNull(LiteralNull node) => visitLiteral(node);
  T visitLiteralUndefined(LiteralUndefined node) => visitLiteral(node);
  T visitArrayInitializer(ArrayInitializer node) => visitExpression(node);
  T visitArrayElement(ArrayElement node) => visitNode(node);
  T visitObjectInitializer(ObjectInitializer node) => visitExpression(node);
  T visitProperty(Property node) => visitNode(node);
  T visitRegExpLiteral(RegExpLiteral node) => visitExpression(node);
}
abstract class Node {
  accept(NodeVisitor visitor);
  void visitChildren(NodeVisitor visitor);
  Object run(Scope scope);
}
class Program extends Node {
  final List<Statement> body;
  Program(this.body);
  Statement currentStatement;
  accept(NodeVisitor visitor) => visitor.visitProgram(this);
  void visitChildren(NodeVisitor visitor) {
    for (Statement statement in body) statement.accept(visitor);
  }
  Object run(Scope scope) {
    return null;
  }
  Object runProgram(Map inputs, IDGMap thisObj) {
    Scope programScope = new ProgramScope(this, null, inputs, thisObj);
    Object rslt;
    for (Statement statement in body) {
      currentStatement = statement;
      rslt = statement.run(programScope);
      if (rslt is ReturnValue) {
        currentStatement = null;
        return rslt.value;
      }
    }
    currentStatement = null;
    return rslt;
  }
}
abstract class Statement extends Node {
  String label;
}
class Block extends Statement {
  final List<Statement> statements;
  Block(this.statements);
  accept(NodeVisitor visitor) => visitor.visitBlock(this);
  void visitChildren(NodeVisitor visitor) {
    for (Statement statement in statements) statement.accept(visitor);
  }
  Object run(Scope scope) {
    Object rslt;
    for (Statement statement in statements) {
      rslt = statement.run(scope);
      if (rslt is InteruptStatement) {
        if (label != null && rslt is Break && rslt.targetLabel == label) {
          return null;
        }
        return rslt;
      }
    }
    return null;
  }
}
class ExpressionStatement extends Statement {
  final Expression expression;
  ExpressionStatement(this.expression);
  accept(NodeVisitor visitor) => visitor.visitExpressionStatement(this);
  void visitChildren(NodeVisitor visitor) {
    expression.accept(visitor);
  }
  Object run(Scope scope) {
    return expression.run(scope);
  }
}
class EmptyStatement extends Statement {
  EmptyStatement();
  accept(NodeVisitor visitor) => visitor.visitEmptyStatement(this);
  void visitChildren(NodeVisitor visitor) {}
  Object run(Scope scope) {
    return null;
  }
}
class If extends Statement {
  final Expression condition;
  final Node then;
  final Node otherwise;
  If(this.condition, this.then, this.otherwise);
  accept(NodeVisitor visitor) => visitor.visitIf(this);
  void visitChildren(NodeVisitor visitor) {
    condition.accept(visitor);
    then.accept(visitor);
    otherwise.accept(visitor);
  }
  Object run(Scope scope) {
    if (dgToBoolJs(condition.run(scope))) {
      return then.run(scope);
    } else {
      return otherwise.run(scope);
    }
  }
}
abstract class Loop extends Statement {
  final Statement body;
  Loop(this.body);
}
class For extends Loop {
  final Expression init;
  final Expression condition;
  final Expression update;
  For(this.init, this.condition, this.update, Statement body) : super(body);
  accept(NodeVisitor visitor) => visitor.visitFor(this);
  void visitChildren(NodeVisitor visitor) {
    if (init != null) init.accept(visitor);
    if (condition != null) condition.accept(visitor);
    if (update != null) update.accept(visitor);
    body.accept(visitor);
  }
  Object run(Scope scope) {
    Object rslt;
    for (init.run(scope); dgToBoolJs(condition.run(scope)); update.run(scope)) {
      rslt = body.run(scope);
      if (rslt is InteruptStatement) {
        if (rslt is Break && (rslt.targetLabel == null || rslt.targetLabel == label)) {
          break;
        }
        if (rslt is Continue && (rslt.targetLabel == null || rslt.targetLabel == label)) {
          continue;
        }
        return rslt;
      }
    }
    return null;
  }
}
class ForIn extends Loop {
  final Expression leftHandSide;
  final Expression object;
  ForIn(this.leftHandSide, this.object, Statement body) : super(body);
  accept(NodeVisitor visitor) => visitor.visitForIn(this);
  void visitChildren(NodeVisitor visitor) {
    leftHandSide.accept(visitor);
    object.accept(visitor);
    body.accept(visitor);
  }
  Object run(Scope scope) {
    Object map_A = object.run(scope);
    LeftValue left_A = leftHandSide.getLeftValue(scope);
    if (leftHandSide is VariableDeclarationList) {
      left_A = (leftHandSide as VariableDeclarationList).declarations.first.declaration.getLeftValue(scope);
    }
    if (map_A is Map && left_A != null) {
      Object rslt;
      for (String key_A in map_A.keys) {
        left_A.assign(key_A);
        rslt = body.run(scope);
        if (rslt is InteruptStatement) {
          if (rslt is Break && (rslt.targetLabel == null || rslt.targetLabel == label)) {
            break;
          }
          if (rslt is Continue && (rslt.targetLabel == null || rslt.targetLabel == label)) {
            continue;
          }
          return rslt;
        }
      }
    } else if (map_A is List && left_A != null) {
      Object rslt;
      for (int i = 0; i < map_A.length; ++i) {
        left_A.assign(i);
        rslt = body.run(scope);
        if (rslt is InteruptStatement) {
          if (rslt is Break && (rslt.targetLabel == null || rslt.targetLabel == label)) {
            break;
          }
          if (rslt is Continue && (rslt.targetLabel == null || rslt.targetLabel == label)) {
            continue;
          }
          return rslt;
        }
      }
    } else if (map_A is IDGArray && left_A != null) {
      Object rslt;
      int len = map_A.getLength();
      for (int i = 0; i < len; ++i) {
        left_A.assign(i);
        rslt = body.run(scope);
        if (rslt is InteruptStatement) {
          if (rslt is Break && (rslt.targetLabel == null || rslt.targetLabel == label)) {
            break;
          }
          if (rslt is Continue && (rslt.targetLabel == null || rslt.targetLabel == label)) {
            continue;
          }
          return rslt;
        }
      }
    }
    return null;
  }
}
class While extends Loop {
  final Node condition;
  While(this.condition, Statement body) : super(body);
  accept(NodeVisitor visitor) => visitor.visitWhile(this);
  void visitChildren(NodeVisitor visitor) {
    condition.accept(visitor);
    body.accept(visitor);
  }
  Object run(Scope scope) {
    Object rslt;
    while (dgToBoolJs(condition.run(scope))) {
      rslt = body.run(scope);
      if (rslt is InteruptStatement) {
        if (rslt is Break && (rslt.targetLabel == null || rslt.targetLabel == label)) {
          break;
        }
        if (rslt is Continue && (rslt.targetLabel == null || rslt.targetLabel == label)) {
          continue;
        }
        return rslt;
      }
    }
    return null;
  }
}
class Do extends Loop {
  final Expression condition;
  Do(Statement body, this.condition) : super(body);
  accept(NodeVisitor visitor) => visitor.visitDo(this);
  void visitChildren(NodeVisitor visitor) {
    body.accept(visitor);
    condition.accept(visitor);
  }
  Object run(Scope scope) {
    Object rslt;
    do {
      rslt = body.run(scope);
      if (rslt is InteruptStatement) {
        if (rslt is Break && (rslt.targetLabel == null || rslt.targetLabel == label)) {
          break;
        }
        if (rslt is Continue && (rslt.targetLabel == null || rslt.targetLabel == label)) {
          continue;
        }
        return rslt;
      }
    } while (dgToBoolJs(condition.run(scope)));
    return null;
  }
}
abstract class InteruptStatement extends Statement {
  final String targetLabel;
  InteruptStatement(this.targetLabel);
  void visitChildren(NodeVisitor visitor) {}
}
class Continue extends InteruptStatement {
  Continue(targetLabel) : super(targetLabel);
  accept(NodeVisitor visitor) => visitor.visitContinue(this);
  Object run(Scope scope) {
    return this;
  }
}
class Break extends InteruptStatement {
  Break(targetLabel) : super(targetLabel);
  accept(NodeVisitor visitor) => visitor.visitBreak(this);
  Object run(Scope scope) {
    return this;
  }
}
class ReturnValue extends InteruptStatement {
  final Object value;
  ReturnValue(this.value) : super(null);
  accept(NodeVisitor visitor) {}
  Object run(Scope scope) {
    return value;
  }
}
class Return extends Statement {
  final Expression value;
  Return([this.value = null]);
  accept(NodeVisitor visitor) => visitor.visitReturn(this);
  void visitChildren(NodeVisitor visitor) {
    if (value != null) value.accept(visitor);
  }
  Object run(Scope scope) {
    return new ReturnValue(value.run(scope));
  }
}
class Switch extends Statement {
  final Expression key;
  final List<SwitchClause> cases;
  Switch(this.key, this.cases);
  accept(NodeVisitor visitor) => visitor.visitSwitch(this);
  void visitChildren(NodeVisitor visitor) {
    key.accept(visitor);
    for (SwitchClause clause in cases) clause.accept(visitor);
  }
  Object run(Scope scope) {
    Object val = key.run(scope);
    for (SwitchClause switchcase in cases) {
      if (switchcase is! Case || dgDynamicEqual(val, (switchcase as Case).expression.run(scope))) {
        Object rslt = switchcase.body.run(scope);
        if (rslt is InteruptStatement) {
          if (rslt is Break && (rslt.targetLabel == null || rslt.targetLabel == label)) {
            break;
          }
          return rslt;
        }
      }
    }
    return null;
  }
}
abstract class SwitchClause extends Node {
  final Block body;
  SwitchClause(this.body);
}
class Case extends SwitchClause {
  final Expression expression;
  Case(this.expression, Block body) : super(body);
  accept(NodeVisitor visitor) => visitor.visitCase(this);
  void visitChildren(NodeVisitor visitor) {
    expression.accept(visitor);
    body.accept(visitor);
  }
  Object run(Scope scope) {
    return body.run(scope);
  }
}
class Default extends SwitchClause {
  Default(Block body) : super(body);
  accept(NodeVisitor visitor) => visitor.visitDefault(this);
  void visitChildren(NodeVisitor visitor) {
    body.accept(visitor);
  }
  Object run(Scope scope) {
    return body.run(scope);
  }
}
class FunctionDeclaration extends Statement {
  final VariableDeclaration name;
  final Fun function;
  FunctionDeclaration(this.name, this.function);
  accept(NodeVisitor visitor) => visitor.visitFunctionDeclaration(this);
  void visitChildren(NodeVisitor visitor) {
    name.accept(visitor);
    function.accept(visitor);
  }
  Object run(Scope scope) {
    var instance = function.run(scope);
    scope.updateValue(name.name, instance);
    return instance;
  }
}
abstract class Expression extends Node {
  LeftValue getLeftValue(Scope scope) {
    return null;
  }
}
class VariableDeclarationList extends Expression {
  final List<VariableInitialization> declarations;
  VariableDeclarationList(this.declarations);
  accept(NodeVisitor visitor) => visitor.visitVariableDeclarationList(this);
  void visitChildren(NodeVisitor visitor) {
    for (VariableInitialization declaration in declarations) {
      declaration.accept(visitor);
    }
  }
  Object run(Scope scope) {
    for (var declarns in declarations) {
      LeftValue lval = declarns.leftHandSide.getLeftValue(scope);
      if (lval != null) {
        if (declarns.value != null) {
          lval.assign(declarns.value.run(scope));
        } else {
          lval.assign(null);
        }
      }
    }
    return null;
  }
}
class Sequence extends Expression {
  final List<Expression> expressions;
  Sequence(this.expressions);
  accept(NodeVisitor visitor) => visitor.visitSequence(this);
  void visitChildren(NodeVisitor visitor) {
    for (Expression expr in expressions) expr.accept(visitor);
  }
  Object run(Scope scope) {
    Object rslt;
    for (Statement statement in expressions) {
      rslt = statement.run(scope);
    }
    return rslt;
  }
}
class Assignment extends Expression {
  final Expression leftHandSide;
  final Operator operator_A;
  final Expression value;
  Assignment(this.leftHandSide, this.value) : operator_A = null;
  Assignment.compound(this.leftHandSide, String op_A, this.value) : operator_A = new Operator(op_A);
  accept(NodeVisitor visitor) => visitor.visitAssignment(this);
  void visitChildren(NodeVisitor visitor) {
    leftHandSide.accept(visitor);
    if (value != null) value.accept(visitor);
  }
  Object run(Scope scope) {
    LeftValue left_A = leftHandSide.getLeftValue(scope);
    if (left_A != null) {
      Object val = value.run(scope);
      if (operator_A != null) {
        val = operator_A.runOp(left_A.getValue(), val);
      }
      left_A.assign(val);
      return val;
    }
    return null;
  }
}
class TildeAssignment extends Expression {
  final Expression leftHandSide;
  final Expression value;
  TildeAssignment(this.leftHandSide, this.value);
  accept(NodeVisitor visitor) => visitor.visitTildeAssignment(this);
  void visitChildren(NodeVisitor visitor) {
    leftHandSide.accept(visitor);
    if (value != null) value.accept(visitor);
  }
  Object run(Scope scope) {
    LeftValue left_A = leftHandSide.getLeftValue(scope);
    if (left_A != null) {
      Object val = value.run(scope);
      left_A.tildeAssign(val);
      return val;
    }
    return null;
  }
}
class VariableInitialization extends Assignment {
  VariableInitialization(VariableDeclaration declaration_A, Expression value_A) : super(declaration_A, value_A);
  VariableDeclaration get declaration => leftHandSide;
  accept(NodeVisitor visitor) => visitor.visitVariableInitialization(this);
}
class Conditional extends Expression {
  final Expression condition;
  final Expression then;
  final Expression otherwise;
  Conditional(this.condition, this.then, this.otherwise);
  accept(NodeVisitor visitor) => visitor.visitConditional(this);
  void visitChildren(NodeVisitor visitor) {
    condition.accept(visitor);
    then.accept(visitor);
    otherwise.accept(visitor);
  }
  Object run(Scope scope) {
    if (dgToBoolJs(condition.run(scope))) {
      return then.run(scope);
    } else {
      return otherwise.run(scope);
    }
  }
}
class Call extends Expression {
  Expression target;
  List<Expression> arguments;
  Call(this.target, this.arguments);
  accept(NodeVisitor visitor) => visitor.visitCall(this);
  void visitChildren(NodeVisitor visitor) {
    target.accept(visitor);
    for (Expression arg in arguments) arg.accept(visitor);
  }
  Object run(Scope scope) {
    LeftValue leftVal = target.getLeftValue(scope);
    Object fun;
    if (leftVal != null) {
      fun = leftVal.getValue();
    } else {
      fun = target.run(scope);
    }
    if (fun is ScriptFunction) {
      int len = arguments.length;
      List args = new List(len);
      for (int i = 0; i < len; ++i) {
        args[i] = arguments[i].run(scope);
      }
      if (leftVal != null) {
        return fun(leftVal.getTarget(), args);
      }
      return fun(null, args);
    } else {
      throw 'invalid call to ${target}';
    }
  }
}
class New extends Call {
  New(Expression cls, List<Expression> arguments) : super(cls, arguments);
  accept(NodeVisitor visitor) => visitor.visitNew(this);
  Object run(Scope scope) {
    LeftValue leftVal = target.getLeftValue(scope);
    Object fun;
    if (leftVal != null) {
      fun = leftVal.getValue();
    } else {
      fun = target.run(scope);
    }
    if (fun is JsNativeClass) {
      int len = arguments.length;
      List args = new List(len);
      for (int i = 0; i < len; ++i) {
        args[i] = arguments[i].run(scope);
      }
      return fun.constructor(args);
    }
    if (fun is ScriptFunction) {
      int len = arguments.length;
      List args = new List(len);
      for (int i = 0; i < len; ++i) {
        args[i] = arguments[i].run(scope);
      }
      Map newInstance = new DGHashMap();
      fun(newInstance, args);
      return newInstance;
    } else {
      throw 'invalid call to ${target}';
    }
  }
}
class Binary extends Call {
  Binary(String op_A, Expression left_A, Expression right_A) : super(null, <Expression>[left_A, right_A]), operator_A = new Operator(op_A);
  Operator operator_A;
  Expression get left => arguments[0];
  Expression get right => arguments[1];
  accept(NodeVisitor visitor) => visitor.visitBinary(this);
  void visitChildren(NodeVisitor visitor) {
    for (Expression arg in arguments) arg.accept(visitor);
  }
  Object run(Scope scope) {
    return operator_A.runOpExpression(scope, left, right);
  }
}
abstract class VariableReference extends Expression {
  final String name;
  Node scopeNode;
  VariableReference(this.name);
  accept(NodeVisitor visitor);
  void visitChildren(NodeVisitor visitor) {}
  Object run(Scope scope) {
    while (scope != null && scope.node != scopeNode) {
      scope = scope.parent;
    }
    if (scope != null) {
      return scope.getValue(name);
    }
    return null;
  }
  LeftValue getLeftValue(Scope scope) {
    while (scope != null && scope.node != scopeNode) {
      scope = scope.parent;
    }
    if (scope != null) {
      return new LeftValueDGMap(scope, name);
    }
    return null;
  }
}
class VariableUse extends VariableReference {
  VariableUse(String name_A) : super(name_A);
  accept(NodeVisitor visitor) => visitor.visitVariableUse(this);
}
class VariableDeclaration extends VariableReference {
  VariableDeclaration(String name_A) : super(name_A);
  accept(NodeVisitor visitor) => visitor.visitVariableDeclaration(this);
}
class Parameter extends VariableDeclaration {
  Parameter(String id) : super(id);
  accept(NodeVisitor visitor) => visitor.visitParameter(this);
}
class This extends Parameter {
  This() : super("this");
  accept(NodeVisitor visitor) => visitor.visitThis(this);
}
class NamedFunction extends Expression {
  final VariableDeclaration name;
  final Fun function;
  NamedFunction(this.name, this.function);
  accept(NodeVisitor visitor) => visitor.visitNamedFunction(this);
  void visitChildren(NodeVisitor visitor) {
    name.accept(visitor);
    function.accept(visitor);
  }
  Object run(Scope scope) {
    var funinst = function.run(scope);
    while (scope != null && scope.node != name.scopeNode) {
      scope = scope.parent;
    }
    scope.updateValue(name.name, funinst);
    return funinst;
  }
}
class Fun extends Expression {
  final List<Parameter> params;
  final Block body;
  Fun(this.params, this.body);
  accept(NodeVisitor visitor) => visitor.visitFun(this);
  void visitChildren(NodeVisitor visitor) {
    for (Parameter param in params) param.accept(visitor);
    body.accept(visitor);
  }
  Object run(Scope scope) {
    return new FunctionInstance(this, scope);
  }
  Object runFun(Scope scope, List args, Object this_) {
    Scope funScope = new FunScope(this, scope);
    int len = args.length;
    if (params.length < args.length) {
      len = params.length;
    }
    for (int i = 0; i < len; ++i) {
      funScope.updateValue(params[i].name, args[i]);
    }
    funScope.updateValue('this', this_);
    Object rslt = body.run(funScope);
    if (rslt is ReturnValue) {
      return rslt.value;
    }
    return null;
  }
}
class PropertyAccess extends Expression {
  final Expression receiver;
  final Expression selector;
  PropertyAccess(this.receiver, this.selector);
  accept(NodeVisitor visitor) => visitor.visitPropertyAccess(this);
  void visitChildren(NodeVisitor visitor) {
    receiver.accept(visitor);
    selector.accept(visitor);
  }
  LeftValue getLeftValue(Scope scope) {
    return LeftValue.create(receiver.run(scope), selector.run(scope));
  }
  Object run(Scope scope) {
    return accessProperty(receiver.run(scope), selector.run(scope));
  }
}
abstract class Literal extends Expression {
  void visitChildren(NodeVisitor visitor) {}
}
class LiteralBool extends Literal {
  final bool value;
  LiteralBool(this.value);
  accept(NodeVisitor visitor) => visitor.visitLiteralBool(this);
  Object run(Scope scope) {
    return value;
  }
}
class LiteralUndefined extends Literal {
  LiteralUndefined();
  accept(NodeVisitor visitor) => visitor.visitLiteralUndefined(this);
  Object run(Scope scope) {
    return null;
  }
}
class LiteralNull extends Literal {
  LiteralNull();
  accept(NodeVisitor visitor) => visitor.visitLiteralNull(this);
  Object run(Scope scope) {
    return null;
  }
}
class LiteralString extends Literal {
  static RegExp regexp = new RegExp(r'\\(u....|.|\n)');
  static String replaceReg(Match m) {
    String s = m.group(0);
    if (s.length == 6) {
      int code = int.parse(s.substring(2), radix: 16, onError: dgToIntError_1);
      if (code > -1) {
        return new String.fromCharCode(code);
      }
      return '';
    }
    int code = s.codeUnitAt(1);
    if (code == Lexer.$n) return '\n';
    if (code == Lexer.$r) return '\r';
    if (code == Lexer.$b) return '\b';
    if (code == Lexer.$t) return '\t';
    if (code == Lexer.$f) return '\f';
    if (code == Lexer.$NEWLINE) return '';
    return s.substring(1, 2);
  }
  final String value;
  String strVal;
  LiteralString(this.value, [this.strVal = null]) {
    if (strVal == null) {
      strVal = value.substring(1, value.length - 1).replaceAllMapped(regexp, replaceReg);
    }
  }
  accept(NodeVisitor visitor) => visitor.visitLiteralString(this);
  Object run(Scope scope) {
    return strVal;
  }
}
class LiteralNumber extends Literal {
  final String value;
  num numVal;
  LiteralNumber(this.value) {
    numVal = dgToNumber(value);
  }
  Object run(Scope scope) {
    return numVal;
  }
  accept(NodeVisitor visitor) => visitor.visitLiteralNumber(this);
}
class ArrayInitializer extends Expression {
  final int length;
  final List<ArrayElement> elements;
  ArrayInitializer(this.length, this.elements);
  accept(NodeVisitor visitor) => visitor.visitArrayInitializer(this);
  void visitChildren(NodeVisitor visitor) {
    for (ArrayElement element_A in elements) element_A.accept(visitor);
  }
  Object run(Scope scope) {
    List rslt = [];
    for (ArrayElement element_A in elements) {
      rslt.add(element_A.value.run(scope));
    }
    return rslt;
  }
}
class ArrayElement extends Node {
  int index;
  Expression value;
  ArrayElement(this.index, this.value);
  accept(NodeVisitor visitor) => visitor.visitArrayElement(this);
  void visitChildren(NodeVisitor visitor) {
    value.accept(visitor);
  }
  Object run(Scope scope) {
    return value.run(scope);
  }
}
class ObjectInitializer extends Expression {
  List<Property> properties;
  ObjectInitializer(this.properties);
  accept(NodeVisitor visitor) => visitor.visitObjectInitializer(this);
  void visitChildren(NodeVisitor visitor) {
    for (Property init in properties) init.accept(visitor);
  }
  Object run(Scope scope) {
    Map rslt = new DGHashMap<String, Object>();
    for (Property prop in properties) {
      if (prop.name is LiteralString) {
        rslt[(prop.name as LiteralString).strVal] = prop.value.run(scope);
      }
    }
    return rslt;
  }
}
class Property extends Node {
  Literal name;
  Expression value;
  Property(this.name, this.value);
  accept(NodeVisitor visitor) => visitor.visitProperty(this);
  void visitChildren(NodeVisitor visitor) {
    name.accept(visitor);
    value.accept(visitor);
  }
  Object run(Scope scope) {
    return value.run(scope);
  }
}
class RegExpLiteral extends Expression {
  String pattern;
  JsRegExp reg;
  RegExpLiteral(this.pattern) {
    reg = new JsRegExp(pattern);
  }
  accept(NodeVisitor visitor) => visitor.visitRegExpLiteral(this);
  void visitChildren(NodeVisitor visitor) {}
  Object run(Scope scope) {
    return reg;
  }
}
abstract class Operator {
  static const Map<String, Operator> dict = const{'+': const OpAdd(), '-': const OpMinus(), '*': const OpMutiply(), '/': const OpDivide(), '%': const OpMod(), '<<': const OpShiftLeft(), '>>': const OpShiftRight(), '<': const OpLT(), '>': const OpGT(), '<=': const OpLTE(), '>=': const OpGTE(), 'in': const OpIn(), '==': const OpEqual(), '===': const OpStrictEqual(), '!=': const OpNotEqual(), '!==': const OpNotStrictEqual(), '&&': const OpLogicalAnd(), '||': const OpLogicalOr(), '&': const OpBitAnd(), '|': const OpBitOr(), '^': const OpBitXor()};
  factory Operator(String op) {
    return dict[op];
  }
  final String name;
  const Operator.__A(this.name);
  Object runOpExpression(Scope scope, Expression left_A, Expression right_A) {
    return runOp(left_A.run(scope), right_A.run(scope));
  }
  Object runOp(Object leftVal, Object rightVal) {
    return null;
  }
}
class OpAdd extends Operator {
  const OpAdd() : super.__A('+');
  Object runOp(Object leftVal, Object rightVal) {
    if (leftVal is num) {
      return leftVal + dgToNumber(rightVal);
    }
    if (leftVal is String) {
      return leftVal + dgToString(rightVal, '');
    }
    return null;
  }
}
class OpMinus extends Operator {
  const OpMinus() : super.__A('-');
  Object runOp(Object leftVal, Object rightVal) {
    return dgToNumber(leftVal) - dgToNumber(rightVal);
  }
}
class OpMutiply extends Operator {
  const OpMutiply() : super.__A('*');
  Object runOp(Object leftVal, Object rightVal) {
    return dgToNumber(leftVal) * dgToNumber(rightVal);
  }
}
class OpDivide extends Operator {
  const OpDivide() : super.__A('/');
  Object runOp(Object leftVal, Object rightVal) {
    return dgToNumber(leftVal) / dgToNumber(rightVal);
  }
}
class OpMod extends Operator {
  const OpMod() : super.__A('%');
  Object runOp(Object leftVal, Object rightVal) {
    return dgToNumber(leftVal).remainder(dgToNumber(rightVal));
  }
}
class OpShiftLeft extends Operator {
  const OpShiftLeft() : super.__A('<<');
  Object runOp(Object leftVal, Object rightVal) {
    return dgToInt(leftVal, 0) << dgToInt(rightVal, 0);
  }
}
class OpShiftRight extends Operator {
  const OpShiftRight() : super.__A('>>');
  Object runOp(Object leftVal, Object rightVal) {
    return dgToInt(leftVal, 0) >> dgToInt(rightVal, 0);
  }
}
class OpLT extends Operator {
  const OpLT() : super.__A('<');
  Object runOp(Object leftVal, Object rightVal) {
    if (leftVal is String && rightVal is String) {
      return leftVal.compareTo(rightVal) < 0;
    }
    return dgToNumber(leftVal) < dgToNumber(rightVal);
  }
}
class OpGT extends Operator {
  const OpGT() : super.__A('>');
  Object runOp(Object leftVal, Object rightVal) {
    if (leftVal is String && rightVal is String) {
      return leftVal.compareTo(rightVal) > 0;
    }
    return dgToNumber(leftVal) > dgToNumber(rightVal);
  }
}
class OpLTE extends Operator {
  const OpLTE() : super.__A('<=');
  Object runOp(Object leftVal, Object rightVal) {
    if (leftVal is String && rightVal is String) {
      return leftVal.compareTo(rightVal) <= 0;
    }
    return dgToNumber(leftVal) <= dgToNumber(rightVal);
  }
}
class OpGTE extends Operator {
  const OpGTE() : super.__A('>=');
  Object runOp(Object leftVal, Object rightVal) {
    if (leftVal is String && rightVal is String) {
      return leftVal.compareTo(rightVal) >= 0;
    }
    return dgToNumber(leftVal) >= dgToNumber(rightVal);
  }
}
class OpIn extends Operator {
  const OpIn() : super.__A('in');
  Object runOp(Object leftVal, Object rightVal) {
    if (rightVal is Map) {
      return rightVal.containsKey(leftVal.toString());
    } else if (rightVal is Scope) {
      return rightVal.contains(leftVal.toString());
    } else if (rightVal is List && leftVal is num) {
      int idx = leftVal.toInt();
      if (idx >= 0 && idx < rightVal.length) {
        return true;
      }
    }
    return false;
  }
}
class OpEqual extends Operator {
  const OpEqual() : super.__A('==');
  Object runOp(Object leftVal, Object rightVal) {
    return dgDynamicEqual(leftVal, rightVal);
  }
}
class OpStrictEqual extends Operator {
  const OpStrictEqual() : super.__A('===');
  Object runOp(Object leftVal, Object rightVal) {
    return leftVal == rightVal;
  }
}
class OpNotEqual extends Operator {
  const OpNotEqual() : super.__A('!=');
  Object runOp(Object leftVal, Object rightVal) {
    return !dgDynamicEqual(leftVal, rightVal);
  }
}
class OpNotStrictEqual extends Operator {
  const OpNotStrictEqual() : super.__A('!==');
  Object runOp(Object leftVal, Object rightVal) {
    return leftVal == rightVal;
  }
}
class OpLogicalAnd extends Operator {
  const OpLogicalAnd() : super.__A('&&');
  Object runOpExpression(Scope scope, Expression left_A, Expression right_A) {
    Object leftVal = left_A.run(scope);
    if (dgToBoolJs(leftVal)) {
      return right_A.run(scope);
    }
    return leftVal;
  }
  Object runOp(Object leftVal, Object rightVal) {
    if (dgToBoolJs(leftVal)) {
      return rightVal;
    }
    return leftVal;
  }
}
class OpLogicalOr extends Operator {
  const OpLogicalOr() : super.__A('||');
  Object runOpExpression(Scope scope, Expression left_A, Expression right_A) {
    Object leftVal = left_A.run(scope);
    if (dgToBoolJs(leftVal)) {
      return leftVal;
    }
    return right_A.run(scope);
  }
  Object runOp(Object leftVal, Object rightVal) {
    if (dgToBoolJs(leftVal)) {
      return leftVal;
    }
    return rightVal;
  }
}
class OpBitAnd extends Operator {
  const OpBitAnd() : super.__A('&');
  Object runOp(Object leftVal, Object rightVal) {
    return dgToInt(leftVal, 0) & dgToInt(rightVal, 0);
  }
}
class OpBitOr extends Operator {
  const OpBitOr() : super.__A('&');
  Object runOp(Object leftVal, Object rightVal) {
    return dgToInt(leftVal, 0) | dgToInt(rightVal, 0);
  }
}
class OpBitXor extends Operator {
  const OpBitXor() : super.__A('&');
  Object runOp(Object leftVal, Object rightVal) {
    return dgToInt(leftVal, 0) ^ dgToInt(rightVal, 0);
  }
}
class Parser {
  final Lexer lexer;
  List<Token> peekedTokens;
  String previousTokenType = null;
  Parser(this.lexer) : this.peekedTokens = <Token>[];
  void error(String msg, var obj, Token token) {
    throw "${msg}: ${obj}. ${token}";
  }
  void unexpectedToken(Token token) {
    throw "Unexpected token: ${token}";
  }
  Token peekToken() {
    if (peekedTokens.isEmpty) {
      Token nextToken;
      while (true) {
        nextToken = lexer.next();
        if (nextToken.type == "NEW_LINE") {
          previousTokenType = nextToken.type;
        } else {
          break;
        }
      }
      peekedTokens.add(nextToken);
    }
    return peekedTokens.last;
  }
  void pushBackToken(Token token) {
    peekedTokens.add(token);
  }
  String peekTokenType() => peekToken().type;
  bool isAtNewLineToken() => previousTokenType == 'NEW_LINE';
  dynamic consume(String type) {
    Token token = consumeAny();
    if (token.type == type) return token.value;
    print("Expected: ${type}");
    return unexpectedToken(token);
  }
  void consumeStatementSemicolon() {
    String nextTokenType = peekTokenType();
    if (nextTokenType == "SEMICOLON") {
      consumeAny();
    } else if (nextTokenType == "RBRACE" || isAtNewLineToken() || nextTokenType == "EOF") {} else {
      unexpectedToken(peekToken());
    }
  }
  Token consumeAny() {
    Token result_A = peekToken();
    previousTokenType = result_A.type;
    peekedTokens.length--;
    return result_A;
  }
  bool atEof() => peekTokenType() == "EOF";
  Program parseProgram() => new Program(parseStatements());
  List<Statement> parseStatements() {
    List<Statement> result_A = <Statement>[];
    while (!atEof()) {
      Statement stmt = parseStatement();
      result_A.add(stmt);
    }
    return result_A;
  }
  Statement parseStatement() {
    switch (peekTokenType()) {
      case "LBRACE":
        return parseBlock();

      case "SEMICOLON":
        return parseEmptyStatement();

      case "IF":
        return parseIf();

      case "FOR":
        return parseFor();

      case "WHILE":
        return parseWhile();

      case "DO":
        return parseDoWhile();

      case "CONTINUE":
        return parseContinue();

      case "BREAK":
        return parseBreak();

      case "RETURN":
        return parseReturn();

      case "SWITCH":
        return parseSwitch();

      case "FUNCTION":
        return parseFunctionDeclaration();

      case "ID":
        return parseLabeledOrExpression();

      default:
        return parseExpressionStatement();
    }
  }
  Block parseBlock() {
    consume("LBRACE");
    List<Statement> statements = <Statement>[];
    while (peekTokenType() != "RBRACE") {
      statements.add(parseStatement());
    }
    consumeAny();
    return new Block(statements);
  }
  EmptyStatement parseEmptyStatement() {
    consume("SEMICOLON");
    return new EmptyStatement();
  }
  If parseIf() {
    consume("IF");
    consume("LPAREN");
    Expression test_A = parseExpression(false);
    consume("RPAREN");
    Statement then_A = parseStatement();
    Statement otherwise;
    if (peekTokenType() == "ELSE") {
      consumeAny();
      otherwise = parseStatement();
    } else {
      otherwise = new EmptyStatement();
    }
    return new If(test_A, then_A, otherwise);
  }
  Loop parseFor() {
    consume("FOR");
    consume("LPAREN");
    Expression firstPart;
    if (peekTokenType() != "SEMICOLON") {
      firstPart = parseVarExpression(true);
    } else {
      firstPart = new LiteralNull();
    }
    switch (peekTokenType()) {
      case "SEMICOLON":
        return parseForInitTestIncr(firstPart);

      case "IN":
        return parseForIn(firstPart);

      default:
        throw "internal error";
    }
  }
  For parseForInitTestIncr(Expression init) {
    consume("SEMICOLON");
    Expression test_A = null;
    if (peekTokenType() != "SEMICOLON") {
      test_A = parseExpression(false);
    } else {
      test_A = new LiteralBool(true);
    }
    consume("SEMICOLON");
    Expression incr;
    if (peekTokenType() != "RPAREN") {
      incr = parseExpression(false);
    } else {
      incr = new LiteralNull();
    }
    consume("RPAREN");
    Statement body = parseStatement();
    return new For(init, test_A, incr, body);
  }
  ForIn parseForIn(Expression firstPart) {
    Token errorToken = peekToken();
    consume("IN");
    Expression obj = parseExpression(false);
    consume("RPAREN");
    Statement body = parseStatement();
    if (firstPart is VariableDeclarationList) {
      VariableDeclarationList varDecl = firstPart;
      if (varDecl.declarations.length != 1) {
        error("Only one variable allowed in 'for-in' statement", varDecl.declarations[1].declaration.name, errorToken);
      }
      return new ForIn(firstPart, obj, body);
    } else if (firstPart is VariableUse || firstPart is PropertyAccess) {
      return new ForIn(firstPart, obj, body);
    } else {
      print(firstPart);
    }
    error("Bad left-hand side in 'for-in' loop construct", firstPart, errorToken);
    return null;
  }
  While parseWhile() {
    consume("WHILE");
    consume("LPAREN");
    Expression test_A = parseExpression(false);
    consume("RPAREN");
    Statement body = parseStatement();
    return new While(test_A, body);
  }
  Do parseDoWhile() {
    consume("DO");
    Statement body = parseStatement();
    consume("WHILE");
    consume("LPAREN");
    Expression test_A = parseExpression(false);
    consume("RPAREN");
    consumeStatementSemicolon();
    return new Do(body, test_A);
  }
  Continue parseContinue() {
    consume("CONTINUE");
    if (!isAtNewLineToken() && peekTokenType() == "ID") {
      String id = consume("ID");
      consumeStatementSemicolon();
      return new Continue(id);
    } else {
      consumeStatementSemicolon();
      return new Continue(null);
    }
  }
  Break parseBreak() {
    consume("BREAK");
    if (!isAtNewLineToken() && peekTokenType() == "ID") {
      String id = consume("ID");
      consumeStatementSemicolon();
      return new Break(id);
    } else {
      consumeStatementSemicolon();
      return new Break(null);
    }
  }
  Return parseReturn() {
    consume("RETURN");
    Expression value_A;
    if (isAtNewLineToken()) {
      value_A = new LiteralUndefined();
    } else {
      switch (peekTokenType()) {
        case "EOF": case "ERROR": case "SEMICOLON":
          value_A = new LiteralUndefined();
          break;

        default:
          value_A = parseExpression(false);
      }
      consumeStatementSemicolon();
      return new Return(value_A);
    }
    return null;
  }
  Switch parseSwitch() {
    consume("SWITCH");
    consume("LPAREN");
    Expression key_A = parseExpression(false);
    consume("RPAREN");
    List<SwitchClause> clauses = parseCaseBlock();
    return new Switch(key_A, clauses);
  }
  List<SwitchClause> parseCaseBlock() {
    consume("LBRACE");
    List<SwitchClause> clauses = <SwitchClause>[];
    bool defaultCaseIsDone = false;
    while (peekTokenType() != "RBRACE") {
      switch (peekTokenType()) {
        case "CASE":
          clauses.add(parseCaseClause());
          break;

        case "DEFAULT":
          if (defaultCaseIsDone) {
            error("Only one default-clause allowed", peekToken(), peekToken());
          }
          clauses.add(parseDefaultClause());
          break;
      }
    }
    consume("RBRACE");
    return clauses;
  }
  Case parseCaseClause() {
    consume("CASE");
    Expression expr = parseExpression(false);
    consume(":");
    Block body = parseSwitchClauseStatements();
    return new Case(expr, body);
  }
  Default parseDefaultClause() {
    consume("DEFAULT");
    consume(":");
    return new Default(parseSwitchClauseStatements());
  }
  Block parseSwitchClauseStatements() {
    List<Statement> statements = <Statement>[];
    while (true) {
      switch (peekTokenType()) {
        case "RBRACE": case "EOF": case "ERROR": case "DEFAULT": case "CASE":
          return new Block(statements);

        default:
          statements.add(parseStatement());
      }
    }
  }
  Statement parseLabeledOrExpression() {
    Token idToken = consumeAny();
    String nextTokenType = peekTokenType();
    assert(idToken.type == "ID");
    pushBackToken(idToken);
    if (nextTokenType == ":") {
      return parseLabeled();
    } else {
      return parseExpressionStatement();
    }
  }
  Statement parseExpressionStatement() {
    Expression expr = parseVarExpression(false);
    consumeStatementSemicolon();
    return new ExpressionStatement(expr);
  }
  Statement parseLabeled() {
    String id = consume("ID");
    consume(":");
    Statement statement = parseStatement();
    statement.label = id;
    return statement;
  }
  FunctionDeclaration parseFunctionDeclaration() => parseFunction(true);
  Expression parseFunctionExpression() => parseFunction(false);
  Node parseFunction(isDeclaration) {
    consume("FUNCTION");
    String id = null;
    if (isDeclaration || peekTokenType() == "ID") id = consume("ID");
    List<Parameter> params = parseParameters();
    Block body = parseBlock();
    Fun fun = new Fun(params, body);
    if (isDeclaration) return new FunctionDeclaration(new VariableDeclaration(id), fun);
    if (id != null) return new NamedFunction(new VariableDeclaration(id), fun);
    return fun;
  }
  List<Parameter> parseParameters() {
    List<Parameter> result_A = <Parameter>[];
    consume("LPAREN");
    if (peekTokenType() == "RPAREN") {
      consumeAny();
      return result_A;
    }
    while (true) {
      result_A.add(new Parameter(consume("ID")));
      if (peekTokenType() != "COMMA") break;
      consumeAny();
    }
    consume("RPAREN");
    return result_A;
  }
  Expression parseVarExpression(bool inForInit) {
    if (peekTokenType() == "VAR") {
      return parseVariableDeclarationList(inForInit);
    }
    return parseExpression(inForInit);
  }
  VariableDeclarationList parseVariableDeclarationList(bool inForInit) {
    consume("VAR");
    List<VariableInitialization> declarations = <VariableInitialization>[parseVar(inForInit)];
    while (true) {
      switch (peekTokenType()) {
        case "SEMICOLON":
          return new VariableDeclarationList(declarations);

        case "COMMA":
          consumeAny();
          declarations.add(parseVar(inForInit));
          break;

        case "IN":
          if (!inForInit) error("bad token: ", "in", peekToken());
          return new VariableDeclarationList(declarations);

        default:
          if (!inForInit && (isAtNewLineToken() || peekTokenType() == "EOF")) {
            return new VariableDeclarationList(declarations);
          }
          unexpectedToken(consumeAny());
      }
    }
  }
  VariableInitialization parseVar(bool inForInit) {
    String id = consume("ID");
    if (peekTokenType() == "=") {
      consumeAny();
      return new VariableInitialization(new VariableDeclaration(id), parseAssignExpression(inForInit));
    }
    return new VariableInitialization(new VariableDeclaration(id), null);
  }
  Expression parseExpression(bool inForInit) => parseSequence(inForInit);
  Expression parseSequence(bool inForInit) {
    Expression expr = parseAssignExpression(inForInit);
    if (peekTokenType() == "COMMA") {
      List<Expression> expressions = <Expression>[expr];
      while (peekTokenType() == "COMMA") {
        consumeAny();
        expressions.add(parseAssignExpression(inForInit));
      }
      return new Sequence(expressions);
    } else {
      return expr;
    }
  }
  bool isAssignOperator(String tokenType) {
    switch (tokenType) {
      case "=": case "*=": case "/=": case "%=": case "+=": case "-=": case "<<=": case ">>=": case "&=": case "^=": case "|=": case "~=":
        return true;

      default:
        return false;
    }
  }
  Expression parseAssignExpression(bool inForInit) {
    removeEquals(String op) {
      assert(op[op.length - 1] == "=");
      return op.substring(0, op.length - 1);
    }
    Token errorToken = peekToken();
    Expression expr = parseConditionalExpression(inForInit);
    if (!isAssignOperator(peekTokenType())) return expr;
    String op = consumeAny().value;
    Expression rhs = parseAssignExpression(inForInit);
    if ((op == "=") && expr is PropertyAccess) return new Assignment(expr, rhs);
    if ((op == "=") && expr is VariableUse) return new Assignment(expr, rhs);
    if (op == "=") error("bad assignment", null, errorToken);
    if (expr is PropertyAccess) {
      op = removeEquals(op);
      if (op == '~') {
        return new TildeAssignment(expr, rhs);
      }
      return new Assignment.compound(expr, op, rhs);
    }
    if (expr is VariableUse) {
      op = removeEquals(op);
      return new Assignment.compound(expr, op, rhs);
    }
    error("bad assignment", null, errorToken);
    return null;
  }
  Expression parseConditionalExpression(bool inForInit) {
    Expression expr = parseBinaryExpression(inForInit);
    if (peekTokenType() != "?") return expr;
    consumeAny();
    Expression then_A = parseAssignExpression(false);
    consume(":");
    Expression otherwise = parseAssignExpression(inForInit);
    return new Conditional(expr, then_A, otherwise);
  }
  int operatorLevel(String tokenType) {
    switch (tokenType) {
      case "||":
        return 1;

      case "&&":
        return 2;

      case "|":
        return 3;

      case "^":
        return 4;

      case "&":
        return 5;

      case "==": case "!=": case "===": case "!==":
        return 6;

      case "<": case ">": case "<=": case ">=": case "INSTANCEOF": case "IN":
        return 7;

      case "<<": case ">>": case ">>>":
        return 8;

      case "+": case "-":
        return 9;

      case "*": case "/": case "%":
        return 10;

      default:
        return null;
    }
  }
  Expression parseBinaryExpression(bool inForInit) {
    Expression parseBinaryExpressionOfLevel(int level) {
      if (level > 10) return parseUnary();
      Expression expr = parseBinaryExpressionOfLevel(level + 1);
      while (true) {
        String type = peekTokenType();
        if (inForInit && type == "IN") return expr;
        int newLevel = operatorLevel(type);
        if (newLevel == null) return expr;
        if (newLevel != level) return expr;
        String op = consumeAny().value;
        Expression other = parseBinaryExpressionOfLevel(level + 1);
        expr = new Binary(op, expr, other);
      }
    }
    return parseBinaryExpressionOfLevel(1);
  }
  Expression parseUnary() {
    switch (peekTokenType()) {
      case "DELETE":
        consumeAny();
        return new PrefixDelete(parseUnary());

      case "VOID":
        consumeAny();
        return new PrefixVoid(parseUnary());

      case "TYPEOF":
        consumeAny();
        return new PrefixTypeOf(parseUnary());

      case "!":
        consumeAny();
        return new PrefixNot(parseUnary());

      case "++":
        consumeAny();
        return new PrefixPlusPlus(parseUnary());

      case "--":
        consumeAny();
        return new PrefixMinusMinus(parseUnary());

      case "+":
        consumeAny();
        return parseUnary();

      case "-":
        consumeAny();
        Expression expr = parseUnary();
        if (expr is LiteralNumber) {
          expr.numVal = -expr.numVal;
          return expr;
        }
        return new PrefixMinus(expr);

      default:
        return parsePostfix();
    }
  }
  Expression parsePostfix() {
    Expression lhs = parseLeftHandSide();
    if (!isAtNewLineToken()) {
      String type = peekTokenType();
      if (type == '++') {
        consumeAny();
        return new PostfixPlusPlus(lhs);
      } else if (type == '--') {
        consumeAny();
        return new PostfixMinusMinus(lhs);
      }
    }
    return lhs;
  }
  Expression parseLeftHandSide() {
    return parseAccessOrCall(parseNewExpression(), true);
  }
  Expression parseNewExpression() {
    if (peekTokenType() != "NEW") {
      return parseAccessOrCall(parsePrimary(), false);
    }
    consumeAny();
    Expression cls = parseNewExpression();
    List<Expression> args = peekTokenType() == "LPAREN" ? parseArguments() : <Expression>[];
    return new New(cls, args);
  }
  Expression parseAccessOrCall(Expression expr, bool callsAreAllowed) {
    String parseFieldName() {
      if (peekTokenType() == "ID") return consume("ID");
      unexpectedToken(consumeAny());
      return null;
    }
    while (true) {
      switch (peekTokenType()) {
        case "LBRACKET":
          consumeAny();
          Expression field = parseExpression(false);
          consume("RBRACKET");
          expr = new PropertyAccess(expr, field);
          break;

        case "DOT":
          consumeAny();
          String field = parseFieldName();
          expr = new PropertyAccess(expr, new LiteralString('"${field}"'));
          break;

        case "LPAREN":
          if (callsAreAllowed) {
            expr = new Call(expr, parseArguments());
          } else {
            return expr;
          }
          break;

        default:
          return expr;
      }
    }
  }
  List<Expression> parseArguments() {
    consume("LPAREN");
    List<Expression> result_A = <Expression>[];
    if (peekTokenType() == "RPAREN") {
      consumeAny();
      return result_A;
    }
    result_A.add(parseAssignExpression(false));
    while (peekTokenType() != "RPAREN") {
      consume("COMMA");
      result_A.add(parseAssignExpression(false));
    }
    consumeAny();
    return result_A;
  }
  Expression parsePrimary() {
    switch (peekTokenType()) {
      case "FUNCTION":
        return parseFunctionExpression();

      case "THIS":
        consumeAny();
        return new This();

      case "ID":
        return new VariableUse(consume("ID"));

      case "LPAREN":
        consumeAny();
        Expression expr = parseExpression(false);
        consume("RPAREN");
        return expr;

      case "LBRACKET":
        return parseArrayLiteral();

      case "LBRACE":
        return parseObjectLiteral();

      case "NULL":
        consumeAny();
        return new LiteralNull();

      case "TRUE": case "FALSE":
        return new LiteralBool(consumeAny().value == "true");

      case "NUMBER":
        return new LiteralNumber(consumeAny().value);

      case "STRING":
        return new LiteralString(consumeAny().value);

      case "/": case "/=":
        return parseRegExpLiteral();

      default:
        unexpectedToken(peekToken());
    }
    return null;
  }
  ArrayInitializer parseArrayLiteral() {
    consume("LBRACKET");
    List<ArrayElement> elements = <ArrayElement>[];
    int length_A = 0;
    while (true) {
      switch (peekTokenType()) {
        case "RBRACKET":
          consumeAny();
          return new ArrayInitializer(length_A, elements);

        case "COMMA":
          consumeAny();
          length_A++;
          break;

        default:
          elements.add(new ArrayElement(length_A, parseAssignExpression(false)));
          length_A++;
          if (peekTokenType() != "RBRACKET") {
            consume("COMMA");
          }
      }
    }
  }
  ObjectInitializer parseObjectLiteral() {
    Literal parsePropertyName() {
      switch (peekTokenType()) {
        case "ID":
          String id = consume("ID");
          return new LiteralString('"${id}"', id);

        case "STRING":
          return new LiteralString(consume("STRING"));

        case "NUMBER":
          return new LiteralNumber(consume("NUMBER"));

        default:
          unexpectedToken(consumeAny());
      }
      return null;
    }
    Property parsePropertyInit() {
      Literal name_A = parsePropertyName();
      consume(":");
      Expression value_A = parseAssignExpression(false);
      return new Property(name_A, value_A);
    }
    consume("LBRACE");
    List<Property> properties = <Property>[];
    while (peekTokenType() != "RBRACE") {
      if (!properties.isEmpty) consume("COMMA");
      properties.add(parsePropertyInit());
    }
    consumeAny();
    return new ObjectInitializer(properties);
  }
  RegExpLiteral parseRegExpLiteral() {
    Token token = lexer.lexRegExp();
    if (token.type != "REGEXP") unexpectedToken(token);
    Token regExpStart = consumeAny();
    return new RegExpLiteral("${regExpStart.value}${token.value}");
  }
}
abstract class Prefix extends Expression {
  Prefix(this.expression);
  Expression expression;
  accept(NodeVisitor visitor) => visitor.visitPrefix(this);
  void visitChildren(NodeVisitor visitor) {
    expression.accept(visitor);
  }
}
class PrefixPlusPlus extends Prefix {
  PrefixPlusPlus(Expression exp_A) : super(exp_A);
  Object run(Scope scope) {
    LeftValue lval = expression.getLeftValue(scope);
    if (lval != null) {
      Object val = lval.getValue();
      if (val is num) {
        lval.assign(val + 1);
        return val + 1;
      }
    }
    return null;
  }
}
class PrefixMinusMinus extends Prefix {
  PrefixMinusMinus(Expression exp_A) : super(exp_A);
  Object run(Scope scope) {
    LeftValue lval = expression.getLeftValue(scope);
    if (lval != null) {
      Object val = lval.getValue();
      if (val is num) {
        lval.assign(val - 1);
        return val - 1;
      }
    }
    return null;
  }
}
class PrefixMinus extends Prefix {
  PrefixMinus(Expression exp_A) : super(exp_A);
  Object run(Scope scope) {
    Object val = expression.run(scope);
    if (val is num) {
      return -val;
    }
    return null;
  }
}
class PrefixDelete extends Prefix {
  PrefixDelete(Expression exp_A) : super(exp_A);
  Object run(Scope scope) {
    LeftValue lval = expression.getLeftValue(scope);
    if (lval != null) {
      lval.delete();
    }
    return null;
  }
}
class PrefixVoid extends Prefix {
  PrefixVoid(Expression exp_A) : super(exp_A);
  Object run(Scope scope) {
    expression.run(scope);
    return null;
  }
}
class PrefixTypeOf extends Prefix {
  PrefixTypeOf(Expression exp_A) : super(exp_A);
  Object run(Scope scope) {
    Object val = expression.run(scope);
    if (val is IDGObject) {
      return val.getType();
    } else if (val is List) {
      return 'list';
    } else if (val is String) {
      return 'string';
    } else if (val is num) {
      return 'number';
    } else if (val is bool) {
      return 'boolean';
    }
    return 'object';
  }
}
class PrefixNot extends Prefix {
  PrefixNot(Expression exp_A) : super(exp_A);
  Object run(Scope scope) {
    Object val = expression.run(scope);
    return !dgToBoolJs(val);
  }
}
abstract class Postfix extends Expression {
  Postfix(this.expression);
  Expression expression;
  accept(NodeVisitor visitor) => visitor.visitPostfix(this);
  void visitChildren(NodeVisitor visitor) {
    expression.accept(visitor);
  }
}
class PostfixPlusPlus extends Postfix {
  PostfixPlusPlus(Expression exp_A) : super(exp_A);
  Object run(Scope scope) {
    LeftValue lval = expression.getLeftValue(scope);
    if (lval != null) {
      Object val = lval.getValue();
      if (val is num) {
        lval.assign(val + 1);
      }
      return val;
    }
    return null;
  }
}
class PostfixMinusMinus extends Postfix {
  PostfixMinusMinus(Expression exp_A) : super(exp_A);
  Object run(Scope scope) {
    LeftValue lval = expression.getLeftValue(scope);
    if (lval != null) {
      Object val = lval.getValue();
      if (val is num) {
        lval.assign(val - 1);
      }
      return val;
    }
    return null;
  }
}
Object getFutureMember(Future future_A, String name_A) {
  if (name_A == "then" || name_A == "next") {
    return _futureThen;
  } else if (name_A == "catch" || name_A == "catchError" || name_A == "error") {
    return _futureCatchError;
  }
  return null;
}
Object _futureThen(Future future_A, List args) {
  if (future_A is! Future || args.length != 1 || args[0] is! ScriptFunction) {
    return null;
  }
  ScriptFunction func = args[0];
  return future_A.then((val) {
    return func(future_A, [val]);
  });
}
Object _futureCatchError(Future future_A, List args) {
  if (future_A is! Future || args.length != 1 || args[0] is! ScriptFunction) {
    return null;
  }
  ScriptFunction func = args[0];
  return future_A.catchError((e, stack) {
    return func(future_A, [e, stack]);
  });
}
void resolve_A(Program program) {
  Collector collector = new Collector();
  collector.collect(program);
  Resolver resolver = new Resolver(collector.declaredVars, collector.scopesContainingEval);
  resolver.visitProgram(program);
}
class Collector extends BaseVisitor {
  final Map<Node, Map<String, Var>> declaredVars;
  final Set<Node> scopesContainingEval;
  Node currentScope;
  Map<String, Var> declaredVarsInCurrentScope;
  bool get isGlobal => currentScope is Program;
  Collector() : declaredVars = new DGHashMap<Node, Map<String, Var>>(), scopesContainingEval = new Set<Node>();
  void collect(Program program) {
    program.accept(this);
  }
  visitScope(Node node, void doInsideScope()) {
    Node oldScope = currentScope;
    Map oldDeclaredVars = declaredVarsInCurrentScope;
    currentScope = node;
    declaredVarsInCurrentScope = new DGHashMap<String, Var>();
    declaredVars[node] = declaredVarsInCurrentScope;
    doInsideScope();
    node.visitChildren(this);
    declaredVarsInCurrentScope = oldDeclaredVars;
    currentScope = oldScope;
  }
  void addThis() {
    declaredVarsInCurrentScope["this"] = new Var("this", isParam: true);
  }
  void addArgumentsObject() {
    declaredVarsInCurrentScope["arguments"] = new Var("arguments", isParam: true);
  }
  visitProgram(Program node) {
    visitScope(node, () {
      addThis();
      node.visitChildren(this);
    });
  }
  visitNamedFunction(NamedFunction node) {
    visitScope(node, () {
      node.visitChildren(this);
    });
  }
  visitFun(Fun node) {
    visitScope(node, () {
      addThis();
      addArgumentsObject();
      node.visitChildren(this);
    });
  }
  visitVariableDeclaration(VariableDeclaration node) {
    String id = node.name;
    declaredVarsInCurrentScope[id] = new Var(id, isGlobal: isGlobal);
  }
  visitParameter(Parameter node) {
    String id = node.name;
    declaredVarsInCurrentScope[id] = new Var(id, isParam: true);
  }
  visitCall(Call node) {
    if (node.target is VariableUse) {
      VariableUse target = node.target;
      if (target.name == "eval") scopesContainingEval.add(currentScope);
    }
    node.visitChildren(this);
  }
  visitPrefix(Prefix node) {
    node.visitChildren(this);
  }
  visitPostfix(Postfix node) {
    node.visitChildren(this);
  }
}
class Resolver extends BaseVisitor {
  final Map<Node, Map<String, Var>> declaredVars;
  final Set<Node> scopesContainingEval;
  final List<Node> scopes;
  final List<Map<String, Var>> scopesVars;
  Resolver(this.declaredVars, this.scopesContainingEval) : scopes = <Node>[], scopesVars = <Map<String, Var>>[];
  visitScope(Node node) {
    scopes.add(node);
    scopesVars.add(declaredVars[node]);
    node.visitChildren(this);
    scopesVars.length--;
    scopes.length--;
  }
  visitProgram(Program node) => visitScope(node);
  visitNamedFunction(NamedFunction node) => visitScope(node);
  visitFun(Fun node) => visitScope(node);
  visitVariableReference(VariableReference node) {
    node.scopeNode = resolve(node.name, scopes.length - 1);
  }
  Node resolve(String id, int scopeIndex) {
    Map<String, Var> vars = scopesVars[scopeIndex];
    Node scope = scopes[scopeIndex];
    Var v = vars[id];
    if (v != null) return scope;
    if (scope is Program) {
      return scope;
    }
    return resolve(id, scopeIndex - 1);
  }
}
class Scope extends IDGMap {
  final Scope parent;
  final Node node;
  Map<String, Object> map = new DGHashMap<String, Object>();
  Scope(this.node, this.parent);
  Object getValue(String name_A) {
    return map[name_A];
  }
  void updateValue(String name_A, Object val) {
    map[name_A] = val;
  }
  void setValue(String name_A, Object val) {
    map[name_A] = val;
  }
  void setBinding(String name_A, String val) {
    throw '~= not supported for this type';
  }
  bool contains(String name_A) {
    return map.containsKey(name_A);
  }
}
class ProgramScope extends Scope {
  static final Map<String, Object> global = global_functions;
  Map<String, Object> inputs;
  IDGMap thisObj;
  ProgramScope(Node node, Scope parent_A, this.inputs, this.thisObj) : super(node, parent_A);
  Object getValue(String name_A) {
    if (name_A.startsWith('@')) {
      if (name_A == '@') {
        return thisObj;
      } else {
        return thisObj.getValue(name_A);
      }
    }
    if (map.containsKey(name_A)) {
      return map[name_A];
    }
    if (inputs != null && inputs.containsKey(name_A)) {
      return inputs[name_A];
    }
    if (global.containsKey(name_A)) {
      return global[name_A];
    }
    return null;
  }
}
class FunScope extends Scope {
  FunScope(Node node, Scope parent_A) : super(node, parent_A);
}
typedef Object ScriptFunction(Object _0, List _1);
abstract class JsNativeClass {}
class FunctionInstance {
  final Fun function;
  final Scope scope;
  FunctionInstance(this.function, this.scope);
  Object call(Object this_, List args) {
    return function.runFun(scope, args, this_);
  }
}
Object accessProperty(Object target, Object selector) {
  if (target == null) {
    throw 'can not access ${selector} of null';
  }
  if (target is Map) {
    return target[selector.toString()];
  }
  if (target is IDGMap) {
    return target.getValue(selector.toString());
  }
  if (target is String) {
    return getStringMember(target, selector);
  }
  if (target is List && selector is num) {
    return target[selector.toInt()];
  }
  if (target is List) {
    return getListMember(target, selector);
  }
  if (target is XmlNode) {
    return getXmlMember(target, selector);
  }
  if (target is DateTime) {
    return getDateTimeMember(target, selector);
  }
  if (target is Future) {
    return getFutureMember(target, selector);
  }
  if (target is JsRegExp) {
    return getRegExpMember(target, selector);
  }
  throw 'can not access ${selector} of ${target}';
}
abstract class LeftValue {
  void assign(Object val);
  void tildeAssign(Object val) {
    throw '~= not supported for this type';
  }
  Object getValue();
  Object getTarget();
  void delete();
  static LeftValue create(Object target, Object selector) {
    if (target is Map && selector is String) {
      return new LeftValueMap(target, selector);
    }
    if (target is IDGMap) {
      return new LeftValueDGMap(target, selector.toString());
    }
    if (target is List) {
      if (selector is num) {
        return new LeftValueList(target, selector.toInt());
      } else if (selector == 'length') {
        return new LeftValueListLength(target);
      } else {
        return new LeftValueConst(target, getListMember(target, selector));
      }
    }
    if (target is String) {
      return new LeftValueConst(target, getStringMember(target, selector));
    }
    if (target is XmlElement) {
      return new LeftValueConst(target, getXmlMember(target, selector));
    }
    if (target is Future) {
      return new LeftValueConst(target, getFutureMember(target, selector));
    }
    return null;
  }
}
class LeftValueConst extends LeftValue {
  final Object target;
  final Object value;
  Object getTarget() => target;
  LeftValueConst(this.target, this.value);
  void assign(Object val) {}
  Object getValue() {
    return value;
  }
  void delete() {}
}
abstract class IComplexValue {}
class LeftValueDGMap implements LeftValue {
  final IDGMap map;
  final String field;
  Object getTarget() => map;
  LeftValueDGMap(this.map, this.field);
  void assign(Object val) {
    if (val is IComplexValue) {
      map.setValue(field, val.getOrClone());
    } else {
      map.updateValue(field, val);
    }
  }
  void tildeAssign(Object val) {
    if (val is List) {
      if (val.length == 1 && val[0] is String) {
        map.setBinding(field, val[0]);
      } else {
        map.setBinding(field, null);
      }
    } else if (val is IComplexValue) {
      map.setValue(field, val.getOrClone());
    } else {
      map.setValue(field, val);
    }
  }
  Object getValue() {
    return map.getValue(field);
  }
  void delete() {
    map.setValue(field, null);
  }
}
class LeftValueMap extends LeftValue {
  final Map map;
  final String field;
  Object getTarget() => map;
  LeftValueMap(this.map, this.field);
  void assign(Object val) {
    map[field] = val;
  }
  Object getValue() {
    return map[field];
  }
  void delete() {
    map.remove(field);
  }
}
class LeftValueList extends LeftValue {
  final List list;
  final int idx;
  Object getTarget() => list;
  LeftValueList(this.list, this.idx);
  void assign(Object val) {
    list[idx] = val;
  }
  Object getValue() {
    return list[idx];
  }
  void delete() {}
}
class LeftValueListLength extends LeftValue {
  final List list;
  Object getTarget() => list;
  LeftValueListLength(this.list);
  void assign(Object val) {
    list.length = val;
  }
  Object getValue() {
    return list.length;
  }
  void delete() {}
}
class JsRegExp {
  RegExp reg;
  bool isGlobal = false;
  JsRegExp(String pattern_B) {
    int pos = pattern_B.lastIndexOf('/');
    bool caseSensitive = !pattern_B.contains('i', pos);
    bool multiLine = pattern_B.contains('m', pos);
    isGlobal = pattern_B.contains('g', pos);
    reg = new RegExp(pattern_B.substring(1, pos), multiLine: multiLine, caseSensitive: caseSensitive);
  }
  Object exec(Object this_, List args) {
    Object arg0 = args[0];
    if (arg0 is String) {
      Match m = reg.firstMatch(arg0);
      if (m != null) {
        List<String> rslt = [];
        for (int i = 0; i <= m.groupCount; ++i) {
          rslt.add(m.group(i));
        }
        return rslt;
      }
    }
    return null;
  }
  Object test(Object this_, List args) {
    Object arg0 = args[0];
    if (arg0 is String) {
      return reg.hasMatch(arg0);
    }
    return null;
  }
}
Object getRegExpMember(JsRegExp exp_A, String name_A) {
  if (name_A == 'exec') {
    return exp_A.exec;
  } else if (name_A == 'test') {
    return exp_A.test;
  }
  return null;
}
Object getStringMember(String str, String name_A) {
  if (name_A == 'length') return str.length;
  if (name_A == 'replace') return _strReplace;
  if (name_A == 'replaceAll') return _strReplaceAll;
  if (name_A == 'match') return _strMatch;
  if (name_A == 'matchAll') return _strMatchAll;
  if (name_A == 'charAt') return _strCharAt;
  if (name_A == 'charCodeAt') return _strCharCodeAt;
  if (name_A == 'indexOf') return _strIndexOf;
  if (name_A == 'lastIndexOf') return _strLastIndexOf;
  if (name_A == 'split') return _strSplit;
  if (name_A == 'subStr') return _strSubStr;
  if (name_A == 'subString') return _strSubString;
  if (name_A == 'substr') return _strSubStr;
  if (name_A == 'substring') return _strSubString;
  if (name_A == 'slice') return _strSubString;
  if (name_A == 'toLowerCase') return _strToLowerCase;
  if (name_A == 'toUpperCase') return _strToUpperCase;
  if (name_A == 'trim') return _strTrim;
  if (name_A == 'trimLeft') return _strTrimLeft;
  if (name_A == 'trimRight') return _strTrimRight;
  if (name_A == 'encodeBase64') return strEncodeBase64;
  if (name_A == 'decodeBase64') return strDecodeBase64;
  if (name_A == 'encodeUriComponent') return strEncodeUriComponent;
  if (name_A == 'decodeUriComponent') return strDecodeUriComponent;
  if (name_A == 'encodeCamelCase') return strEncodeCamelCase;
  if (name_A == 'decodeCamelCase') return strDecodeCamelCase;
  if (name_A == 'splitQuery') return strSplitQuery;
  if (name_A == 'md5') return strMd5;
  if (name_A == 'sha1') return strSha1;
  if (name_A == 'sha256') return strSha256;
  return null;
}
Object _strReplace(Object this_, List args) {
  if (this_ is String) {
    Object arg0 = args[0];
    Object arg1 = dgToString(args[1]);
    if (arg0 is String) {
      return this_.replaceFirst(arg0, arg1);
    } else if (arg0 is JsRegExp) {
      if (arg0.isGlobal) {
        return this_.replaceAll(arg0.reg, arg1);
      } else {
        return this_.replaceFirst(arg0.reg, arg1);
      }
    }
  }
  return null;
}
Object _strReplaceAll(Object this_, List args) {
  if (this_ is String) {
    Object arg0 = args[0];
    Object arg1 = dgToString(args[1]);
    if (arg0 is String) {
      return this_.replaceAll(arg0, arg1);
    } else if (arg0 is JsRegExp) {
      return this_.replaceAll(arg0.reg, arg1);
    }
  }
  return null;
}
Object _strMatch(Object this_, List args) {
  if (this_ is String) {
    Object arg0 = args[0];
    if (arg0 is JsRegExp) {
      if (arg0.isGlobal) {
        Iterable<Match> rslt = arg0.reg.allMatches(this_);
        if (rslt.length == 0) {
          return null;
        }
        return rslt.map((Match m) => m.group(0)).toList();
      } else {
        Match rslt = arg0.reg.firstMatch(this_);
        if (rslt != null) {
          return rslt.group(0);
        }
      }
    }
  }
  return null;
}
Object _strMatchAll(Object this_, List args) {
  if (this_ is String) {
    Object arg0 = args[0];
    if (arg0 is JsRegExp) {
      return arg0.reg.allMatches(this_).map((Match m) => m.group(0)).toList();
    }
  }
  return null;
}
Object _strCharAt(Object this_, List args) {
  if (this_ is String && args[0] is num) {
    int pos = args[0].toInt();
    return this_.substring(pos, pos + 1);
  }
  return null;
}
Object _strCharCodeAt(Object this_, List args) {
  if (this_ is String && args[0] is num) {
    int pos = args[0].toInt();
    return this_.codeUnitAt(pos);
  }
  return null;
}
Object _strIndexOf(Object this_, List args) {
  if (this_ is String && args[0] is String) {
    return this_.indexOf(args[0]);
  }
  return null;
}
Object _strLastIndexOf(Object this_, List args) {
  if (this_ is String && args[0] is String) {
    return this_.lastIndexOf(args[0]);
  }
  return null;
}
Object _strSplit(Object this_, List args) {
  if (this_ is String) {
    Object arg0 = args[0];
    List rslt;
    if (arg0 is String) {
      rslt = this_.split(arg0);
    } else if (arg0 is JsRegExp) {
      rslt = this_.split(arg0.reg);
    }
    if (args.length > 1 && args[1] == true) {
      rslt = rslt.where((s) => s != '').toList();
    }
    return rslt;
  }
  return null;
}
Object _strSubString(Object this_, List args) {
  if (this_ is String && args[0] is num) {
    if (args.length > 1 && args[1] is num) {
      int start_A = args[0].toInt();
      int end_A = args[1].toInt();
      if (start_A < 0) start_A = this_.length + start_A;
      if (end_A < 0) end_A = this_.length + end_A;
      return this_.substring(start_A, end_A);
    } else {
      int start_A = args[0].toInt();
      if (start_A < 0) start_A = this_.length + start_A;
      return this_.substring(start_A);
    }
  }
  return null;
}
Object _strSubStr(Object this_, List args) {
  if (this_ is String && args[0] is num) {
    if (args.length > 1 && args[1] is num) {
      int pos0 = args[0].toInt();
      int len1 = args[1].toInt();
      return this_.substring(pos0, len1 + pos0);
    } else {
      return this_.substring(args[0].toInt());
    }
  }
  return null;
}
Object _strToLowerCase(Object this_, List args) {
  if (this_ is String) {
    return this_.toLowerCase();
  }
  return null;
}
Object _strToUpperCase(Object this_, List args) {
  if (this_ is String) {
    return this_.toUpperCase();
  }
  return null;
}
Object _strTrim(Object this_, List args) {
  if (this_ is String) {
    return this_.trim();
  }
  return null;
}
Object _strTrimLeft(Object this_, List args) {
  if (this_ is String) {
    return this_.trimLeft();
  }
  return null;
}
Object _strTrimRight(Object this_, List args) {
  if (this_ is String) {
    return this_.trimRight();
  }
  return null;
}
Object strEncodeBase64(Object this_, List args) {
  if (this_ is String) {
    return CryptoUtils.bytesToBase64((const Utf8Codec(allowMalformed: true)).encode(this_));
  }
  return null;
}
Object strDecodeBase64(Object this_, List args) {
  if (this_ is String) {
    if (args.length > 0 && args[0] == true) {
      return CryptoUtils.base64StringToBytes(this_);
    } else {
      return (const Utf8Codec(allowMalformed: true)).decode(CryptoUtils.base64StringToBytes(this_), allowMalformed: true);
    }
  }
  return null;
}
Object strEncodeUriComponent(Object this_, List args) {
  if (this_ is String) {
    return Uri.encodeComponent(this_);
  }
  return null;
}
Object strDecodeUriComponent(Object this_, List args) {
  if (this_ is String) {
    return UriComponentDecoder.decode_A(this_);
  }
  return null;
}
Object strEncodeCamelCase(Object this_, List args) {
  if (this_ is String) {
    return DGStringFunctions.encodeCamelCase(this_);
  }
  return null;
}
Object strDecodeCamelCase(Object this_, List args) {
  if (this_ is String) {
    return DGStringFunctions.decodeCamelCase(this_);
  }
  return null;
}
Object strSplitQuery(Object this_, List args) {
  if (this_ is String) {
    return Uri.splitQueryString(this_);
  }
  return null;
}
Object strMd5(Object this_, List args) {
  if (this_ is String) {
    Hash hash = new MD5();
    hash.add((const Utf8Codec(allowMalformed: true)).encode(this_));
    return CryptoUtils.bytesToHex(hash.close());
  }
  return null;
}
Object strSha1(Object this_, List args) {
  if (this_ is String) {
    Hash hash = new SHA1();
    hash.add((const Utf8Codec(allowMalformed: true)).encode(this_));
    return CryptoUtils.bytesToHex(hash.close());
  }
  return null;
}
Object strSha256(Object this_, List args) {
  if (this_ is String) {
    Hash hash = new SHA256();
    hash.add((const Utf8Codec(allowMalformed: true)).encode(this_));
    return CryptoUtils.bytesToHex(hash.close());
  }
  return null;
}
class Var {
  final String id;
  final bool isGlobal;
  final bool isImplicit;
  final bool isParam;
  const Var(this.id, {isGlobal: false, isImplicit: false, isParam: false}) : this.isGlobal = isGlobal, this.isImplicit = isImplicit, this.isParam = isParam;
}
class JsXml implements IDGMap {
  const JsXml();
  Object getValue(String name_A) {
    return xmlMap[name_A];
  }
  void setValue(String name_A, Object val) {
    throw "can't change readonly object";
  }
  void updateValue(String name_A, Object val) {
    throw "can't change readonly object";
  }
  void setBinding(String name_A, String val) {
    throw "can't change readonly object";
  }
}
const Map<String, Object> xmlMap = const{'parse': _xmlParse, 'stringify': _xmlStringify};
Object getXmlMember(XmlNode xml, Object name_A) {
  if (name_A == 'children') {
    if (xml is XmlElement) {
      return xml.children;
    }
    return null;
  }
  if (name_A == 'elements') {
    if (xml is XmlElement) {
      return xml.children.where((node) => node is XmlElement).toList();
    }
    return null;
  }
  if (name_A == 'name') {
    if (xml is XmlElement) {
      return xml.name.local;
    }
    return null;
  }
  if (name_A == 'data') {
    if (xml is XmlData) {
      return xml.text;
    }
    return null;
  }
  if (name_A == 'text') {
    if (xml is XmlElement) {
      return DGXmlUtil.getText(xml);
    }
    return null;
  }
  if (name_A == 'getAttribute') return _xmlGetAttribute;
  if (name_A == 'query') return _xmlQuery;
  if (name_A == 'queryAll') return _xmlQueryAll;
  if (name_A == 'remove') return _xmlRemove;
  return null;
}
Object _xmlParse(Object this_, List args) {
  Object val1 = args[0];
  if (val1 is String) {
    return DGXmlUtil.parse_A(val1);
  }
  return null;
}
Object _xmlStringify(Object this_, List args) {
  Object val = args[0];
  if (val is XmlElement) {
    return val.toString();
  }
  return null;
}
Object _xmlGetAttribute(Object this_, List args) {
  Object name_A = args[0];
  if (this_ is XmlElement && name_A is String) {
    return this_.getAttribute(name_A);
  }
  return null;
}
Object _xmlQuery(Object this_, List args) {
  if (this_ is XmlElement) {
    return DGXmlUtil.query_A(this_, args[0]);
  }
  return null;
}
Object _xmlQueryAll(Object this_, List args) {
  if (this_ is XmlElement) {
    return DGXmlUtil.queryAll(this_, args[0]);
  }
  return null;
}
Object _xmlRemove(Object this_, List args) {
  if (this_ is XmlNode) {
    this_.parent.children.remove(this_);
  }
  return null;
}
Object _xmlCollectionQuery(Object this_, List args) {
  if (this_ is List<XmlNode> && this_.length > 0 && this_[0] is XmlNode) {
    return DGXmlUtil.queryList(this_, args[0]);
  }
  return null;
}
Object _xmlCollectionQueryAll(Object this_, List args) {
  if (this_ is List<XmlNode> && this_.length > 0 && this_[0] is XmlNode) {
    return DGXmlUtil.queryListAll(this_, args[0], new List<XmlNode>());
  }
  return null;
}
class DGStringFunctions {
  static RegExp _encodeCamelCaseReg0 = new RegExp(r'([^a-zA-Z0-9_\- ])|^[_0-9]+');
  static RegExp _encodeCamelCaseReg1 = new RegExp(r'[ -]+([a-zA-Z0-9_])');
  static RegExp _encodeCamelCaseReg2 = new RegExp(r'([0-9])([a-z])');
  static RegExp _decodeCamelCaseReg0 = new RegExp(r'[A-Z]');
  static String encodeCamelCase(String str) {
    String s = str.replaceAll(_encodeCamelCaseReg0, "").trim().toLowerCase();
    s = s.replaceAllMapped(_encodeCamelCaseReg1, _encodeCamelCase1);
    s = s.replaceAllMapped(_encodeCamelCaseReg2, _encodeCamelCase2);
    return s;
  }
  static String _encodeCamelCase1(Match match) {
    return match.group(1).toUpperCase();
  }
  static String _encodeCamelCase2(Match match) {
    return '${match.group(1)}${match.group(2).toUpperCase()}';
  }
  static String decodeCamelCase(String str) {
    return str.replaceAllMapped(_decodeCamelCaseReg0, _decodeCamelCase0);
  }
  static String _decodeCamelCase0(Match match) {
    return ' ${match.group(0).toLowerCase()}';
  }
}
class DGHashMap<K, V> extends DelegatingMap<K, V> {
  DGHashMap() : super(new Map<K, V>());
}
abstract class IDGMap {
  Object getValue(String name_A);
  void updateValue(String name_A, Object val);
  void setValue(String name_A, Object val);
  void setBinding(String name_A, String val);
}
abstract class IDGObject extends IDGMap {}
abstract class IDGArray extends IDGObject {}
bool dgDynamicEqual(Object obj1, Object obj2) {
  if (obj1 is String) {
    if (obj2 is num) {
      return double.parse(obj1, dgToNumberError) == obj2;
    }
    if (obj2 is bool) {
      return obj2.toString() == obj1;
    }
  }
  if (obj2 is String) {
    if (obj1 is num) {
      return double.parse(obj2, dgToNumberError) == obj1;
    }
    if (obj1 is bool) {
      return obj1.toString() == obj2;
    }
  }
  return obj1 == obj2;
}
String dgToString(Object obj, [String defaultVal = null]) {
  if (obj is String) {
    return obj;
  }
  if (obj == null) {
    return defaultVal;
  }
  if (obj is DateTime) {
    return obj.toIso8601String();
  }
  if (obj is ByteData) {
    return obj.buffer.asUint8List().map((i) => i.toRadixString(16)).join(" ");
  }
  if (obj is Map || obj is List) {
    try {
      return DGCodec.encode_A(obj);
    } catch (err) {
      if (obj is Map) {
        return '{encodingError}';
      }
      return '[encodingError]';
    }
  }
  return obj.toString();
}
num dgToNumberError(String val) => double.NAN;
num dgToNumber(Object obj, [num defaultVal = double.NAN]) {
  if (obj is num) {
    if (obj.isNaN) {
      return defaultVal;
    }
    return obj;
  }
  if (obj == null) {
    return defaultVal;
  }
  if (obj is String) {
    int rslt = int.parse(obj, onError: dgToIntError);
    if (rslt != null) {
      return rslt;
    }
    double drslt = double.parse(obj, dgToNumberError);
    if (drslt == drslt) {
      return drslt;
    }
    return defaultVal;
  }
  if (obj is bool) {
    if (obj) {
      return 1;
    } else {
      return 0;
    }
  }
  return defaultVal;
}
int dgToIntError(String val) => null;
int dgToIntError_1(String val) => -1;
int dgToInt(Object obj, [int defaultVal = null]) {
  if (obj == null) {
    return defaultVal;
  }
  if (obj is int) {
    return obj;
  }
  if (obj is num && obj.isFinite) {
    return obj.toInt();
  }
  if (obj is String) {
    double rslt = double.parse(obj, dgToNumberError);
    if (rslt == rslt) {
      return rslt.toInt();
    }
  }
  return defaultVal;
}
bool dgToBoolJs(Object obj) {
  if (obj == false || obj == null || obj == 0 || obj == '' || isNaN_A(obj)) {
    return false;
  }
  return true;
}
RegExp _dateReg1 = new RegExp(r'\b(\d{4})-(\d{1,2})-(\d{1,2})\b');
RegExp _dateReg2 = new RegExp(r'\b(\d{4})\/(\d{1,2})\/(\d{1,2})\b');
RegExp _dateReg3 = new RegExp(r'\b(\d{1,2})\/(\d{1,2})\/(\d{4})\b');
RegExp _timeReg = new RegExp(r'\b(\d{2}):(\d{2}):(\d{2})\b');
RegExp _longms = new RegExp(r'(\d{2}:\d{2}:\d{2}\.\d{3})\d+');
RegExp _amReg = new RegExp(r'\bam\b');
RegExp _pmReg = new RegExp(r'\bpm\b');
DGHashMap<Object, DateTime> dgToDateTimeCache = new DGHashMap<Object, DateTime>();
String _fixLongMs(Match m) {
  return m.group(1);
}
DateTime dgToDateTime(Object obj) {
  DateTime cachedValue = dgToDateTimeCache[obj];
  if (cachedValue != null) {
    return cachedValue;
  }
  if (dgToDateTimeCache.length > 8196) {
    dgToDateTimeCache.clear();
  }
  cachedValue = dgToDateTimeHelper(obj);
  dgToDateTimeCache[obj] = cachedValue;
  return cachedValue;
}
DateTime dgToDateTimeHelper(Object obj) {
  if (obj is num && obj.isFinite) {
    return new DateTime.fromMillisecondsSinceEpoch(obj.toInt());
  }
  if (obj is String) {
    if (obj.length > 40) {
      return null;
    }
    try {
      return DateTime.parse(obj).toLocal();
    } catch (e) {
      String fixedLongMs = obj.replaceFirstMapped(_longms, _fixLongMs);
      if (fixedLongMs != obj) {
        try {
          return DateTime.parse(fixedLongMs).toLocal();
        } catch (e) {}
      }
      int year_A;
      int month_A;
      int date;
      Match m = _dateReg1.firstMatch(obj);
      if (m != null) {
        year_A = int.parse(m.group(1));
        month_A = int.parse(m.group(2));
        date = int.parse(m.group(3));
      } else {
        m = _dateReg2.firstMatch(obj);
        if (m != null) {
          year_A = int.parse(m.group(1));
          month_A = int.parse(m.group(2));
          date = int.parse(m.group(3));
        } else {
          m = _dateReg3.firstMatch(obj);
          if (m != null) {
            year_A = int.parse(m.group(3));
            month_A = int.parse(m.group(1));
            date = int.parse(m.group(2));
          }
        }
      }
      if (m != null) {
        int hour_A = 0;
        int minute_A = 0;
        int second_A = 0;
        Match tm = _timeReg.firstMatch(obj);
        if (tm != null) {
          hour_A = int.parse(tm.group(1));
          minute_A = int.parse(tm.group(2));
          second_A = int.parse(tm.group(3));
          String lowerts = obj.toLowerCase();
          if (lowerts.contains(_amReg)) {
            if (hour_A == 12) {
              hour_A = 0;
            }
          } else if (lowerts.contains(_pmReg)) {
            if (hour_A != 12) {
              hour_A += 12;
            }
          }
        }
        return new DateTime(year_A, month_A, date, hour_A, minute_A, second_A);
      }
      num n = dgToNumber(obj);
      if (n.isFinite) {
        return new DateTime.fromMillisecondsSinceEpoch(n.toInt());
      }
    }
  }
  return null;
}
bool isNaN_A(obj) {
  if (obj is num) {
    return obj.isNaN;
  } else {
    return obj != obj;
  }
}
class DGCodec {
  static final JsonEncoder encoder_A = new JsonEncoder(_encoder_A);
  static String encode_A(Object obj) {
    return encoder_A.convert(obj);
  }
  static dynamic _encoder_A(value_A) {
    if (value_A is num) {
      num n = value_A;
      if (n.isNaN) {
        return '\u001BNaN';
      } else if (n.isInfinite) {
        if (n.isNegative) {
          return '\u001B-Infinity';
        } else {
          return '\u001BInfinity';
        }
      }
    }
    return null;
  }
}
class DGXmlUtil {
  static XmlElement parse_A(Object str) {
    return parse_B(str).rootElement;
  }
  static getText(XmlElement node) {
    if (node.children.length == 1 && node.firstChild is XmlData) {
      return (node.firstChild as XmlData).text;
    }
    return null;
  }
  static XmlNode query_A(XmlElement node, String name_A) {
    return queryList(node.children, name_A);
  }
  static XmlNode queryList(List<XmlNode> nodes, String name_A) {
    for (XmlNode child in nodes) {
      if (child is XmlElement) {
        if (child.name.local == name_A) {
          return child;
        } else {
          XmlNode rslt = queryList(child.children, name_A);
          if (rslt != null) {
            return rslt;
          }
        }
      }
    }
    return null;
  }
  static List<XmlNode> queryAll(XmlElement node, String name_A) {
    List<XmlNode> rslt = new List<XmlNode>();
    return queryListAll(node.children, name_A, rslt);
  }
  static List<XmlNode> queryListAll(List<XmlNode> nodes, String name_A, List<XmlNode> rslt) {
    for (XmlNode child in nodes) {
      if (child is XmlElement) {
        if (child.name.local == name_A) {
          rslt.add(child);
        } else {
          queryListAll(child.children, name_A, rslt);
        }
      }
    }
    return rslt;
  }
}
dynamic doExecuteScript(String script, Map variables) {
  Program program = parseProgramString(script);
  return program.runProgram({"row": variables}, null);
}
main() {
  doExecuteScript("5 + 5", {});
}
class ByteDataUtil {
  static Uint8List toUint8List(ByteData bytes) {
    return bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
  }
}
class UriComponentDecoder {
  static const int _SPACE_A = 0x20;
  static const int _PERCENT_A = 0x25;
  static const int _PLUS_A = 0x2B;
  static String decode_A(String text) {
    List codes = new List();
    List bytes = new List();
    int len = text.length;
    for (int i = 0; i < len; i++) {
      var codeUnit = text.codeUnitAt(i);
      if (codeUnit == _PERCENT_A) {
        if (i + 3 > text.length) {
          bytes.add(_PERCENT_A);
          continue;
        }
        int hexdecoded = _hexCharPairToByte_A(text, i + 1);
        if (hexdecoded > 0) {
          bytes.add(hexdecoded);
          i += 2;
        } else {
          bytes.add(_PERCENT_A);
        }
      } else {
        if (!bytes.isEmpty) {
          codes.addAll(const Utf8Decoder(allowMalformed: true).convert(bytes).codeUnits);
          bytes.clear();
        }
        if (codeUnit == _PLUS_A) {
          codes.add(_SPACE_A);
        } else {
          codes.add(codeUnit);
        }
      }
    }
    if (!bytes.isEmpty) {
      codes.addAll(const Utf8Decoder().convert(bytes).codeUnits);
      bytes.clear();
    }
    return new String.fromCharCodes(codes);
  }
  static int _hexCharPairToByte_A(String s, int pos) {
    int byte = 0;
    for (int i = 0; i < 2; i++) {
      int charCode = s.codeUnitAt(pos + i);
      if (0x30 <= charCode && charCode <= 0x39) {
        byte = byte * 16 + charCode - 0x30;
      } else if ((charCode >= 0x41 && charCode <= 0x46) || (charCode >= 0x61 && charCode <= 0x66)) {
        charCode |= 0x20;
        byte = byte * 16 + charCode - 0x57;
      } else {
        return -1;
      }
    }
    return byte;
  }
}
class ActionParser extends DelegateParser {
  final Function _function;
  ActionParser(parser, this._function) : super(parser);
  Result parseOn(Context context) {
    var result_A = _delegate_A.parseOn(context);
    if (result_A.isSuccess) {
      return result_A.success(_function(result_A.value));
    } else {
      return result_A;
    }
  }
  bool hasEqualProperties(Parser_A other) {
    return other is ActionParser && super.hasEqualProperties(other) && _function == other._function;
  }
}
class TrimmingParser extends DelegateParser {
  Parser_A _left;
  Parser_A _right;
  TrimmingParser(parser, this._left, this._right) : super(parser);
  Result parseOn(Context context) {
    var current_A = context;
    do {
      current_A = _left.parseOn(current_A);
    } while (current_A.isSuccess);
    var result_A = _delegate_A.parseOn(current_A);
    if (result_A.isFailure) {
      return result_A;
    }
    current_A = result_A;
    do {
      current_A = _right.parseOn(current_A);
    } while (current_A.isSuccess);
    return current_A.success(result_A.value);
  }
  List<Parser_A> get children => [_delegate_A, _left, _right];
  void replace(Parser_A source_A, Parser_A target) {
    super.replace(source_A, target);
    if (_left == source_A) {
      _left = target;
    }
    if (_right == source_A) {
      _right = target;
    }
  }
}
class FlattenParser extends DelegateParser {
  FlattenParser(parser) : super(parser);
  Result parseOn(Context context) {
    var result_A = _delegate_A.parseOn(context);
    if (result_A.isSuccess) {
      var output = context.buffer is String ? context.buffer.substring(context.position, result_A.position) : context.buffer.sublist(context.position, result_A.position);
      return result_A.success(output);
    } else {
      return result_A;
    }
  }
}
class TokenParser extends DelegateParser {
  TokenParser(parser) : super(parser);
  Result parseOn(Context context) {
    var result_A = _delegate_A.parseOn(context);
    if (result_A.isSuccess) {
      var token = new Token_A(result_A.value, context.buffer, context.position, result_A.position);
      return result_A.success(token);
    } else {
      return result_A;
    }
  }
}
class CharacterParser extends Parser_A {
  final CharacterPredicate _predicate;
  final String _message;
  CharacterParser(this._predicate, this._message);
  Result parseOn(Context context) {
    var buffer_A = context.buffer;
    var position = context.position;
    if (position < buffer_A.length && _predicate.test(buffer_A.codeUnitAt(position))) {
      return context.success(buffer_A[position], position + 1);
    }
    return context.failure(_message);
  }
  String toString() => '${super.toString()}[${_message}]';
  bool hasEqualProperties(Parser_A other) {
    return other is CharacterParser && super.hasEqualProperties(other) && _predicate == other._predicate && _message == other._message;
  }
}
abstract class CharacterPredicate {}
class _NotCharacterPredicate implements CharacterPredicate {
  final CharacterPredicate predicate_A;
  _NotCharacterPredicate(this.predicate_A);
  bool test(int value_A) => !predicate_A.test(value_A);
}
CharacterPredicate _optimizedRanges(Iterable<_RangeCharPredicate> ranges) {
  var sortedRanges = new List.from(ranges, growable: false);
  sortedRanges.sort((first_A, second_A) {
    return first_A.start != second_A.start ? first_A.start - second_A.start : first_A.stop - second_A.stop;
  });
  var mergedRanges = new List();
  for (var thisRange in sortedRanges) {
    if (mergedRanges.isEmpty) {
      mergedRanges.add(thisRange);
    } else {
      var lastRange = mergedRanges.last;
      if (lastRange.stop + 1 >= thisRange.start) {
        var characterRange = new _RangeCharPredicate(lastRange.start, thisRange.stop);
        mergedRanges[mergedRanges.length - 1] = characterRange;
      } else {
        mergedRanges.add(thisRange);
      }
    }
  }
  if (mergedRanges.length == 1) {
    return mergedRanges[0].start == mergedRanges[0].stop ? new _SingleCharPredicate(mergedRanges[0].start) : mergedRanges[0];
  } else {
    return new _RangesCharPredicate(mergedRanges.length, mergedRanges.map((range_A) => range_A.start).toList(growable: false), mergedRanges.map((range_A) => range_A.stop).toList(growable: false));
  }
}
Parser_A char(element_A, [String message_A]) {
  return new CharacterParser(new _SingleCharPredicate(_toCharCode(element_A)), message_A != null ? message_A : '"${element_A}" expected');
}
class _SingleCharPredicate implements CharacterPredicate {
  final int value;
  const _SingleCharPredicate(this.value);
  bool test(int value_A) => identical(this.value, value_A);
}
Parser_A digit([String message_A]) {
  return new CharacterParser(_digitCharPredicate, message_A != null ? message_A : 'digit expected');
}
class _DigitCharPredicate implements CharacterPredicate {
  const _DigitCharPredicate();
  bool test(int value_A) => 48 <= value_A && value_A <= 57;
}
const _digitCharPredicate = const _DigitCharPredicate();
Parser_A pattern_A(String element_A, [String message_A]) {
  return new CharacterParser(_patternParser.parse_C(element_A).value, message_A != null ? message_A : '[${element_A}] expected');
}
Parser_A _createPatternParser() {
  var single_A = any_A().map((each) => new _RangeCharPredicate(_toCharCode(each), _toCharCode(each)));
  var multiple = any_A().seq(char('-')).seq(any_A()).map((each) => new _RangeCharPredicate(_toCharCode(each[0]), _toCharCode(each[2])));
  var positive = multiple.or(single_A).plus().map((each) => _optimizedRanges(each));
  return char('^').optional().seq(positive).map((each) => each[0] == null ? each[1] : new _NotCharacterPredicate(each[1]));
}
final _patternParser = _createPatternParser();
class _RangesCharPredicate implements CharacterPredicate {
  final int length;
  final List<int> starts;
  final List<int> stops;
  _RangesCharPredicate(this.length, this.starts, this.stops);
  bool test(int value_A) {
    var min_A = 0;
    var max_A = length;
    while (min_A < max_A) {
      var mid = min_A + ((max_A - min_A) >> 1);
      var comp = starts[mid] - value_A;
      if (comp == 0) {
        return true;
      } else if (comp < 0) {
        min_A = mid + 1;
      } else {
        max_A = mid;
      }
    }
    return 0 < min_A && value_A <= stops[min_A - 1];
  }
}
class _RangeCharPredicate implements CharacterPredicate {
  final int start;
  final int stop;
  _RangeCharPredicate(this.start, this.stop);
  bool test(int value_A) => start <= value_A && value_A <= stop;
}
Parser_A whitespace([String message_A]) {
  return new CharacterParser(_whitespaceCharPredicate, message_A != null ? message_A : 'whitespace expected');
}
class _WhitespaceCharPredicate implements CharacterPredicate {
  const _WhitespaceCharPredicate();
  bool test(int value_A) {
    if (value_A < 256) {
      return value_A == 0x09 || value_A == 0x0A || value_A == 0x0B || value_A == 0x0C || value_A == 0x0D || value_A == 0x20 || value_A == 0x85 || value_A == 0xA0;
    } else {
      return value_A == 0x1680 || value_A == 0x180E || value_A == 0x2000 || value_A == 0x2001 || value_A == 0x2002 || value_A == 0x2003 || value_A == 0x2004 || value_A == 0x2005 || value_A == 0x2006 || value_A == 0x2007 || value_A == 0x2008 || value_A == 0x2009 || value_A == 0x200A || value_A == 0x2028 || value_A == 0x2029 || value_A == 0x202F || value_A == 0x205F || value_A == 0x3000 || value_A == 0xFEFF;
    }
  }
}
const _whitespaceCharPredicate = const _WhitespaceCharPredicate();
Parser_A word([String message_A]) {
  return new CharacterParser(_wordCharPredicate, message_A != null ? message_A : 'letter or digit expected');
}
class _WordCharPredicate implements CharacterPredicate {
  const _WordCharPredicate();
  bool test(int value_A) => (65 <= value_A && value_A <= 90) || (97 <= value_A && value_A <= 122) || (48 <= value_A && value_A <= 57) || (value_A == 95);
}
const _wordCharPredicate = const _WordCharPredicate();
int _toCharCode(element_A) {
  if (element_A is num) {
    return element_A.round();
  }
  var value_A = element_A.toString();
  if (value_A.length != 1) {
    throw new ArgumentError('${value_A} is not a character');
  }
  return value_A.codeUnitAt(0);
}
class DelegateParser extends Parser_A {
  Parser_A _delegate_A;
  DelegateParser(this._delegate_A);
  Result parseOn(Context context) {
    return _delegate_A.parseOn(context);
  }
  List<Parser_A> get children => [_delegate_A];
  void replace(Parser_A source_A, Parser_A target) {
    super.replace(source_A, target);
    if (_delegate_A == source_A) {
      _delegate_A = target;
    }
  }
}
class EndOfInputParser extends DelegateParser {
  final String _message;
  EndOfInputParser(parser, this._message) : super(parser);
  Result parseOn(Context context) {
    var result_A = _delegate_A.parseOn(context);
    if (result_A.isFailure || result_A.position == result_A.buffer.length) {
      return result_A;
    }
    return result_A.failure(_message, result_A.position);
  }
  String toString() => '${super.toString()}[${_message}]';
  bool hasEqualProperties(Parser_A other) {
    return other is EndOfInputParser && super.hasEqualProperties(other) && _message == other._message;
  }
}
class OptionalParser extends DelegateParser {
  final _otherwise;
  OptionalParser(parser, this._otherwise) : super(parser);
  Result parseOn(Context context) {
    var result_A = _delegate_A.parseOn(context);
    if (result_A.isSuccess) {
      return result_A;
    } else {
      return context.success(_otherwise);
    }
  }
  bool hasEqualProperties(Parser_A other) {
    return other is OptionalParser && super.hasEqualProperties(other) && _otherwise == other._otherwise;
  }
}
abstract class ListParser extends Parser_A {
  final List<Parser_A> _parsers;
  ListParser(this._parsers);
  List<Parser_A> get children => _parsers;
  void replace(Parser_A source_A, Parser_A target) {
    super.replace(source_A, target);
    for (var i = 0; i < _parsers.length; i++) {
      if (_parsers[i] == source_A) {
        _parsers[i] = target;
      }
    }
  }
}
class ChoiceParser extends ListParser {
  factory ChoiceParser(Iterable<Parser_A> parsers) {
    return new ChoiceParser.__B(new List.from(parsers, growable: false));
  }
  ChoiceParser.__B(parsers) : super(parsers);
  Result parseOn(Context context) {
    var result_A;
    for (var i = 0; i < _parsers.length; i++) {
      result_A = _parsers[i].parseOn(context);
      if (result_A.isSuccess) {
        return result_A;
      }
    }
    return result_A;
  }
  Parser_A or(Parser_A other) {
    return new ChoiceParser(new List()
        ..addAll(_parsers)
        ..add(other));
  }
}
class SequenceParser extends ListParser {
  factory SequenceParser(Iterable<Parser_A> parsers) {
    return new SequenceParser.__C(new List.from(parsers, growable: false));
  }
  SequenceParser.__C(parsers) : super(parsers);
  Result parseOn(Context context) {
    var current_A = context;
    var elements = new List(_parsers.length);
    for (var i = 0; i < _parsers.length; i++) {
      var result_A = _parsers[i].parseOn(current_A);
      if (result_A.isFailure) {
        return result_A;
      }
      elements[i] = result_A.value;
      current_A = result_A;
    }
    return current_A.success(elements);
  }
  Parser_A seq(Parser_A other) {
    return new SequenceParser(new List()
        ..addAll(_parsers)
        ..add(other));
  }
}
class Context {
  const Context(this.buffer, this.position);
  final buffer;
  final int position;
  Result success(result_A, [int position_A]) {
    return new Success(buffer, position_A == null ? this.position : position_A, result_A);
  }
  Result failure(String message_A, [int position_A]) {
    return new Failure(buffer, position_A == null ? this.position : position_A, message_A);
  }
  String toString() => 'Context[${toPositionString()}]';
  String toPositionString() => Token_A.positionString(buffer, position);
}
abstract class Result extends Context {
  const Result(buffer_A, position) : super(buffer_A, position);
  bool get isSuccess => false;
  bool get isFailure => false;
  get value;
  String get message;
}
class Success extends Result {
  const Success(buffer_A, position, this.value) : super(buffer_A, position);
  bool get isSuccess => true;
  final value;
  String get message => null;
  String toString() => 'Success[${toPositionString()}]: ${value}';
}
class Failure extends Result {
  const Failure(buffer_A, position, this.message) : super(buffer_A, position);
  bool get isFailure => true;
  get value => throw new ParserError(this);
  final String message;
  String toString() => 'Failure[${toPositionString()}]: ${message}';
}
class ParserError extends Error {
  final Failure failure;
  ParserError(this.failure);
  String toString() => '${failure.message} at ${failure.toPositionString()}';
}
abstract class GrammarDefinition {
  const GrammarDefinition();
  Parser_A start();
  Parser_A ref(Function function_A, [arg1, arg2, arg3, arg4, arg5, arg6]) {
    var arguments = [arg1, arg2, arg3, arg4, arg5, arg6].takeWhile((each) => each != null).toList(growable: false);
    return new _Reference(function_A, arguments);
  }
  Parser_A build({Function start: null, List arguments: const[]}) {
    return _resolve(new _Reference(start != null ? start : this.start, arguments));
  }
  Parser_A _resolve(_Reference reference) {
    var mapping = new Map();
    Parser_A _dereference(_Reference reference) {
      var parser = mapping[reference];
      if (parser == null) {
        var references = [reference];
        parser = reference.resolve();
        while (parser is _Reference) {
          if (references.contains(parser)) {
            throw new StateError('Recursive references detected: ${references}');
          }
          references.add(parser);
          parser = parser.resolve();
        }
        for (var each in references) {
          mapping[each] = parser;
        }
      }
      return parser;
    }
    var todo = [_dereference(reference)];
    var seen = new Set.from(todo);
    while (todo.isNotEmpty) {
      var parent_A = todo.removeLast();
      for (var child in parent_A.children) {
        if (child is _Reference) {
          var referenced = _dereference(child);
          parent_A.replace(child, referenced);
          child = referenced;
        }
        if (!seen.contains(child)) {
          seen.add(child);
          todo.add(child);
        }
      }
    }
    return mapping[reference];
  }
}
class _Reference extends Parser_A {
  final Function function;
  final List arguments;
  _Reference(this.function, this.arguments);
  Parser_A resolve() => Function.apply(function, arguments);
  bool operator==(other) {
    if (other is! _Reference || other.function != function || other.arguments.length != arguments.length) {
      return false;
    }
    for (var i = 0; i < arguments.length; i++) {
      var a = arguments[i], b = other.arguments[i];
      if (a is Parser_A && a is! _Reference && b is Parser_A && b is! _Reference) {
        if (!a.isEqualTo(b)) {
          return false;
        }
      } else {
        if (a != b) {
          return false;
        }
      }
    }
    return true;
  }
  int get hashCode => function.hashCode;
  Result parseOn(Context context) => throw new UnsupportedError('References cannot be parsed.');
}
abstract class Parser_A {
  Result parseOn(Context context);
  Result parse_C(input_A) {
    return parseOn(new Context(input_A, 0));
  }
  bool accept(input_A) {
    return parse_C(input_A).isSuccess;
  }
  Iterable matchesSkipping(input_A) {
    var list_A = new List();
    map((each) => list_A.add(each)).or(any_A()).star().parse_C(input_A);
    return list_A;
  }
  Parser_A optional([otherwise]) => new OptionalParser(this, otherwise);
  Parser_A star() => repeat(0, unbounded);
  Parser_A starLazy(Parser_A limit) => repeatLazy(limit, 0, unbounded);
  Parser_A plus() => repeat(1, unbounded);
  Parser_A repeat(int min_A, int max_A) {
    return new PossessiveRepeatingParser(this, min_A, max_A);
  }
  Parser_A repeatLazy(Parser_A limit, int min_A, int max_A) {
    return new LazyRepeatingParser(this, limit, min_A, max_A);
  }
  Parser_A seq(Parser_A other) => new SequenceParser([this, other]);
  Parser_A operator&(Parser_A other) => this.seq(other);
  Parser_A or(Parser_A other) => new ChoiceParser([this, other]);
  Parser_A operator|(Parser_A other) => this.or(other);
  Parser_A flatten() => new FlattenParser(this);
  Parser_A token() => new TokenParser(this);
  Parser_A trim([Parser_A left_A, Parser_A right_A]) {
    if (left_A == null) left_A = whitespace();
    if (right_A == null) right_A = left_A;
    return new TrimmingParser(this, left_A, right_A);
  }
  Parser_A end([String message_A = 'end of input expected']) {
    return new EndOfInputParser(this, message_A);
  }
  Parser_A map(Function function_A) => new ActionParser(this, function_A);
  Parser_A pick(int index_A) {
    return this.map((List list_A) {
      return list_A[index_A < 0 ? list_A.length + index_A : index_A];
    });
  }
  Parser_A separatedBy(Parser_A separator, {bool includeSeparators: true, bool optionalSeparatorAtEnd: false}) {
    var repeater = new SequenceParser([separator, this]).star();
    var parser = new SequenceParser(optionalSeparatorAtEnd ? [this, repeater, separator.optional(separator)] : [this, repeater]);
    return parser.map((List list_A) {
      var result_A = new List();
      result_A.add(list_A[0]);
      for (var tuple in list_A[1]) {
        if (includeSeparators) {
          result_A.add(tuple[0]);
        }
        result_A.add(tuple[1]);
      }
      if (includeSeparators && optionalSeparatorAtEnd && !identical(list_A[2], separator)) {
        result_A.add(list_A[2]);
      }
      return result_A;
    });
  }
  bool isEqualTo(Parser_A other, [Set<Parser_A> seen]) {
    if (seen == null) {
      seen = new Set();
    }
    if (this == other || seen.contains(this)) {
      return true;
    }
    seen.add(this);
    return runtimeType == other.runtimeType && hasEqualProperties(other) && hasEqualChildren(other, seen);
  }
  bool hasEqualProperties(Parser_A other) => true;
  bool hasEqualChildren(Parser_A other, Set<Parser_A> seen) {
    var thisChildren = children, otherChildren = other.children;
    if (thisChildren.length != otherChildren.length) {
      return false;
    }
    for (var i = 0; i < thisChildren.length; i++) {
      if (!thisChildren[i].isEqualTo(otherChildren[i], seen)) {
        return false;
      }
    }
    return true;
  }
  List<Parser_A> get children => const[];
  void replace(Parser_A source_A, Parser_A target) {}
}
Parser_A any_A([String message_A = 'input expected']) {
  return new AnyParser(message_A);
}
class AnyParser extends Parser_A {
  final String _message;
  AnyParser(this._message);
  Result parseOn(Context context) {
    var position = context.position;
    var buffer_A = context.buffer;
    return position < buffer_A.length ? context.success(buffer_A[position], position + 1) : context.failure(_message);
  }
  bool hasEqualProperties(Parser_A other) {
    return other is AnyParser && super.hasEqualProperties(other) && _message == other._message;
  }
}
Parser_A string_A(String element_A, [String message_A]) {
  return predicate(element_A.length, (String each) => element_A == each, message_A != null ? message_A : '${element_A} expected');
}
typedef bool Predicate(_0);
Parser_A predicate(int length_A, Predicate predicate_A, String message_A) {
  return new PredicateParser(length_A, predicate_A, message_A);
}
class PredicateParser extends Parser_A {
  final int _length_A;
  final Predicate _predicate;
  final String _message;
  PredicateParser(this._length_A, this._predicate, this._message);
  Result parseOn(Context context) {
    final start_A = context.position;
    final stop_A = start_A + _length_A;
    if (stop_A <= context.buffer.length) {
      var result_A = context.buffer is String ? context.buffer.substring(start_A, stop_A) : context.buffer.sublist(start_A, stop_A);
      if (_predicate(result_A)) {
        return context.success(result_A, stop_A);
      }
    }
    return context.failure(_message);
  }
  String toString() => '${super.toString()}[${_message}]';
  bool hasEqualProperties(Parser_A other) {
    return other is PredicateParser && super.hasEqualProperties(other) && _length_A == other._length_A && _predicate == other._predicate && _message == other._message;
  }
}
const int unbounded = -1;
abstract class RepeatingParser extends DelegateParser {
  final int _min;
  final int _max;
  RepeatingParser(Parser_A parser, this._min, this._max) : super(parser) {
    assert(0 <= _min);
    assert(_max == unbounded || _min <= _max);
  }
  String toString() {
    var max_A = _max == unbounded ? '*' : _max;
    return '${super.toString()}[${_min}..${max_A}]';
  }
  bool hasEqualProperties(Parser_A other) {
    return other is RepeatingParser && super.hasEqualProperties(other) && _min == other._min && _max == other._max;
  }
}
class PossessiveRepeatingParser extends RepeatingParser {
  PossessiveRepeatingParser(Parser_A parser, int min_A, int max_A) : super(parser, min_A, max_A);
  Result parseOn(Context context) {
    var current_A = context;
    var elements = new List();
    while (elements.length < _min) {
      var result_A = _delegate_A.parseOn(current_A);
      if (result_A.isFailure) {
        return result_A;
      }
      elements.add(result_A.value);
      current_A = result_A;
    }
    while (_max == unbounded || elements.length < _max) {
      var result_A = _delegate_A.parseOn(current_A);
      if (result_A.isFailure) {
        return current_A.success(elements);
      }
      elements.add(result_A.value);
      current_A = result_A;
    }
    return current_A.success(elements);
  }
}
abstract class LimitedRepeatingParser extends RepeatingParser {
  Parser_A _limit;
  LimitedRepeatingParser(Parser_A parser, this._limit, int min_A, int max_A) : super(parser, min_A, max_A);
  List<Parser_A> get children => [_delegate_A, _limit];
  void replace(Parser_A source_A, Parser_A target) {
    super.replace(source_A, target);
    if (_limit == source_A) {
      _limit = target;
    }
  }
}
class LazyRepeatingParser extends LimitedRepeatingParser {
  LazyRepeatingParser(Parser_A parser, Parser_A limit, int min_A, int max_A) : super(parser, limit, min_A, max_A);
  Result parseOn(Context context) {
    var current_A = context;
    var elements = new List();
    while (elements.length < _min) {
      var result_A = _delegate_A.parseOn(current_A);
      if (result_A.isFailure) {
        return result_A;
      }
      elements.add(result_A.value);
      current_A = result_A;
    }
    while (true) {
      var limit = _limit.parseOn(current_A);
      if (limit.isSuccess) {
        return current_A.success(elements);
      } else {
        if (_max != unbounded && elements.length >= _max) {
          return limit;
        }
        var result_A = _delegate_A.parseOn(current_A);
        if (result_A.isFailure) {
          return limit;
        }
        elements.add(result_A.value);
        current_A = result_A;
      }
    }
  }
}
class Token_A {
  final value;
  final buffer;
  final int start;
  final int stop;
  const Token_A(this.value, this.buffer, this.start, this.stop);
  get input => buffer is String ? buffer.substring(start, stop) : buffer.sublist(start, stop);
  int get length => stop - start;
  String toString() => 'Token[${positionString(buffer, start)}]: ${value}';
  bool operator==(other) {
    return other is Token_A && value == other.value && start == other.start && stop == other.stop;
  }
  int get hashCode => value.hashCode + start.hashCode + stop.hashCode;
  static Parser_A newlineParser() => _newlineParser;
  static final Parser_A _newlineParser = char('\n') | (char('\r') & char('\n').optional());
  static List<int> lineAndColumnOf(String buffer_A, int position) {
    var line_A = 1, offset_A = 0;
    for (var token in newlineParser().token().matchesSkipping(buffer_A)) {
      if (position < token.stop) {
        return [line_A, position - offset_A + 1];
      }
      line_A++;
      offset_A = token.stop;
    }
    return [line_A, position - offset_A + 1];
  }
  static String positionString(buffer_A, int position) {
    if (buffer_A is String) {
      var lineAndColumn = Token_A.lineAndColumnOf(buffer_A, position);
      return '${lineAndColumn[0]}:${lineAndColumn[1]}';
    } else {
      return '${position}';
    }
  }
}
class DelegatingMap<K, V> implements Map<K, V> {
  final Map<K, V> _base;
  const DelegatingMap(Map<K, V> base_A) : _base = base_A;
  V operator[](Object key_A) => _base[key_A];
  void operator[]=(K key_A, V value_A) {
    _base[key_A] = value_A;
  }
  void addAll(Map<K, V> other) {
    _base.addAll(other);
  }
  void clear() {
    _base.clear();
  }
  bool containsKey(Object key_A) => _base.containsKey(key_A);
  bool containsValue(Object value_A) => _base.containsValue(value_A);
  void forEach(void f(K key, V value)) {
    _base.forEach(f);
  }
  bool get isEmpty => _base.isEmpty;
  bool get isNotEmpty => _base.isNotEmpty;
  Iterable<K> get keys => _base.keys;
  int get length => _base.length;
  V putIfAbsent(K key_A, V ifAbsent()) => _base.putIfAbsent(key_A, ifAbsent);
  V remove(Object key_A) => _base.remove(key_A);
  Iterable<V> get values => _base.values;
  String toString() => _base.toString();
}
final Parser_A _parser = new XmlParserDefinition().build();
XmlDocument parse_B(String input_A) {
  var result_A = _parser.parse_C(input_A);
  if (result_A.isFailure) {
    throw new ArgumentError(new ParserError(result_A).toString());
  }
  return result_A.value;
}
abstract class XmlGrammarDefinition<TNode, TName> extends GrammarDefinition {
  static const NAME_START_CHARS = ':A-Z_a-z\u00C0-\u00D6\u00D8-\u00F6\u00F8-\u02FF' '\u0370-\u037D\u037F-\u1FFF\u200C-\u200D\u2070-\u218F\u2C00-\u2FEF\u3001\uD7FF' '\uF900-\uFDCF\uFDF0-\uFFFD';
  static const NAME_CHARS = '-.0-9\u00B7\u0300-\u036F\u203F-\u2040${NAME_START_CHARS}';
  static const DOUBLE_QUOTE = '"';
  static const SINGLE_QUOTE = "'";
  static const EQUALS = '=';
  static const WHITESPACE = ' ';
  static const OPEN_COMMENT = '<!--';
  static const CLOSE_COMMENT = '-->';
  static const OPEN_CDATA = '<![CDATA[';
  static const CLOSE_CDATA = ']]>';
  static const OPEN_ELEMENT = '<';
  static const CLOSE_ELEMENT = '>';
  static const OPEN_END_ELEMENT = '</';
  static const CLOSE_END_ELEMENT = '/>';
  static const OPEN_DOCTYPE = '<!DOCTYPE';
  static const CLOSE_DOCTYPE = '>';
  static const OPEN_DOCTYPE_BLOCK = '[';
  static const CLOSE_DOCTYPE_BLOCK = ']';
  static const OPEN_PROCESSING = '<?';
  static const CLOSE_PROCESSING = '?>';
  TNode createAttribute(TName name_A, String text);
  TNode createComment(String text);
  TNode createCDATA(String text);
  TNode createDoctype(String text);
  TNode createDocument(Iterable<TNode> children);
  TNode createElement(TName name_A, Iterable<TNode> attributes_A, Iterable<TNode> children);
  TNode createProcessing(String target, String text);
  TName createQualified(String name_A);
  TNode createText(String text);
  start() => ref(document).end();
  attribute() => ref(qualified).seq(ref(space_optional)).seq(char(EQUALS)).seq(ref(space_optional)).seq(ref(attributeValue)).map((each) => createAttribute(each[0], each[4]));
  attributeValue() => ref(attributeValueDouble).or(ref(attributeValueSingle)).pick(1);
  attributeValueDouble() => char(DOUBLE_QUOTE).seq(new _XmlCharacterDataParser(DOUBLE_QUOTE, 0)).seq(char(DOUBLE_QUOTE));
  attributeValueSingle() => char(SINGLE_QUOTE).seq(new _XmlCharacterDataParser(SINGLE_QUOTE, 0)).seq(char(SINGLE_QUOTE));
  attributes() => ref(space).seq(ref(attribute)).pick(1).star();
  comment() => string_A(OPEN_COMMENT).seq(any_A().starLazy(string_A(CLOSE_COMMENT)).flatten()).seq(string_A(CLOSE_COMMENT)).map((each) => createComment(each[1]));
  cdata() => string_A(OPEN_CDATA).seq(any_A().starLazy(string_A(CLOSE_CDATA)).flatten()).seq(string_A(CLOSE_CDATA)).map((each) => createCDATA(each[1]));
  content() => ref(characterData).or(ref(element)).or(ref(processing)).or(ref(comment)).or(ref(cdata)).star();
  doctype() => string_A(OPEN_DOCTYPE).seq(ref(space)).seq(ref(nameToken).or(ref(attributeValue)).or(any_A().starLazy(char(OPEN_DOCTYPE_BLOCK)).seq(char(OPEN_DOCTYPE_BLOCK)).seq(any_A().starLazy(char(CLOSE_DOCTYPE_BLOCK))).seq(char(CLOSE_DOCTYPE_BLOCK))).separatedBy(ref(space)).flatten()).seq(ref(space_optional)).seq(char(CLOSE_DOCTYPE)).map((each) => createDoctype(each[2]));
  document() => ref(processing).optional().seq(ref(misc)).seq(ref(doctype).optional()).seq(ref(misc)).seq(ref(element)).seq(ref(misc)).map((each) => createDocument([each[0], each[2], each[4]].where((each) => each != null)));
  element() => char(OPEN_ELEMENT).seq(ref(qualified)).seq(ref(attributes)).seq(ref(space_optional)).seq(string_A(CLOSE_END_ELEMENT).or(char(CLOSE_ELEMENT).seq(ref(content)).seq(string_A(OPEN_END_ELEMENT)).seq(ref(qualified)).seq(ref(space_optional)).seq(char(CLOSE_ELEMENT)))).map((list_A) {
    if (list_A[4] == CLOSE_END_ELEMENT) {
      return createElement(list_A[1], list_A[2], []);
    } else {
      if (list_A[1] == list_A[4][3]) {
        return createElement(list_A[1], list_A[2], list_A[4][1]);
      } else {
        throw new ArgumentError('Expected </${list_A[1]}>, but found </${list_A[4][3]}>');
      }
    }
  });
  processing() => string_A(OPEN_PROCESSING).seq(ref(nameToken)).seq(ref(space).seq(any_A().starLazy(string_A(CLOSE_PROCESSING)).flatten()).pick(1).optional('')).seq(string_A(CLOSE_PROCESSING)).map((each) => createProcessing(each[1], each[2]));
  qualified() => ref(nameToken).map(createQualified);
  characterData() => new _XmlCharacterDataParser(OPEN_ELEMENT, 1).map(createText);
  misc() => ref(space).or(ref(comment)).or(ref(processing)).star();
  space() => whitespace().plus();
  space_optional() => whitespace().star();
  nameToken() => ref(nameStartChar).seq(ref(nameChar).star()).flatten();
  nameStartChar() => pattern_A(NAME_START_CHARS, 'Expected name');
  nameChar() => pattern_A(NAME_CHARS);
}
class _XmlDescendantsIterable extends IterableBase<XmlNode> {
  final XmlNode start;
  _XmlDescendantsIterable(this.start);
  Iterator<XmlNode> get iterator => new _XmlDescendantsIterator(start);
}
class _XmlDescendantsIterator extends Iterator<XmlNode> {
  final List<XmlNode> todo = new List();
  _XmlDescendantsIterator(XmlNode start_A) {
    push(start_A);
  }
  void push(XmlNode node) {
    todo.addAll(node.children.reversed);
    todo.addAll(node.attributes.reversed);
  }
  XmlNode current;
  bool moveNext() {
    if (todo.isEmpty) {
      current = null;
      return false;
    } else {
      current = todo.removeLast();
      push(current);
      return true;
    }
  }
}
class XmlAttribute extends XmlNode implements XmlNamed {
  final XmlName name;
  final String value;
  XmlAttribute(this.name, this.value) {
    assert(this.name._parent == null);
    this.name._parent = this;
  }
  accept(XmlVisitor visitor) => visitor.visitAttribute(this);
}
class XmlCDATA extends XmlData {
  XmlCDATA(String text) : super(text);
  accept(XmlVisitor visitor) => visitor.visitCDATA(this);
}
class XmlComment extends XmlData {
  XmlComment(String text) : super(text);
  accept(XmlVisitor visitor) => visitor.visitComment(this);
}
abstract class XmlData extends XmlNode {
  final String text;
  XmlData(this.text);
}
class XmlDoctype extends XmlData {
  XmlDoctype(String text) : super(text);
  accept(XmlVisitor visitor) => visitor.visitDoctype(this);
}
class XmlDocument extends XmlParent {
  XmlDocument(Iterable<XmlNode> children) : super(children);
  XmlElement get rootElement {
    return children.firstWhere((node) => node is XmlElement, orElse: () => throw new StateError('Empty XML document'));
  }
  XmlDocument get document => this;
  String get text => null;
  accept(XmlVisitor visitor) => visitor.visitDocument(this);
}
class XmlElement extends XmlParent implements XmlNamed {
  final XmlName name;
  final List<XmlAttribute> attributes;
  XmlElement(XmlName name_A, Iterable<XmlAttribute> attributes_A, Iterable<XmlNode> children) : name = name_A, attributes = attributes_A.toList(growable: false), super(children) {
    assert(this.name._parent == null);
    this.name._parent = this;
    for (var attribute in this.attributes) {
      assert(attribute._parent == null);
      attribute._parent = this;
    }
  }
  String getAttribute(name_A, {String namespace}) {
    var attribute = getAttributeNode(name_A, namespace: namespace);
    return attribute != null ? attribute.value : null;
  }
  XmlAttribute getAttributeNode(String name_A, {String namespace}) {
    return attributes.firstWhere(_createMatcher(name_A, namespace), orElse: () => null);
  }
  accept(XmlVisitor visitor) => visitor.visitElement(this);
}
abstract class XmlNode extends Object with XmlVisitable, XmlWritable, XmlOwned {
  List<XmlAttribute> get attributes => const[];
  List<XmlNode> get children => const[];
  Iterable<XmlNode> get descendants => new _XmlDescendantsIterable(this);
  XmlDocument get document => parent == null ? null : parent.document;
  XmlNode get firstChild => children.isEmpty ? null : children.first;
  String get text {
    return descendants.where((node) => node is XmlText || node is XmlCDATA).map((node) => node.text).join();
  }
}
abstract class XmlParent extends XmlNode {
  final List<XmlNode> children;
  XmlParent(Iterable<XmlNode> children_A) : children = children_A.toList(growable: false) {
    for (var child in this.children) {
      assert(child._parent == null);
      child._parent = this;
    }
  }
}
class XmlProcessing extends XmlData {
  final String target;
  XmlProcessing(this.target, String text) : super(text);
  accept(XmlVisitor visitor) => visitor.visitProcessing(this);
}
class XmlText extends XmlData {
  XmlText(String text) : super(text);
  accept(XmlVisitor visitor) => visitor.visitText(this);
}
class XmlParserDefinition extends XmlGrammarDefinition<XmlNode, XmlName> {
  XmlAttribute createAttribute(XmlName name_A, String text) => new XmlAttribute(name_A, text);
  XmlComment createComment(String text) => new XmlComment(text);
  XmlCDATA createCDATA(String text) => new XmlCDATA(text);
  XmlDoctype createDoctype(String text) => new XmlDoctype(text);
  XmlDocument createDocument(Iterable<XmlNode> children) => new XmlDocument(children);
  XmlElement createElement(XmlName name_A, Iterable<XmlNode> attributes, Iterable<XmlNode> children) {
    return new XmlElement(name_A, attributes, children);
  }
  XmlProcessing createProcessing(String target, String text) => new XmlProcessing(target, text);
  XmlName createQualified(String name_A) => new XmlName.fromString_A(name_A);
  XmlText createText(String text) => new XmlText(text);
}
abstract class XmlOwned {
  XmlNode _parent;
  XmlNode get parent => _parent;
}
final _ENTITY_HEX = pattern_A('xX').seq(pattern_A('A-Fa-f0-9').plus().flatten().map((value_A) {
  return new String.fromCharCode(int.parse(value_A, radix: 16));
})).pick(1);
final _ENTITY_DIGIT = char('#').seq(_ENTITY_HEX.or(digit().plus().flatten().map((value_A) {
  return new String.fromCharCode(int.parse(value_A));
}))).pick(1);
final _ENTITY = char('&').seq(_ENTITY_DIGIT.or(word().plus().flatten().map((value_A) {
  return _ENTITY_TO_CHAR[value_A];
}))).seq(char(';')).pick(1);
class _XmlCharacterDataParser extends Parser_A {
  final String _stopper;
  final int _stopperCode;
  final int _minLength;
  _XmlCharacterDataParser(String stopper, int minLength) : _stopper = stopper, _stopperCode = stopper.codeUnitAt(0), _minLength = minLength;
  Result parseOn(Context context) {
    var input_A = context.buffer;
    var length_A = input_A.length;
    var output = new StringBuffer();
    var position = context.position;
    var start_A = position;
    while (position < length_A) {
      var value_A = input_A.codeUnitAt(position);
      if (value_A == _stopperCode) {
        break;
      } else if (value_A == 38) {
        var result_A = _ENTITY.parseOn(context.success(null, position));
        if (result_A.isSuccess && result_A.value != null) {
          output.write(input_A.substring(start_A, position));
          output.write(result_A.value);
          position = result_A.position;
          start_A = position;
        } else {
          position++;
        }
      } else {
        position++;
      }
    }
    output.write(input_A.substring(start_A, position));
    return output.length < _minLength ? context.failure('Unable to parse chracter data.') : context.success(output.toString(), position);
  }
  List<Parser_A> get children => [_ENTITY];
}
final Map<String, String> _ENTITY_TO_CHAR = const{'lt': '<', 'gt': '>', 'amp': '&', 'apos': "'", 'quot': '"', 'Aacute': '\u00C1', 'aacute': '\u00E1', 'Acirc': '\u00C2', 'acirc': '\u00E2', 'acute': '\u00B4', 'AElig': '\u00C6', 'aelig': '\u00E6', 'Agrave': '\u00C0', 'agrave': '\u00E0', 'alefsym': '\u2135', 'Alpha': '\u0391', 'alpha': '\u03B1', 'and': '\u2227', 'ang': '\u2220', 'Aring': '\u00C5', 'aring': '\u00E5', 'asymp': '\u2248', 'Atilde': '\u00C3', 'atilde': '\u00E3', 'Auml': '\u00C4', 'auml': '\u00E4', 'bdquo': '\u201E', 'Beta': '\u0392', 'beta': '\u03B2', 'brvbar': '\u00A6', 'bull': '\u2022', 'cap': '\u2229', 'Ccedil': '\u00C7', 'ccedil': '\u00E7', 'cedil': '\u00B8', 'cent': '\u00A2', 'Chi': '\u03A7', 'chi': '\u03C7', 'circ': '\u02C6', 'clubs': '\u2663', 'cong': '\u2245', 'copy': '\u00A9', 'crarr': '\u21B5', 'cup': '\u222A', 'curren': '\u00A4', 'dagger': '\u2020', 'Dagger': '\u2021', 'darr': '\u2193', 'dArr': '\u21D3', 'deg': '\u00B0', 'Delta': '\u0394', 'delta': '\u03B4', 'diams': '\u2666', 'divide': '\u00F7', 'Eacute': '\u00C9', 'eacute': '\u00E9', 'Ecirc': '\u00CA', 'ecirc': '\u00EA', 'Egrave': '\u00C8', 'egrave': '\u00E8', 'empty': '\u2205', 'emsp': '\u2003', 'ensp': '\u2002', 'Epsilon': '\u0395', 'epsilon': '\u03B5', 'equiv': '\u2261', 'Eta': '\u0397', 'eta': '\u03B7', 'ETH': '\u00D0', 'eth': '\u00F0', 'Euml': '\u00CB', 'euml': '\u00EB', 'euro': '\u20AC', 'exist': '\u2203', 'fnof': '\u0192', 'forall': '\u2200', 'frac12': '\u00BD', 'frac14': '\u00BC', 'frac34': '\u00BE', 'frasl': '\u2044', 'Gamma': '\u0393', 'gamma': '\u03B3', 'ge': '\u2265', 'harr': '\u2194', 'hArr': '\u21D4', 'hearts': '\u2665', 'hellip': '\u2026', 'Iacute': '\u00CD', 'iacute': '\u00ED', 'Icirc': '\u00CE', 'icirc': '\u00EE', 'iexcl': '\u00A1', 'Igrave': '\u00CC', 'igrave': '\u00EC', 'image': '\u2111', 'infin': '\u221E', 'int': '\u222B', 'Iota': '\u0399', 'iota': '\u03B9', 'iquest': '\u00BF', 'isin': '\u2208', 'Iuml': '\u00CF', 'iuml': '\u00EF', 'Kappa': '\u039A', 'kappa': '\u03BA', 'Lambda': '\u039B', 'lambda': '\u03BB', 'lang': '\u2329', 'laquo': '\u00AB', 'larr': '\u2190', 'lArr': '\u21D0', 'lceil': '\u2308', 'ldquo': '\u201C', 'le': '\u2264', 'lfloor': '\u230A', 'lowast': '\u2217', 'loz': '\u25CA', 'lrm': '\u200E', 'lsaquo': '\u2039', 'lsquo': '\u2018', 'macr': '\u00AF', 'mdash': '\u2014', 'micro': '\u00B5', 'middot': '\u00B7', 'minus': '\u2212', 'Mu': '\u039C', 'mu': '\u03BC', 'nabla': '\u2207', 'nbsp': '\u00A0', 'ndash': '\u2013', 'ne': '\u2260', 'ni': '\u220B', 'not': '\u00AC', 'notin': '\u2209', 'nsub': '\u2284', 'Ntilde': '\u00D1', 'ntilde': '\u00F1', 'Nu': '\u039D', 'nu': '\u03BD', 'Oacute': '\u00D3', 'oacute': '\u00F3', 'Ocirc': '\u00D4', 'ocirc': '\u00F4', 'OElig': '\u0152', 'oelig': '\u0153', 'Ograve': '\u00D2', 'ograve': '\u00F2', 'oline': '\u203E', 'Omega': '\u03A9', 'omega': '\u03C9', 'Omicron': '\u039F', 'omicron': '\u03BF', 'oplus': '\u2295', 'or': '\u2228', 'ordf': '\u00AA', 'ordm': '\u00BA', 'Oslash': '\u00D8', 'oslash': '\u00F8', 'Otilde': '\u00D5', 'otilde': '\u00F5', 'otimes': '\u2297', 'Ouml': '\u00D6', 'ouml': '\u00F6', 'para': '\u00B6', 'part': '\u2202', 'permil': '\u2030', 'perp': '\u22A5', 'Phi': '\u03A6', 'phi': '\u03C6', 'Pi': '\u03A0', 'pi': '\u03C0', 'piv': '\u03D6', 'plusmn': '\u00B1', 'pound': '\u00A3', 'prime': '\u2032', 'Prime': '\u2033', 'prod': '\u220F', 'prop': '\u221D', 'Psi': '\u03A8', 'psi': '\u03C8', 'radic': '\u221A', 'rang': '\u232A', 'raquo': '\u00BB', 'rarr': '\u2192', 'rArr': '\u21D2', 'rceil': '\u2309', 'rdquo': '\u201D', 'real': '\u211C', 'reg': '\u00AE', 'rfloor': '\u230B', 'Rho': '\u03A1', 'rho': '\u03C1', 'rlm': '\u200F', 'rsaquo': '\u203A', 'rsquo': '\u2019', 'sbquo': '\u201A', 'Scaron': '\u0160', 'scaron': '\u0161', 'sdot': '\u22C5', 'sect': '\u00A7', 'shy': '\u00AD', 'Sigma': '\u03A3', 'sigma': '\u03C3', 'sigmaf': '\u03C2', 'sim': '\u223C', 'spades': '\u2660', 'sub': '\u2282', 'sube': '\u2286', 'sum': '\u2211', 'sup': '\u2283', 'sup1': '\u00B9', 'sup2': '\u00B2', 'sup3': '\u00B3', 'supe': '\u2287', 'szlig': '\u00DF', 'Tau': '\u03A4', 'tau': '\u03C4', 'there4': '\u2234', 'Theta': '\u0398', 'theta': '\u03B8', 'thetasym': '\u03D1', 'thinsp': '\u2009', 'THORN': '\u00DE', 'thorn': '\u00FE', 'tilde': '\u02DC', 'times': '\u00D7', 'trade': '\u2122', 'Uacute': '\u00DA', 'uacute': '\u00FA', 'uarr': '\u2191', 'uArr': '\u21D1', 'Ucirc': '\u00DB', 'ucirc': '\u00FB', 'Ugrave': '\u00D9', 'ugrave': '\u00F9', 'uml': '\u00A8', 'upsih': '\u03D2', 'Upsilon': '\u03A5', 'upsilon': '\u03C5', 'Uuml': '\u00DC', 'uuml': '\u00FC', 'weierp': '\u2118', 'Xi': '\u039E', 'xi': '\u03BE', 'Yacute': '\u00DD', 'yacute': '\u00FD', 'yen': '\u00A5', 'yuml': '\u00FF', 'Yuml': '\u0178', 'Zeta': '\u0396', 'zeta': '\u03B6', 'zwj': '\u200D', 'zwnj': '\u200C'};
String _encodeXmlText(String input_A) {
  return input_A.replaceAllMapped(_TEXT_PATTERN, (match) {
    return match.group(0) == '<' ? '&lt;' : '&amp;';
  });
}
final Pattern _TEXT_PATTERN = new RegExp(r'[&<]');
String _encodeXmlAttributeValue(String input_A) {
  return input_A.replaceAllMapped(_ATTRIBUTE_PATTERN, (match) {
    switch (match.group(0)) {
      case '"':
        return '&quot;';

      case '&':
        return '&amp;';

      case '<':
        return '&lt;';
    }
  });
}
final Pattern _ATTRIBUTE_PATTERN = new RegExp(r'["&<]');
const _SEPARATOR = ':';
const _XMLNS = 'xmlns';
abstract class XmlName extends Object with XmlVisitable, XmlWritable, XmlOwned {
  String get prefix;
  String get local;
  String get qualified;
  String get namespaceUri;
  factory XmlName.fromString_A(String qualified_A) {
    var index_A = qualified_A.indexOf(_SEPARATOR);
    if (index_A > 0) {
      var prefix_A = qualified_A.substring(0, index_A);
      var local_A = qualified_A.substring(index_A + 1, qualified_A.length);
      return new _XmlPrefixName(prefix_A, local_A, qualified_A);
    } else {
      return new _XmlSimpleName(qualified_A);
    }
  }
  XmlName.__D();
  accept(XmlVisitor visitor) => visitor.visitName(this);
  bool operator==(other) => other is XmlName && other.local == local && other.namespaceUri == namespaceUri;
  int get hashCode => qualified.hashCode;
}
class _XmlSimpleName extends XmlName {
  String get prefix => null;
  final String local;
  String get qualified => local;
  String get namespaceUri {
    for (var node = parent; node != null; node = node.parent) {
      for (var attribute in node.attributes) {
        if (attribute.name.prefix == null && attribute.name.local == _XMLNS) {
          return attribute.value;
        }
      }
    }
    return null;
  }
  _XmlSimpleName(this.local) : super.__D();
}
class _XmlPrefixName extends XmlName {
  final String prefix;
  final String local;
  final String qualified;
  String get namespaceUri {
    for (var node = parent; node != null; node = node.parent) {
      for (var attribute in node.attributes) {
        if (attribute.name.prefix == _XMLNS && attribute.name.local == prefix) {
          return attribute.value;
        }
      }
    }
    return null;
  }
  _XmlPrefixName(this.prefix, this.local, this.qualified) : super.__D();
}
abstract class XmlNamed {}
typedef bool _XmlNamedMatcher(XmlNamed _0);
_XmlNamedMatcher _createMatcher(String name_A, String namespace) {
  if (name_A == null) {
    throw new ArgumentError('Illegal name matcher.');
  } else if (name_A == '*') {
    if (namespace == null || namespace == '*') {
      return (XmlNamed named) => true;
    } else {
      return (XmlNamed named) => named.name.namespaceUri == namespace;
    }
  } else {
    if (namespace == null) {
      return (XmlNamed named) => named.name.qualified == name_A;
    } else if (namespace == '*') {
      return (XmlNamed named) => named.name.local == name_A;
    } else {
      return (XmlNamed named) => named.name.local == name_A && named.name.namespaceUri == namespace;
    }
  }
}
abstract class XmlWritable implements XmlVisitable {
  void writeTo(StringBuffer buffer_A) {
    new XmlWriter(buffer_A).visit(this);
  }
  void writePrettyTo(StringBuffer buffer_A, int level, String indent_A) {
    new XmlPrettyWriter(buffer_A, level, indent_A).visit(this);
  }
  String toString() => toXmlString();
  String toXmlString({bool pretty: false, String indent: '  '}) {
    var buffer_A = new StringBuffer();
    if (pretty) {
      writePrettyTo(buffer_A, 0, indent);
    } else {
      writeTo(buffer_A);
    }
    return buffer_A.toString();
  }
}
abstract class XmlVisitable {
  accept(XmlVisitor visitor);
}
abstract class XmlVisitor {
  visit(XmlVisitable visitable) => visitable.accept(this);
  visitName(XmlName name_A);
  visitAttribute(XmlAttribute node);
  visitDocument(XmlDocument node);
  visitElement(XmlElement node);
  visitCDATA(XmlCDATA node);
  visitComment(XmlComment node);
  visitDoctype(XmlDoctype node);
  visitProcessing(XmlProcessing node);
  visitText(XmlText node);
}
class XmlWriter extends XmlVisitor {
  final StringBuffer buffer;
  XmlWriter(this.buffer);
  visitAttribute(XmlAttribute node) {
    visit(node.name);
    buffer.write(XmlGrammarDefinition.EQUALS);
    buffer.write(XmlGrammarDefinition.DOUBLE_QUOTE);
    buffer.write(_encodeXmlAttributeValue(node.value));
    buffer.write(XmlGrammarDefinition.DOUBLE_QUOTE);
  }
  visitCDATA(XmlCDATA node) {
    buffer.write(XmlGrammarDefinition.OPEN_CDATA);
    buffer.write(node.text);
    buffer.write(XmlGrammarDefinition.CLOSE_CDATA);
  }
  visitComment(XmlComment node) {
    buffer.write(XmlGrammarDefinition.OPEN_COMMENT);
    buffer.write(node.text);
    buffer.write(XmlGrammarDefinition.CLOSE_COMMENT);
  }
  visitDoctype(XmlDoctype node) {
    buffer.write(XmlGrammarDefinition.OPEN_DOCTYPE);
    buffer.write(XmlGrammarDefinition.WHITESPACE);
    buffer.write(node.text);
    buffer.write(XmlGrammarDefinition.CLOSE_DOCTYPE);
  }
  visitDocument(XmlDocument node) {
    writeChildren(node);
  }
  visitElement(XmlElement node) {
    buffer.write(XmlGrammarDefinition.OPEN_ELEMENT);
    visit(node.name);
    writeAttributes(node);
    if (node.children.isEmpty) {
      buffer.write(XmlGrammarDefinition.WHITESPACE);
      buffer.write(XmlGrammarDefinition.CLOSE_END_ELEMENT);
    } else {
      buffer.write(XmlGrammarDefinition.CLOSE_ELEMENT);
      writeChildren(node);
      buffer.write(XmlGrammarDefinition.OPEN_END_ELEMENT);
      visit(node.name);
      buffer.write(XmlGrammarDefinition.CLOSE_ELEMENT);
    }
  }
  visitName(XmlName name_A) {
    buffer.write(name_A.qualified);
  }
  visitProcessing(XmlProcessing node) {
    buffer.write(XmlGrammarDefinition.OPEN_PROCESSING);
    buffer.write(node.target);
    if (!node.text.isEmpty) {
      buffer.write(XmlGrammarDefinition.WHITESPACE);
      buffer.write(node.text);
    }
    buffer.write(XmlGrammarDefinition.CLOSE_PROCESSING);
  }
  visitText(XmlText node) {
    buffer.write(_encodeXmlText(node.text));
  }
  writeAttributes(XmlNode node) {
    for (var attribute in node.attributes) {
      buffer.write(XmlGrammarDefinition.WHITESPACE);
      visit(attribute);
    }
  }
  writeChildren(XmlNode node) {
    for (var child in node.children) {
      visit(child);
    }
  }
}
class XmlPrettyWriter extends XmlWriter {
  int level = 0;
  final String indent;
  XmlPrettyWriter(buffer_A, this.level, this.indent) : super(buffer_A);
  visitCDATA(XmlCDATA node) {
    newLine();
    super.visitCDATA(node);
  }
  visitComment(XmlComment node) {
    newLine();
    super.visitComment(node);
  }
  visitDoctype(XmlDoctype node) {
    newLine();
    super.visitDoctype(node);
  }
  visitElement(XmlElement node) {
    newLine();
    buffer.write(XmlGrammarDefinition.OPEN_ELEMENT);
    visit(node.name);
    writeAttributes(node);
    if (node.children.isEmpty) {
      buffer.write(XmlGrammarDefinition.WHITESPACE);
      buffer.write(XmlGrammarDefinition.CLOSE_END_ELEMENT);
    } else {
      buffer.write(XmlGrammarDefinition.CLOSE_ELEMENT);
      level++;
      writeChildren(node);
      level--;
      if (!node.children.every((each) => each is XmlText)) {
        newLine();
      }
      buffer.write(XmlGrammarDefinition.OPEN_END_ELEMENT);
      visit(node.name);
      buffer.write(XmlGrammarDefinition.CLOSE_ELEMENT);
    }
  }
  visitProcessing(XmlProcessing node) {
    newLine();
    super.visitProcessing(node);
  }
  visitText(XmlText node) {
    if (node.text.trim().isNotEmpty) {
      super.visitText(node);
    }
  }
  void newLine() {
    if (buffer.isNotEmpty) {
      buffer.writeln();
    }
    for (int i = 0; i < level; i++) {
      buffer.write(indent);
    }
  }
}
