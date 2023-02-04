// ignore_for_file: unnecessary_null_comparison, non_constant_identifier_names, unused_element

part of security_module;

// This is the ported version of PHP phpAES library
// http://www.phpaes.com
// https://github.com/phillipsdata/phpaes
//
// Performance measurements on Intel Xeon E5420:
//
// This implementation is about 40 times faster than 'pointycastle' Dart lib
// on 1 Mb data (1,4 vs 55-65 seconds), about 80 times faster on 2 Mb data
// (2,7 vs 200-240 seconds), and so on.

class Encrypter {
  static const SECURE_APP = 0x00002000;
  static const NON_SECURE_APP = 0x00000000;

  static encrypt(String data) {
    return base64Encode(data.toUtf16Bytes(Endian.little));
  }

  static decrypt(String data) {
    return base64Decode(data).toUtf16String(Endian.little);
  }
}

class _Aes {
  // The S-Box substitution table.
  static final Uint8List _sBox = Uint8List.fromList([
    0x63,
    0x7c,
    0x77,
    0x7b,
    0xf2,
    0x6b,
    0x6f,
    0xc5,
    0x30,
    0x01,
    0x67,
    0x2b,
    0xfe,
    0xd7,
    0xab,
    0x76,
    0xca,
    0x82,
    0xc9,
    0x7d,
    0xfa,
    0x59,
    0x47,
    0xf0,
    0xad,
    0xd4,
    0xa2,
    0xaf,
    0x9c,
    0xa4,
    0x72,
    0xc0,
    0xb7,
    0xfd,
    0x93,
    0x26,
    0x36,
    0x3f,
    0xf7,
    0xcc,
    0x34,
    0xa5,
    0xe5,
    0xf1,
    0x71,
    0xd8,
    0x31,
    0x15,
    0x04,
    0xc7,
    0x23,
    0xc3,
    0x18,
    0x96,
    0x05,
    0x9a,
    0x07,
    0x12,
    0x80,
    0xe2,
    0xeb,
    0x27,
    0xb2,
    0x75,
    0x09,
    0x83,
    0x2c,
    0x1a,
    0x1b,
    0x6e,
    0x5a,
    0xa0,
    0x52,
    0x3b,
    0xd6,
    0xb3,
    0x29,
    0xe3,
    0x2f,
    0x84,
    0x53,
    0xd1,
    0x00,
    0xed,
    0x20,
    0xfc,
    0xb1,
    0x5b,
    0x6a,
    0xcb,
    0xbe,
    0x39,
    0x4a,
    0x4c,
    0x58,
    0xcf,
    0xd0,
    0xef,
    0xaa,
    0xfb,
    0x43,
    0x4d,
    0x33,
    0x85,
    0x45,
    0xf9,
    0x02,
    0x7f,
    0x50,
    0x3c,
    0x9f,
    0xa8,
    0x51,
    0xa3,
    0x40,
    0x8f,
    0x92,
    0x9d,
    0x38,
    0xf5,
    0xbc,
    0xb6,
    0xda,
    0x21,
    0x10,
    0xff,
    0xf3,
    0xd2,
    0xcd,
    0x0c,
    0x13,
    0xec,
    0x5f,
    0x97,
    0x44,
    0x17,
    0xc4,
    0xa7,
    0x7e,
    0x3d,
    0x64,
    0x5d,
    0x19,
    0x73,
    0x60,
    0x81,
    0x4f,
    0xdc,
    0x22,
    0x2a,
    0x90,
    0x88,
    0x46,
    0xee,
    0xb8,
    0x14,
    0xde,
    0x5e,
    0x0b,
    0xdb,
    0xe0,
    0x32,
    0x3a,
    0x0a,
    0x49,
    0x06,
    0x24,
    0x5c,
    0xc2,
    0xd3,
    0xac,
    0x62,
    0x91,
    0x95,
    0xe4,
    0x79,
    0xe7,
    0xc8,
    0x37,
    0x6d,
    0x8d,
    0xd5,
    0x4e,
    0xa9,
    0x6c,
    0x56,
    0xf4,
    0xea,
    0x65,
    0x7a,
    0xae,
    0x08,
    0xba,
    0x78,
    0x25,
    0x2e,
    0x1c,
    0xa6,
    0xb4,
    0xc6,
    0xe8,
    0xdd,
    0x74,
    0x1f,
    0x4b,
    0xbd,
    0x8b,
    0x8a,
    0x70,
    0x3e,
    0xb5,
    0x66,
    0x48,
    0x03,
    0xf6,
    0x0e,
    0x61,
    0x35,
    0x57,
    0xb9,
    0x86,
    0xc1,
    0x1d,
    0x9e,
    0xe1,
    0xf8,
    0x98,
    0x11,
    0x69,
    0xd9,
    0x8e,
    0x94,
    0x9b,
    0x1e,
    0x87,
    0xe9,
    0xce,
    0x55,
    0x28,
    0xdf,
    0x8c,
    0xa1,
    0x89,
    0x0d,
    0xbf,
    0xe6,
    0x42,
    0x68,
    0x41,
    0x99,
    0x2d,
    0x0f,
    0xb0,
    0x54,
    0xbb,
    0x16
  ]);

  // The inverse S-Box substitution table.
  static final Uint8List _invSBox = Uint8List.fromList([
    0x52,
    0x09,
    0x6a,
    0xd5,
    0x30,
    0x36,
    0xa5,
    0x38,
    0xbf,
    0x40,
    0xa3,
    0x9e,
    0x81,
    0xf3,
    0xd7,
    0xfb,
    0x7c,
    0xe3,
    0x39,
    0x82,
    0x9b,
    0x2f,
    0xff,
    0x87,
    0x34,
    0x8e,
    0x43,
    0x44,
    0xc4,
    0xde,
    0xe9,
    0xcb,
    0x54,
    0x7b,
    0x94,
    0x32,
    0xa6,
    0xc2,
    0x23,
    0x3d,
    0xee,
    0x4c,
    0x95,
    0x0b,
    0x42,
    0xfa,
    0xc3,
    0x4e,
    0x08,
    0x2e,
    0xa1,
    0x66,
    0x28,
    0xd9,
    0x24,
    0xb2,
    0x76,
    0x5b,
    0xa2,
    0x49,
    0x6d,
    0x8b,
    0xd1,
    0x25,
    0x72,
    0xf8,
    0xf6,
    0x64,
    0x86,
    0x68,
    0x98,
    0x16,
    0xd4,
    0xa4,
    0x5c,
    0xcc,
    0x5d,
    0x65,
    0xb6,
    0x92,
    0x6c,
    0x70,
    0x48,
    0x50,
    0xfd,
    0xed,
    0xb9,
    0xda,
    0x5e,
    0x15,
    0x46,
    0x57,
    0xa7,
    0x8d,
    0x9d,
    0x84,
    0x90,
    0xd8,
    0xab,
    0x00,
    0x8c,
    0xbc,
    0xd3,
    0x0a,
    0xf7,
    0xe4,
    0x58,
    0x05,
    0xb8,
    0xb3,
    0x45,
    0x06,
    0xd0,
    0x2c,
    0x1e,
    0x8f,
    0xca,
    0x3f,
    0x0f,
    0x02,
    0xc1,
    0xaf,
    0xbd,
    0x03,
    0x01,
    0x13,
    0x8a,
    0x6b,
    0x3a,
    0x91,
    0x11,
    0x41,
    0x4f,
    0x67,
    0xdc,
    0xea,
    0x97,
    0xf2,
    0xcf,
    0xce,
    0xf0,
    0xb4,
    0xe6,
    0x73,
    0x96,
    0xac,
    0x74,
    0x22,
    0xe7,
    0xad,
    0x35,
    0x85,
    0xe2,
    0xf9,
    0x37,
    0xe8,
    0x1c,
    0x75,
    0xdf,
    0x6e,
    0x47,
    0xf1,
    0x1a,
    0x71,
    0x1d,
    0x29,
    0xc5,
    0x89,
    0x6f,
    0xb7,
    0x62,
    0x0e,
    0xaa,
    0x18,
    0xbe,
    0x1b,
    0xfc,
    0x56,
    0x3e,
    0x4b,
    0xc6,
    0xd2,
    0x79,
    0x20,
    0x9a,
    0xdb,
    0xc0,
    0xfe,
    0x78,
    0xcd,
    0x5a,
    0xf4,
    0x1f,
    0xdd,
    0xa8,
    0x33,
    0x88,
    0x07,
    0xc7,
    0x31,
    0xb1,
    0x12,
    0x10,
    0x59,
    0x27,
    0x80,
    0xec,
    0x5f,
    0x60,
    0x51,
    0x7f,
    0xa9,
    0x19,
    0xb5,
    0x4a,
    0x0d,
    0x2d,
    0xe5,
    0x7a,
    0x9f,
    0x93,
    0xc9,
    0x9c,
    0xef,
    0xa0,
    0xe0,
    0x3b,
    0x4d,
    0xae,
    0x2a,
    0xf5,
    0xb0,
    0xc8,
    0xeb,
    0xbb,
    0x3c,
    0x83,
    0x53,
    0x99,
    0x61,
    0x17,
    0x2b,
    0x04,
    0x7e,
    0xba,
    0x77,
    0xd6,
    0x26,
    0xe1,
    0x69,
    0x14,
    0x63,
    0x55,
    0x21,
    0x0c,
    0x7d
  ]);

  // Log table based on 0xe5
  static final Uint8List _ltable = Uint8List.fromList([
    0x00,
    0xff,
    0xc8,
    0x08,
    0x91,
    0x10,
    0xd0,
    0x36,
    0x5a,
    0x3e,
    0xd8,
    0x43,
    0x99,
    0x77,
    0xfe,
    0x18,
    0x23,
    0x20,
    0x07,
    0x70,
    0xa1,
    0x6c,
    0x0c,
    0x7f,
    0x62,
    0x8b,
    0x40,
    0x46,
    0xc7,
    0x4b,
    0xe0,
    0x0e,
    0xeb,
    0x16,
    0xe8,
    0xad,
    0xcf,
    0xcd,
    0x39,
    0x53,
    0x6a,
    0x27,
    0x35,
    0x93,
    0xd4,
    0x4e,
    0x48,
    0xc3,
    0x2b,
    0x79,
    0x54,
    0x28,
    0x09,
    0x78,
    0x0f,
    0x21,
    0x90,
    0x87,
    0x14,
    0x2a,
    0xa9,
    0x9c,
    0xd6,
    0x74,
    0xb4,
    0x7c,
    0xde,
    0xed,
    0xb1,
    0x86,
    0x76,
    0xa4,
    0x98,
    0xe2,
    0x96,
    0x8f,
    0x02,
    0x32,
    0x1c,
    0xc1,
    0x33,
    0xee,
    0xef,
    0x81,
    0xfd,
    0x30,
    0x5c,
    0x13,
    0x9d,
    0x29,
    0x17,
    0xc4,
    0x11,
    0x44,
    0x8c,
    0x80,
    0xf3,
    0x73,
    0x42,
    0x1e,
    0x1d,
    0xb5,
    0xf0,
    0x12,
    0xd1,
    0x5b,
    0x41,
    0xa2,
    0xd7,
    0x2c,
    0xe9,
    0xd5,
    0x59,
    0xcb,
    0x50,
    0xa8,
    0xdc,
    0xfc,
    0xf2,
    0x56,
    0x72,
    0xa6,
    0x65,
    0x2f,
    0x9f,
    0x9b,
    0x3d,
    0xba,
    0x7d,
    0xc2,
    0x45,
    0x82,
    0xa7,
    0x57,
    0xb6,
    0xa3,
    0x7a,
    0x75,
    0x4f,
    0xae,
    0x3f,
    0x37,
    0x6d,
    0x47,
    0x61,
    0xbe,
    0xab,
    0xd3,
    0x5f,
    0xb0,
    0x58,
    0xaf,
    0xca,
    0x5e,
    0xfa,
    0x85,
    0xe4,
    0x4d,
    0x8a,
    0x05,
    0xfb,
    0x60,
    0xb7,
    0x7b,
    0xb8,
    0x26,
    0x4a,
    0x67,
    0xc6,
    0x1a,
    0xf8,
    0x69,
    0x25,
    0xb3,
    0xdb,
    0xbd,
    0x66,
    0xdd,
    0xf1,
    0xd2,
    0xdf,
    0x03,
    0x8d,
    0x34,
    0xd9,
    0x92,
    0x0d,
    0x63,
    0x55,
    0xaa,
    0x49,
    0xec,
    0xbc,
    0x95,
    0x3c,
    0x84,
    0x0b,
    0xf5,
    0xe6,
    0xe7,
    0xe5,
    0xac,
    0x7e,
    0x6e,
    0xb9,
    0xf9,
    0xda,
    0x8e,
    0x9a,
    0xc9,
    0x24,
    0xe1,
    0x0a,
    0x15,
    0x6b,
    0x3a,
    0xa0,
    0x51,
    0xf4,
    0xea,
    0xb2,
    0x97,
    0x9e,
    0x5d,
    0x22,
    0x88,
    0x94,
    0xce,
    0x19,
    0x01,
    0x71,
    0x4c,
    0xa5,
    0xe3,
    0xc5,
    0x31,
    0xbb,
    0xcc,
    0x1f,
    0x2d,
    0x3b,
    0x52,
    0x6f,
    0xf6,
    0x2e,
    0x89,
    0xf7,
    0xc0,
    0x68,
    0x1b,
    0x64,
    0x04,
    0x06,
    0xbf,
    0x83,
    0x38
  ]);

  // Inverse log table
  static final Uint8List _atable = Uint8List.fromList([
    0x01,
    0xe5,
    0x4c,
    0xb5,
    0xfb,
    0x9f,
    0xfc,
    0x12,
    0x03,
    0x34,
    0xd4,
    0xc4,
    0x16,
    0xba,
    0x1f,
    0x36,
    0x05,
    0x5c,
    0x67,
    0x57,
    0x3a,
    0xd5,
    0x21,
    0x5a,
    0x0f,
    0xe4,
    0xa9,
    0xf9,
    0x4e,
    0x64,
    0x63,
    0xee,
    0x11,
    0x37,
    0xe0,
    0x10,
    0xd2,
    0xac,
    0xa5,
    0x29,
    0x33,
    0x59,
    0x3b,
    0x30,
    0x6d,
    0xef,
    0xf4,
    0x7b,
    0x55,
    0xeb,
    0x4d,
    0x50,
    0xb7,
    0x2a,
    0x07,
    0x8d,
    0xff,
    0x26,
    0xd7,
    0xf0,
    0xc2,
    0x7e,
    0x09,
    0x8c,
    0x1a,
    0x6a,
    0x62,
    0x0b,
    0x5d,
    0x82,
    0x1b,
    0x8f,
    0x2e,
    0xbe,
    0xa6,
    0x1d,
    0xe7,
    0x9d,
    0x2d,
    0x8a,
    0x72,
    0xd9,
    0xf1,
    0x27,
    0x32,
    0xbc,
    0x77,
    0x85,
    0x96,
    0x70,
    0x08,
    0x69,
    0x56,
    0xdf,
    0x99,
    0x94,
    0xa1,
    0x90,
    0x18,
    0xbb,
    0xfa,
    0x7a,
    0xb0,
    0xa7,
    0xf8,
    0xab,
    0x28,
    0xd6,
    0x15,
    0x8e,
    0xcb,
    0xf2,
    0x13,
    0xe6,
    0x78,
    0x61,
    0x3f,
    0x89,
    0x46,
    0x0d,
    0x35,
    0x31,
    0x88,
    0xa3,
    0x41,
    0x80,
    0xca,
    0x17,
    0x5f,
    0x53,
    0x83,
    0xfe,
    0xc3,
    0x9b,
    0x45,
    0x39,
    0xe1,
    0xf5,
    0x9e,
    0x19,
    0x5e,
    0xb6,
    0xcf,
    0x4b,
    0x38,
    0x04,
    0xb9,
    0x2b,
    0xe2,
    0xc1,
    0x4a,
    0xdd,
    0x48,
    0x0c,
    0xd0,
    0x7d,
    0x3d,
    0x58,
    0xde,
    0x7c,
    0xd8,
    0x14,
    0x6b,
    0x87,
    0x47,
    0xe8,
    0x79,
    0x84,
    0x73,
    0x3c,
    0xbd,
    0x92,
    0xc9,
    0x23,
    0x8b,
    0x97,
    0x95,
    0x44,
    0xdc,
    0xad,
    0x40,
    0x65,
    0x86,
    0xa2,
    0xa4,
    0xcc,
    0x7f,
    0xec,
    0xc0,
    0xaf,
    0x91,
    0xfd,
    0xf7,
    0x4f,
    0x81,
    0x2f,
    0x5b,
    0xea,
    0xa8,
    0x1c,
    0x02,
    0xd1,
    0x98,
    0x71,
    0xed,
    0x25,
    0xe3,
    0x24,
    0x06,
    0x68,
    0xb3,
    0x93,
    0x2c,
    0x6f,
    0x3e,
    0x6c,
    0x0a,
    0xb8,
    0xce,
    0xae,
    0x74,
    0xb1,
    0x42,
    0xb4,
    0x1e,
    0xd3,
    0x49,
    0xe9,
    0x9c,
    0xc8,
    0xc6,
    0xc7,
    0x22,
    0x6e,
    0xdb,
    0x20,
    0xbf,
    0x43,
    0x51,
    0x52,
    0x66,
    0xb2,
    0x76,
    0x60,
    0xda,
    0xc5,
    0xf3,
    0xf6,
    0xaa,
    0xcd,
    0x9a,
    0xa0,
    0x75,
    0x54,
    0x0e,
    0x01
  ]);

  // The number of 32-bit words comprising the plaintext and columns comprising the state matrix of an AES cipher.
  static const int _Nb = 4;

  // The number of 32-bit words comprising the cipher key in this AES cipher.
  late int _Nk;

  // The number of rounds in this AES cipher.
  int? _Nr;

  // The key schedule in this AES cipher.
  late Uint32List _w; // _Nb*(_Nr+1) 32-bit words
  // The state matrix in this AES cipher with _Nb columns and 4 rows
  // [[0,0,0,...], [0,0,0,...], [0,0,0,...], [0,0,0,...]];
  final List<Uint8List> _s = List.generate(
      4, (i) => Uint8List(4),
      growable: false);

  // The block cipher mode of operation
  late AesMode _aesMode;

  // The encryption key
  late Uint8List _aesKey;

  // The initialization vector used in advanced cipher modes
  late Uint8List _aesIV;

  _Aes() {
    _aesMode = AesMode.cbc;
    _aesIV = Uint8List(0);
    _aesKey = Uint8List(0);
  }

  // Returns AES initialization vector
  Uint8List getIV() => _aesIV;

  // Returns AES encryption key
  Uint8List getKey() => _aesKey;

  // Sets AES encryption key [key] and the initialization vector [iv].
  void aesSetKeys(Uint8List key, [Uint8List? iv]) {
    if (![16, 24, 32].contains(key.length)) {
      throw AesCryptArgumentError(
          'Invalid key length for AES. Provided ${key.length * 8} bits, expected 128, 192 or 256 bits.');
    } else if (_aesMode != AesMode.ecb &&
        (iv == null || iv.isEmpty)) {
      throw AesCryptArgumentError(
          'The initialization vector is not specified. It can not be empty when AES mode is not ECB.');
    } else if (iv!.length != 16) {
      throw AesCryptArgumentError(
          'Invalid IV length for AES. The initialization vector must be 128 bits long.');
    }

    _aesKey = Uint8List.fromList(key);
    _aesIV = (iv == null || iv.isEmpty)
        ? Uint8List(0)
        : Uint8List.fromList(iv);

    _Nk = key.length ~/ 4;
    _Nr = _Nk + _Nb + 2;
    _w = Uint32List(_Nb * (_Nr! + 1));

    _aesKeyExpansion(_aesKey); // places expanded key in w
  }

  // Sets AES mode of operation as [mode].
  //
  // Available modes:
  // - [AesMode.ecb] - ECB (Electronic Code Book)
  // - [AesMode.cbc] - CBC (Cipher Block Chaining)
  // - [AesMode.cfb] - CFB (Cipher Feedback)
  // - [AesMode.ofb] - OFB (Output Feedback)
  void aesSetMode(AesMode mode) {
    if (_aesMode == AesMode.ecb &&
        _aesMode != mode &&
        _aesIV.isNullOrEmpty) {
      throw AesCryptArgumentError(
          'Failed to change AES mode. The initialization vector is not set. When changing the mode from ECB to another one, set IV at first.');
    }
    _aesMode = mode;
  }

  // Sets AES encryption key [key], the initialization vector [iv] and AES mode [mode].
  void aesSetParams(
      Uint8List key, Uint8List iv, AesMode mode) {
    aesSetKeys(key, iv);
    aesSetMode(mode);
  }

  // Encrypts binary data [data] with AES algorithm.
  //
  // Returns [Uint8List] object containing encrypted data.
  Uint8List aesEncrypt(Uint8List data) {
    AesCryptArgumentError.checkNullOrEmpty(
        _aesKey, 'AES encryption key is null or empty.');
    if (_aesMode != AesMode.ecb && _aesIV.isEmpty) {
      throw AesCryptArgumentError(
          'The initialization vector is empty. It can not be empty when AES mode is not ECB.');
    } else if (data.length % 16 != 0) {
      throw AesCryptArgumentError(
          'Invalid data length for AES: ${data.length} bytes.');
    }

    final Uint8List encData =
        Uint8List(data.length); // returned cipher text;
    Uint8List t = Uint8List(
        16); // 16-byte block to hold the temporary input of the cipher
    Uint8List block16 = Uint8List.fromList(
        _aesIV); // 16-byte block to hold the temporary output of the cipher

    switch (_aesMode) {
      case AesMode.ecb:
        // put a 16-byte block into t, encrypt it and add it to the result
        for (int i = 0; i < data.length; i += 16) {
          for (int j = 0; j < 16; ++j) {
            if ((i + j) < data.length) {
              t[j] = data[i + j];
            } else {
              t[j] = 0;
            }
          }
          block16 = aesEncryptBlock(t);
          encData.setRange(i, i + 16, block16);
        }
        break;
      case AesMode.cbc:
        // put a 16-byte block into t, encrypt it and add it to the result
        for (int i = 0; i < data.length; i += 16) {
          for (int j = 0; j < 16; ++j) {
            // XOR this block of plaintext with the initialization vector
            t[j] =
                ((i + j) < data.length ? data[i + j] : 0) ^
                    block16[j];
          }
          block16 = aesEncryptBlock(t);
          encData.setRange(i, i + 16, block16);
        }
        break;
      case AesMode.cfb:
        for (int i = 0; i < data.length; i += 16) {
          // Encrypt the initialization vector/cipher output then XOR with the plaintext
          block16 = aesEncryptBlock(block16);
          for (int j = 0; j < 16; ++j) {
            // XOR the cipher output with the plaintext.
            block16[j] =
                ((i + j) < data.length ? data[i + j] : 0) ^
                    block16[j];
          }
          encData.setRange(i, i + 16, block16);
        }
        break;
      case AesMode.ofb:
        for (int i = 0; i < data.length; i += 16) {
          // Encrypt the initialization vector/cipher output then XOR with the plaintext
          t = aesEncryptBlock(block16);
          for (int j = 0; j < 16; ++j) {
            // XOR the cipher output with the plaintext.
            block16[j] =
                ((i + j) < data.length ? data[i + j] : 0) ^
                    t[j];
          }
          encData.setRange(i, i + 16, block16);
          block16 = Uint8List.fromList(t);
        }
        break;
    }
    return encData;
  }

  // Decrypts binary data [data] encrypted with AES algorithm.
  //
  // Returns [Uint8List] object containing decrypted data.
  Uint8List aesDecrypt(Uint8List data) {
    AesCryptArgumentError.checkNullOrEmpty(
        _aesKey, 'AES encryption key null or is empty.');
    if (_aesMode != AesMode.ecb && _aesIV.isEmpty) {
      throw AesCryptArgumentError(
          'The initialization vector is empty. It can not be empty when AES mode is not ECB.');
    } else if (data.length % 16 != 0) {
      throw AesCryptArgumentError(
          'Invalid data length for AES: ${data.length} bytes.');
    }

    Uint8List decData =
        Uint8List(data.length); // returned decrypted data;
    final Uint8List t = Uint8List(16); // 16-byte block
    Uint8List x_block;
    Uint8List block16 = Uint8List.fromList(
        _aesIV); // 16-byte block to hold the temporary output of the cipher

    switch (_aesMode) {
      case AesMode.ecb:
        for (int i = 0; i < data.length; i += 16) {
          for (int j = 0; j < 16; ++j) {
            if ((i + j) < data.length) {
              t[j] = data[i + j];
            } else {
              t[j] = 0;
            }
          }
          x_block = aesDecryptBlock(t);
          decData.setRange(i, i + 16, x_block);
        }
        break;
      case AesMode.cbc:
        for (int i = 0; i < data.length; i += 16) {
          for (int j = 0; j < 16; ++j) {
            if ((i + j) < data.length) {
              t[j] = data[i + j];
            } else {
              t[j] = 0;
            }
          }
          x_block = aesDecryptBlock(t);
          // XOR the iv/previous cipher block with this decrypted cipher block
          for (int j = 0; j < 16; ++j) {
            x_block[j] = x_block[j] ^ block16[j];
          }
          block16 = Uint8List.fromList(t);
          decData.setRange(i, i + 16, x_block);
        }
        break;
      case AesMode.cfb:
        for (int i = 0; i < data.length; i += 16) {
          // Encrypt the initialization vector/cipher output then XOR with the ciphertext
          x_block = aesEncryptBlock(block16);
          for (int j = 0; j < 16; ++j) {
            // XOR the cipher output with the ciphertext.
            x_block[j] =
                ((i + j) < data.length ? data[i + j] : 0) ^
                    x_block[j];
            block16[j] = data[i + j];
          }
          decData.setRange(i, i + 16, x_block);
        }
        break;
      case AesMode.ofb:
        decData = aesEncrypt(data);
        break;
    }
    return decData;
  }

  // Encrypts the 16-byte data block.
  Uint8List aesEncryptBlock(Uint8List data) {
    assert(_Nr != null);

    final Uint8List encBlock =
        Uint8List(16); // 16-byte string
    int i;

    // place input data into the initial state matrix in column order
    for (i = 0; i < 4 * _Nb; ++i) {
      _s[i % 4][(i - i % _Nb) ~/ _Nb] = data[i];
    }

    // add round key
    _addRoundKey(0);

    for (i = 1; i < _Nr!; ++i) {
      // substitute bytes
      _subBytes();
      // shift rows
      _shiftRows();
      // mix columns
      _mixColumns();
      // add round key
      _addRoundKey(i);
    }

    // substitute bytes
    _subBytes();
    // shift rows
    _shiftRows();
    // add round key
    _addRoundKey(i);

    // place state matrix _s into encBlock in column order
    for (i = 0; i < 4 * _Nb; ++i) {
      encBlock[i] = _s[i % 4][(i - i % _Nb) ~/ _Nb];
    }
    return encBlock;
  }

  // Decrypts the 16-byte data block.
  Uint8List aesDecryptBlock(Uint8List data) {
    assert(_Nr != null);

    final Uint8List decBlock =
        Uint8List(16); // 16-byte string
    int i;

    // place input data into the initial state matrix in column order
    for (i = 0; i < 4 * _Nb; ++i) {
      _s[i % 4][(i - i % _Nb) ~/ _Nb] = data[i];
    }

    // add round key
    _addRoundKey(_Nr!);

    for (i = _Nr! - 1; i > 0; --i) {
      // inverse shift rows
      _invShiftRows();
      // inverse sub bytes
      _invSubBytes();
      // add round key
      _addRoundKey(i);
      // inverse mix columns
      _invMixColumns();
    }

    // inverse shift rows
    _invShiftRows();
    // inverse sub bytes
    _invSubBytes();
    // add round key
    _addRoundKey(i);

    // place state matrix s into decBlock in column order
    for (i = 0; i < 4 * _Nb; ++i) {
      decBlock[i] = _s[i % 4][(i - i % _Nb) ~/ _Nb];
    }
    return decBlock;
  }

  // Makes a big key out of a small one
  void _aesKeyExpansion(Uint8List key) {
    const Rcon = [
      0x00000000,
      0x01000000,
      0x02000000,
      0x04000000,
      0x08000000,
      0x10000000,
      0x20000000,
      0x40000000,
      0x80000000,
      0x1b000000,
      0x36000000,
      0x6c000000,
      0xd8000000,
      0xab000000,
      0x4d000000,
      0x9a000000,
      0x2f000000
    ];

    int temp; // temporary 32-bit word
    int i;

    // the first _Nk words of w are the cipher key z
    for (i = 0; i < _Nk; ++i) {
      _w[i] = key.buffer.asByteData().getUint32(i * 4);
    }

    while (i < _Nb * (_Nr! + 1)) {
      temp = _w[i - 1];
      if (i % _Nk == 0) {
        temp = _subWord(_rotWord(temp)) ^ Rcon[i ~/ _Nk];
      } else if (_Nk > 6 && i % _Nk == 4) {
        temp = _subWord(temp);
      }
      _w[i] = (_w[i - _Nk] ^ temp) & 0xFFFFFFFF;
      ++i;
    }
  }

  // Adds the key schedule for a round to a state matrix.
  void _addRoundKey(int round) {
    int temp;

    for (int i = 0; i < 4; ++i) {
      for (int j = 0; j < _Nb; ++j) {
        // place the i-th byte of the j-th word from expanded key w into temp
        temp = (_w[round * _Nb + j] >> (3 - i) * 8) & 0xFF;
        _s[i][j] ^=
            temp; // xor temp with the byte at location (i,j) of the state
      }
    }
  }

  // Unmixes each column of a state matrix.
  void _invMixColumns() {
    int s0;
    int s1;
    int s2;
    int s3;

    // There are _Nb columns
    for (int i = 0; i < _Nb; ++i) {
      s0 = _s[0][i];
      s1 = _s[1][i];
      s2 = _s[2][i];
      s3 = _s[3][i];

      _s[0][i] = _mult(0x0e, s0) ^
          _mult(0x0b, s1) ^
          _mult(0x0d, s2) ^
          _mult(0x09, s3);
      _s[1][i] = _mult(0x09, s0) ^
          _mult(0x0e, s1) ^
          _mult(0x0b, s2) ^
          _mult(0x0d, s3);
      _s[2][i] = _mult(0x0d, s0) ^
          _mult(0x09, s1) ^
          _mult(0x0e, s2) ^
          _mult(0x0b, s3);
      _s[3][i] = _mult(0x0b, s0) ^
          _mult(0x0d, s1) ^
          _mult(0x09, s2) ^
          _mult(0x0e, s3);
    }
  }

  // Applies an inverse cyclic shift to the last 3 rows of a state matrix.
  void _invShiftRows() {
    // var temp = List<int>(_Nb);
    final temp = List.filled(_Nb, 0);
    for (int i = 1; i < 4; ++i) {
      for (int j = 0; j < _Nb; ++j) {
        temp[(i + j) % _Nb] = _s[i][j];
      }
      for (int j = 0; j < _Nb; ++j) {
        _s[i][j] = temp[j];
      }
    }
  }

  // Applies inverse S-Box substitution to each byte of a state matrix.
  void _invSubBytes() {
    for (int i = 0; i < 4; ++i) {
      for (int j = 0; j < _Nb; ++j) {
        _s[i][j] = _invSBox[_s[i][j]];
      }
    }
  }

  // Mixes each column of a state matrix.
  void _mixColumns() {
    int s0;
    int s1;
    int s2;
    int s3;

    // There are _Nb columns
    for (int i = 0; i < _Nb; ++i) {
      s0 = _s[0][i];
      s1 = _s[1][i];
      s2 = _s[2][i];
      s3 = _s[3][i];

      _s[0][i] = _mult(0x02, s0) ^
          _mult(0x03, s1) ^
          _mult(0x01, s2) ^
          _mult(0x01, s3);
      _s[1][i] = _mult(0x01, s0) ^
          _mult(0x02, s1) ^
          _mult(0x03, s2) ^
          _mult(0x01, s3);
      _s[2][i] = _mult(0x01, s0) ^
          _mult(0x01, s1) ^
          _mult(0x02, s2) ^
          _mult(0x03, s3);
      _s[3][i] = _mult(0x03, s0) ^
          _mult(0x01, s1) ^
          _mult(0x01, s2) ^
          _mult(0x02, s3);
    }
  }

  // Applies a cyclic shift to the last 3 rows of a state matrix.
  void _shiftRows() {
    // var temp = List<int>(_Nb);
    final temp = List.filled(_Nb, 0);
    for (int i = 1; i < 4; ++i) {
      for (int j = 0; j < _Nb; ++j) {
        temp[j] = _s[i][(j + i) % _Nb];
      }
      for (int j = 0; j < _Nb; ++j) {
        _s[i][j] = temp[j];
      }
    }
  }

  // Applies S-Box substitution to each byte of a state matrix.
  void _subBytes() {
    for (int i = 0; i < 4; ++i) {
      for (int j = 0; j < _Nb; ++j) {
        _s[i][j] = _sBox[_s[i][j]];
      }
    }
  }

  // Multiplies two polynomials a(x), b(x) in GF(2^8) modulo the irreducible polynomial m(x) = x^8+x^4+x^3+x+1
  // @returns 8-bit value
  int _mult(int a, int b) {
    int sum = _ltable[a] + _ltable[b];
    sum %= 255;
    // Get the antilog
    sum = _atable[sum];
    return a == 0 ? 0 : (b == 0 ? 0 : sum);
  }

  // Applies a cyclic permutation to a 4-byte word.
  // @returns 32-bit int
  int _rotWord(int w) =>
      ((w << 8) & 0xFFFFFFFF) | ((w >> 24) & 0xFF);

  // Applies S-box substitution to each byte of a 4-byte word.
  // @returns 32-bit int
  int _subWord(int w) {
    int w0 = w;
    int temp = 0;
    // loop through 4 bytes of a word
    for (int i = 0; i < 4; ++i) {
      temp = (w >> 24) &
          0xFF; // put the first 8-bits into temp
      w0 = ((w << 8) & 0xFFFFFFFF) |
          _sBox[temp]; // add the substituted byte back
    }
    return w0;
  }
}

/// Enum that specifies the overwrite mode for write file operations
/// during encryption or decryption process.
enum AesCryptOwMode {
  /// If the file exists, stops the operation and throws [AesCryptException]
  /// exception with [AesCryptExceptionType.destFileExists] type.
  /// This mode is set by default.
  warn,

  /// If the file exists, adds index '(1)' to its' name and tries to save.
  /// If such file also exists, adds '(2)' to its name, then '(3)', etc.
  rename,

  /// Overwrites the file if it exists.
  on,
}

/// Enum that specifies the mode of operation of the AES algorithm.
enum AesMode {
  /// ECB (Electronic Code Book)
  ecb,

  /// CBC (Cipher Block Chaining)
  cbc,

  /// CFB (Cipher Feedback)
  cfb,

  /// OFB (Output Feedback)
  ofb,
}

/// Wraps encryption and decryption methods and algorithms.
class AesCrypt {
  final _aes = _Aes();

  late String _password;
  late Uint8List _passBytes;
  late AesCryptOwMode _owMode;
  late Map<String, List<int>> _userdata;

  /// Creates the library wrapper.
  ///
  /// Optionally sets encryption/decryption password as [password].
  AesCrypt([String password = '']) {
    _password = password;
    _passBytes = password.toUtf16Bytes(Endian.little);
    _owMode = AesCryptOwMode.warn;
    setUserData();
  }

  /// Sets encryption/decryption password.
  void setPassword(String password) {
    AesCryptArgumentError.checkNullOrEmpty(
        password, 'Empty password.');
    _password = password;
    _passBytes = password.toUtf16Bytes(Endian.little);
  }

  /// Sets overwrite mode [mode] for write file operations during encryption
  /// or decryption process.
  ///
  /// Available modes:
  ///
  /// [AesCryptOwMode.warn] - If the file exists, stops the operation and
  /// throws [AesCryptException] exception with
  /// [AesCryptExceptionType.destFileExists] type. This mode is set by default.
  ///
  /// [AesCryptOwMode.rename] - If the file exists, adds index '(1)' to its' name
  /// and tries to save. If such file also exists, adds '(2)' to its name, then '(3)', etc.
  ///
  /// [AesCryptOwMode.on] - Overwrite the file if it exists.
  void setOverwriteMode(AesCryptOwMode mode) =>
      _owMode = mode;

  /// Sets standard extension tags used in the AES Crypt file format.
  ///
  /// Extension tags available:
  ///
  /// [createdBy] is a developer-defined text string that identifies the software
  /// product, manufacturer, or other useful information (such as software version).
  ///
  /// [createdOn] indicates the date that the file was created.
  /// The format of the date string is YYYY-MM-DD.
  ///
  /// [createdAt] indicates the time that the file was created. The format of the date string
  /// is in 24-hour format like HH:MM:SS (e.g, 21:15:04). The time zone is UTC.
  void setUserData(
      {String createdBy = 'Dart aes_crypt library',
      String createdOn = '',
      String createdAt = ''}) {
    String key;
    _userdata = {};
    if (createdBy.isNotEmpty) {
      key = 'CREATED_BY';
      _userdata[key] = createdBy.toUtf8Bytes();
      if (key.length + _userdata[key]!.length + 1 > 255) {
        throw AesCryptArgumentError(
            "User data '$key' is too long. Total length should not exceed 255 bytes.");
      }
    }
    if (createdOn.isNotEmpty) {
      key = 'CREATED_DATE';
      _userdata[key] = createdOn.toUtf8Bytes();
      if (key.length + _userdata[key]!.length + 1 > 255) {
        throw AesCryptArgumentError(
            "User data '$key' is too long. Total length should not exceed 255 bytes.");
      }
    }
    if (createdAt.isNotEmpty) {
      key = 'CREATED_TIME';
      _userdata[key] = createdAt.toUtf8Bytes();
      if (key.length + _userdata[key]!.length + 1 > 255) {
        throw AesCryptArgumentError(
            "User data '$key' is too long. Total length should not exceed 255 bytes.");
      }
    }
  }

  /// Encrypts binary data [srcData] to [destFilePath] file synchronously.
  ///
  /// Returns [String] object containing the path to encrypted file.
  String encryptDataToFileSync(
      Uint8List srcData, String destFilePath) {
    final destFilePath0 = destFilePath.trim();
    AesCryptArgumentError.checkNullOrEmpty(
        _password, 'Empty password.');
    AesCryptArgumentError.checkNullOrEmpty(
        destFilePath0, 'Empty encrypted file path.');
    return _Cryptor.init(_passBytes, _owMode, _userdata)
        .encryptDataToFileSync(srcData, destFilePath0);
  }

  /// Encrypts a plain text string [srcString] to [destFilePath] file synchronously.
  ///
  /// By default the text string will be converted to a list of UTF-8 bytes before
  /// it is encrypted.
  ///
  /// If the argument [utf16] is set to [true], the text string will be converted
  /// to a list of UTF-16 bytes. Endianness depends on [endian] argument.
  ///
  /// If the argument [bom] is set to [true], BOM (Byte Order Mark) is appended
  /// to the beginning of the text string before it is encrypted.
  ///
  /// Returns [String] object containing the path to encrypted file.
  String encryptTextToFileSync(
      String srcString, String destFilePath,
      {bool utf16 = false,
      Endian endian = Endian.big,
      bool bom = false}) {
    final Uint8List bytes = Uint8List.fromList(utf16
        ? srcString.toUtf16Bytes(endian, bom)
        : srcString.toUtf8Bytes(bom));
    return encryptDataToFileSync(bytes, destFilePath);
  }

  /// Encrypts binary data [srcData] to [destFilePath] file asynchronously.
  ///
  /// Returns [Future<String>] that completes with the path to encrypted file
  /// once the entire operation has completed.
  Future<String> encryptDataToFile(
      Uint8List srcData, String destFilePath) async {
    final destFilePath0 = destFilePath.trim();
    AesCryptArgumentError.checkNullOrEmpty(
        _password, 'Empty password.');
    AesCryptArgumentError.checkNullOrEmpty(
        destFilePath0, 'Empty encrypted file path.');
    return _Cryptor.init(_passBytes, _owMode, _userdata)
        .encryptDataToFile(srcData, destFilePath0);
  }

  /// Encrypts a plain text string [srcString] to [destFilePath] file asynchronously.
  ///
  /// By default the text string will be converted to a list of UTF-8 bytes before
  /// it is encrypted.
  ///
  /// If the argument [utf16] is set to [true], the text string will be converted
  /// to a list of UTF-16 bytes. Endianness depends on [endian] argument.
  ///
  /// If the argument [bom] is set to [true], BOM (Byte Order Mark) is appended
  /// to the beginning of the string before it is encrypted.
  ///
  /// Returns [Future<String>] that completes with the path to encrypted file
  /// once the entire operation has completed.
  Future<String> encryptTextToFile(
      String srcString, String destFilePath,
      {bool utf16 = false,
      Endian endian = Endian.big,
      bool bom = false}) async {
    final Uint8List bytes = Uint8List.fromList(utf16
        ? srcString.toUtf16Bytes(endian, bom)
        : srcString.toUtf8Bytes(bom));
    return encryptDataToFile(bytes, destFilePath);
  }

  /// Encrypts [srcFilePath] file to [destFilePath] file synchronously.
  ///
  /// If the argument [destFilePath] is not specified, encrypted file name is created
  /// as a concatenation of [srcFilePath] and '.aes' file extension.
  ///
  /// If encrypted file exists, the behaviour depends on [AesCryptOwMode].
  ///
  /// Returns [String] object containing the path to encrypted file.
  String encryptFileSync(String srcFilePath,
      [String destFilePath = '']) {
    final srcFilePath0 = srcFilePath.trim();
    final destFilePath0 = destFilePath.trim();
    AesCryptArgumentError.checkNullOrEmpty(
        _password, 'Empty password.');
    AesCryptArgumentError.checkNullOrEmpty(
        srcFilePath0, 'Empty source file path.');
    if (srcFilePath0 == destFilePath0) {
      throw AesCryptArgumentError(
          'Source file path and encrypted file path are the same.');
    }
    return _Cryptor.init(_passBytes, _owMode, _userdata)
        .encryptFileSync(srcFilePath0, destFilePath0);
  }

  /// Encrypts [srcFilePath] file to [destFilePath] file asynchronously.
  ///
  /// If the argument [destFilePath] is not specified, encrypted file name is created
  /// as a concatenation of [srcFilePath] and '.aes' file extension.
  ///
  /// If encrypted file exists, the behaviour depends on [AesCryptOwMode].
  ///
  /// Returns [Future<String>] that completes with the path to encrypted file
  /// once the entire operation has completed.
  Future<String> encryptFile(String srcFilePath,
      [String destFilePath = '']) async {
    final srcFilePath0 = srcFilePath.trim();
    final destFilePath0 = destFilePath.trim();
    AesCryptArgumentError.checkNullOrEmpty(
        _password, 'Empty password.');
    AesCryptArgumentError.checkNullOrEmpty(
        srcFilePath0, 'Empty source file path.');
    if (srcFilePath0 == destFilePath0) {
      throw AesCryptArgumentError(
          'Source file path and encrypted file path are the same.');
    }
    return await _Cryptor.init(
            _passBytes, _owMode, _userdata)
        .encryptFile(srcFilePath0, destFilePath0);
  }

  /// Decrypts binary data from [srcFilePath] file synchronously.
  ///
  /// Returns [Uint8List] object containing decrypted data.
  Uint8List decryptDataFromFileSync(String srcFilePath) {
    final srcFilePath0 = srcFilePath.trim();
    AesCryptArgumentError.checkNullOrEmpty(
        _password, 'Empty password.');
    AesCryptArgumentError.checkNullOrEmpty(
        srcFilePath0, 'Empty source file path.');
    return _Cryptor.init(_passBytes, _owMode, _userdata)
        .decryptDataFromFileSync(srcFilePath0);
  }

  /// Decrypts a plain text from [srcFilePath] file synchronously.
  ///
  /// If BOM (Byte Order Mark) is present in decrypted data, interprets the data
  /// in accordance with BOM. Otherwise the interpretation will depend on [utf16]
  /// and [endian] arguments.
  ///
  /// If the argument [utf16] is set to [true], decrypted data will be interpreted
  /// as a list of UTF-16 bytes. Endianness depends on [endian] argument.
  /// Otherwise the data will be interpreted as a list of UTF-8 bytes.
  ///
  /// Returns [String] object containing decrypted text.
  String decryptTextFromFileSync(String srcFilePath,
      {bool utf16 = false, Endian endian = Endian.big}) {
    final Uint8List decData =
        decryptDataFromFileSync(srcFilePath);
    String srcString;
    if ((decData[0] == 0xFE && decData[1] == 0xFF) ||
        (decData[0] == 0xFF && decData[1] == 0xFE)) {
      srcString = decData.toUtf16String();
    } else if (decData[0] == 0xEF &&
        decData[1] == 0xBB &&
        decData[2] == 0xBF) {
      srcString = decData.toUtf8String();
    } else {
      srcString = utf16
          ? decData.toUtf16String(endian)
          : decData.toUtf8String();
    }
    return srcString;
  }

  /// Decrypts binary data from [srcFilePath] file asynchronously.
  ///
  /// Returns [Future<Uint8List>] that completes with decrypted data
  /// once the entire operation has completed.
  Future<Uint8List> decryptDataFromFile(
      String srcFilePath) async {
    final srcFilePath0 = srcFilePath.trim();
    AesCryptArgumentError.checkNullOrEmpty(
        _password, 'Empty password.');
    AesCryptArgumentError.checkNullOrEmpty(
        srcFilePath0, 'Empty source file path.');
    return await _Cryptor.init(
            _passBytes, _owMode, _userdata)
        .decryptDataFromFile(srcFilePath0);
  }

  /// Decrypts a plain text from [srcFilePath] file asynchronously.
  ///
  /// If BOM (Byte Order Mark) is present in decrypted data, interprets the data
  /// in accordance with BOM. Otherwise the interpretation will depend on [utf16]
  /// and [endian] arguments.
  ///
  /// If the argument [utf16] is set to [true], decrypted data will be interpreted
  /// as a list of UTF-16 bytes. Endianness depends on [endian] argument.
  /// Otherwise the data will be interpreted as a list of UTF-8 bytes.
  ///
  /// Returns [Future<String>] that completes with decrypted text
  /// once the entire operation has completed.
  Future<String> decryptTextFromFile(String srcFilePath,
      {bool utf16 = false,
      Endian endian = Endian.big}) async {
    final Uint8List decData =
        decryptDataFromFileSync(srcFilePath);
    String srcString;
    if ((decData[0] == 0xFE && decData[1] == 0xFF) ||
        (decData[0] == 0xFF && decData[1] == 0xFE)) {
      srcString = decData.toUtf16String();
    } else if (decData[0] == 0xEF &&
        decData[1] == 0xBB &&
        decData[2] == 0xBF) {
      srcString = decData.toUtf8String();
    } else {
      srcString = utf16
          ? decData.toUtf16String(endian)
          : decData.toUtf8String();
    }
    return srcString;
  }

  /// Decrypts [srcFilePath] file to [destFilePath] file synchronously.
  ///
  /// If the argument [destFilePath] is not specified, decrypted file name is created
  /// by removing '.aes' file extension from [srcFilePath].
  /// If it has no '.aes' extension, then decrypted file name is created by adding
  /// '.decrypted' file extension to [srcFilePath].
  ///
  /// If decrypted file exists, the behaviour depends on [AesCryptOwMode].
  ///
  /// Returns [String] object containing the path to decrypted file.
  String decryptFileSync(String srcFilePath,
      [String destFilePath = '']) {
    final srcFilePath0 = srcFilePath.trim();
    final destFilePath0 = destFilePath.trim();
    AesCryptArgumentError.checkNullOrEmpty(
        _password, 'Empty password.');
    AesCryptArgumentError.checkNullOrEmpty(
        srcFilePath0, 'Empty source file path.');
    if (srcFilePath0 == destFilePath0) {
      throw AesCryptArgumentError(
          'Source file path and decrypted file path are the same.');
    }
    return _Cryptor.init(_passBytes, _owMode, _userdata)
        .decryptFileSync(srcFilePath0, destFilePath0);
  }

  /// Decrypts [srcFilePath] file to [destFilePath] file asynchronously.
  ///
  /// If the argument [destFilePath] is not specified, decrypted file name is created
  /// by removing '.aes' file extension from [srcFilePath].
  /// If it has no '.aes' extension, then decrypted file name is created by adding
  /// '.decrypted' file extension to [srcFilePath].
  ///
  /// If decrypted file exists, the behaviour depends on [AesCryptOwMode].
  ///
  /// Returns [Future<String>] that completes with the path to decrypted file
  /// once the entire operation has completed.
  Future<String> decryptFile(String srcFilePath,
      [String destFilePath = '']) async {
    final srcFilePath0 = srcFilePath.trim();
    final destFilePath0 = destFilePath.trim();
    AesCryptArgumentError.checkNullOrEmpty(
        _password, 'Empty password.');
    AesCryptArgumentError.checkNullOrEmpty(
        srcFilePath0, 'Empty source file path.');
    if (srcFilePath0 == destFilePath0) {
      throw AesCryptArgumentError(
          'Source file path and decrypted file path are the same.');
    }
    return await _Cryptor.init(
            _passBytes, _owMode, _userdata)
        .decryptFile(srcFilePath0, destFilePath0);
  }

//****************************************************************************
//**************************** CRYPTO FUNCTIONS ******************************
//****************************************************************************

  /// Creates random encryption key of [length] bytes long.
  ///
  /// Returns [Uint8List] object containing created key.
  Uint8List createKey([int length = 32]) =>
      _Cryptor().createKey(length);

  /// Creates random initialization vector.
  ///
  /// Returns [Uint8List] object containing created initialization vector.
  Uint8List createIV() => _Cryptor().createKey(16);

  /// Computes SHA256 hash for binary data [data].
  ///
  /// Returns [Uint8List] object containing computed hash.
  Uint8List sha256(Uint8List data) =>
      _Cryptor().sha256(data);

  /// Computes HMAC-SHA256 code for binary data [data] using cryptographic key [key].
  ///
  /// Returns [Uint8List] object containing computed code.
  Uint8List hmacSha256(Uint8List key, Uint8List data) =>
      _Cryptor().hmacSha256(key, data);

  /// Sets AES encryption key [key] and the initialization vector [iv].
  void aesSetKeys(Uint8List key, [Uint8List? iv]) =>
      _aes.aesSetKeys(key, iv);

  /// Sets AES mode of operation as [mode].
  ///
  /// Available modes:
  /// - [AesMode.ecb] - ECB (Electronic Code Book)
  /// - [AesMode.cbc] - CBC (Cipher Block Chaining)
  /// - [AesMode.cfb] - CFB (Cipher Feedback)
  /// - [AesMode.ofb] - OFB (Output Feedback)
  void aesSetMode(AesMode mode) => _aes.aesSetMode(mode);

  /// Sets AES encryption key [key], the initialization vector [iv] and AES mode [mode].
  void aesSetParams(
      Uint8List key, Uint8List iv, AesMode mode) {
    aesSetKeys(key, iv);
    aesSetMode(mode);
  }

  /// Encrypts binary data [data] with AES algorithm.
  ///
  /// Returns [Uint8List] object containing encrypted data.
  Uint8List aesEncrypt(Uint8List data) =>
      _aes.aesEncrypt(data);

  // Decrypts binary data [data] encrypted with AES algorithm.
  //
  // Returns [Uint8List] object containing decrypted data.
  Uint8List aesDecrypt(Uint8List data) =>
      _aes.aesDecrypt(data);
}

enum _Action { encrypting, decripting }

enum _Data {
  head,
  userdata,
  iv1,
  key1,
  iv2,
  key2,
  enckeys,
  hmac1,
  encdata,
  fsmod,
  hmac2
}

enum _HmacType { HMAC, HMAC1, HMAC2 }

extension _HmacTypeExtension on _HmacType {
  String get name =>
      toString().replaceFirst('$runtimeType.', '');
}

class _Cryptor {
  static const bool _debug = false;
  static const String _encFileExt = '.aes';
  static const List<_Data> _Chunks = [
    _Data.head,
    _Data.userdata,
    _Data.iv1,
    _Data.enckeys,
    _Data.hmac1,
    _Data.encdata,
    _Data.fsmod,
    _Data.hmac2
  ];
  final Map<_Data, Uint8List> _dp =
      {}; // encrypted file data parts

  final _secureRandom = Random.secure();
  final _aes = _Aes();

  late Uint8List _passBytes;
  late AesCryptOwMode _owMode;
  late Map<String, List<int>> _userdata;

  _Cryptor();

  _Cryptor.init(Uint8List passBytes, AesCryptOwMode mode,
      Map<String, List<int>> userdata) {
    _passBytes = passBytes != null
        ? Uint8List.fromList(passBytes)
        : Uint8List(0);
    _owMode = mode;
    if (userdata == null || userdata.isEmpty) {
      _userdata = {
        'CREATED_BY': 'Dart aes_crypt library'.toUtf8Bytes()
      };
    } else {
      _userdata = Map<String, List<int>>.from(userdata);
    }
  }

  // Sets encryption/decryption password.
  void setPassword(String password) {
    AesCryptArgumentError.checkNullOrEmpty(
        password, 'Empty password.');
    _passBytes = password.toUtf16Bytes(Endian.little);
  }

  // Creates random encryption key of [length] bytes long.
  //
  // Returns [Uint8List] object containing created key.
  Uint8List createKey([int length = 32]) {
    return Uint8List.fromList(List<int>.generate(
        length, (i) => _secureRandom.nextInt(256)));
  }

  // Creates random initialization vector.
  //
  // Returns [Uint8List] object containing created initialization vector.
  Uint8List createIV() {
    return createKey(16);
  }

  // Encrypts binary data [srcData] to [destFilePath] file synchronously.
  //
  // Returns [String] object containing the path to encrypted file.
  String encryptDataToFileSync(
      Uint8List srcData, String destFilePath) {
    _log('ENCRYPTION', 'Started');

    _createDataParts();

    // Prepare data for encryption

    _dp[_Data.fsmod] =
        Uint8List.fromList([srcData.length % 16]);
    _log('FILE SIZE MODULO', _dp[_Data.fsmod]);

    // Encrypt data

    _encryptDataAndCalculateHmac(srcData, _dp[_Data.key2]!,
        _dp[_Data.iv2]!, AesMode.cbc);
    _log('HMAC2', _dp[_Data.hmac2]);

    // Write encrypted data to file

    final destFilePath0 =
        _modifyDestinationFilenameSync(destFilePath);
    final File outFile = File(destFilePath0);
    RandomAccessFile raf;
    try {
      raf = outFile.openSync(mode: FileMode.writeOnly);
    } on FileSystemException catch (e) {
      throw AesCryptFsException(
          'Failed to open file $destFilePath0 for writing.',
          e.path ?? ' ',
          e.osError);
    }
    try {
      for (var c in _Chunks) {
        raf.writeFromSync(_dp[c]!);
      }
    } on FileSystemException catch (e) {
      raf.closeSync();
      for (var v in _dp.values) {
        v.fillByZero();
      }
      throw AesCryptFsException(
          'Failed to write encrypted data to file $destFilePath0.',
          e.path ?? ' ',
          e.osError);
    }
    raf.closeSync();

    for (var v in _dp.values) {
      v.fillByZero();
    }
    _log('ENCRYPTION', 'Complete');

    return destFilePath0;
  }

  // Encrypts binary data [srcData] to [destFilePath] file asynchronously.
  //
  // Returns [Future<String>] that completes with the path to encrypted file
  // once the entire operation has completed.
  Future<String> encryptDataToFile(
      Uint8List srcData, String destFilePath) async {
    _log('ENCRYPTION', 'Started');

    _createDataParts();

    // Prepare data for encryption

    _dp[_Data.fsmod] =
        Uint8List.fromList([srcData.length % 16]);
    _log('FILE SIZE MODULO', _dp[_Data.fsmod]);

    // Encrypt data

    _encryptDataAndCalculateHmac(srcData, _dp[_Data.key2]!,
        _dp[_Data.iv2]!, AesMode.cbc);
    _log('HMAC2', _dp[_Data.hmac2]);

    // Write encrypted data to file

    final destFilePath0 =
        await _modifyDestinationFilename(destFilePath);
    final File outFile = File(destFilePath0);
    RandomAccessFile raf;
    try {
      raf = await outFile.open(mode: FileMode.writeOnly);
    } on FileSystemException catch (e) {
      throw AesCryptFsException(
          'Failed to open file $destFilePath0 for writing.',
          e.path ?? ' ',
          e.osError);
    }
    try {
      await Future.forEach(
          _Chunks, (c) => raf.writeFrom(_dp[c]!));
    } on FileSystemException catch (e) {
      await raf.close();
      for (var v in _dp.values) {
        v.fillByZero();
      }
      throw AesCryptFsException(
          'Failed to write encrypted data to file $destFilePath0.',
          e.path ?? ' ',
          e.osError);
    }
    await raf.close();

    for (var v in _dp.values) {
      v.fillByZero();
    }
    _log('ENCRYPTION', 'Complete');

    return destFilePath0;
  }

  // Encrypts [srcFilePath] file to [destFilePath] file synchronously.
  //
  // If the argument [destFilePath] is not specified, encrypted file name is created
  // as a concatenation of [srcFilePath] and '.aes' file extension.
  //
  // If encrypted file exists, the behaviour depends on [AesCryptOwMode].
  //
  // Returns [String] object containing the path to encrypted file.
  String encryptFileSync(
      String srcFilePath, String destFilePath) {
    final File inFile = File(srcFilePath);
    if (!inFile.existsSync()) {
      throw AesCryptFsException(
          'Source file $srcFilePath does not exist.',
          srcFilePath);
    } else if (!inFile.isReadable()) {
      throw AesCryptFsException(
          'Source file $srcFilePath is not readable.',
          srcFilePath);
    }

    _log('ENCRYPTION', 'Started');

    _createDataParts();

    // Read file data for encryption

    final int inFileLength = inFile.lengthSync();
    final Uint8List srcData = Uint8List(inFileLength);

    _dp[_Data.fsmod] =
        Uint8List.fromList([inFileLength % 16]);
    _log('FILE SIZE MODULO', _dp[_Data.fsmod]);

    RandomAccessFile f;
    try {
      f = inFile.openSync(mode: FileMode.read);
    } on FileSystemException catch (e) {
      throw AesCryptFsException(
          'Failed to open file $srcFilePath for reading.',
          e.path ?? ' ',
          e.osError);
    }
    try {
      f.readIntoSync(srcData);
    } on FileSystemException catch (e) {
      f.closeSync();
      throw AesCryptFsException(
          'Failed to read file $srcFilePath',
          e.path ?? ' ',
          e.osError);
    }
    f.closeSync();

    // Encrypt data

    _encryptDataAndCalculateHmac(srcData, _dp[_Data.key2]!,
        _dp[_Data.iv2]!, AesMode.cbc);
    _dp[_Data.hmac2] =
        hmacSha256(_dp[_Data.key2]!, _dp[_Data.encdata]!);

    _log('HMAC2', _dp[_Data.hmac2]);

    // Write encrypted data to file

    String destFilePath0 = _makeDestFilenameFromSource(
        srcFilePath, destFilePath, _Action.encrypting);
    destFilePath0 =
        _modifyDestinationFilenameSync(destFilePath0);
    final File outFile = File(destFilePath0);
    RandomAccessFile raf;
    try {
      raf = outFile.openSync(mode: FileMode.writeOnly);
    } on FileSystemException catch (e) {
      throw AesCryptFsException(
          'Failed to open file $destFilePath0 for writing.',
          e.path ?? ' ',
          e.osError);
    }
    try {
      for (var c in _Chunks) {
        raf.writeFromSync(_dp[c]!);
      }
    } on FileSystemException catch (e) {
      raf.closeSync();
      for (var v in _dp.values) {
        v.fillByZero();
      }
      throw AesCryptFsException(
          'Failed to write encrypted data to file $destFilePath0.',
          e.path ?? ' ',
          e.osError);
    }
    raf.closeSync();

    for (var v in _dp.values) {
      v.fillByZero();
    }
    _log('ENCRYPTION', 'Complete');

    return destFilePath0;
  }

  // Encrypts [srcFilePath] file to [destFilePath] file asynchronously.
  //
  // If the argument [destFilePath] is not specified, encrypted file name is created
  // as a concatenation of [srcFilePath] and '.aes' file extension.
  //
  // If encrypted file exists, the behaviour depends on [AesCryptOwMode].
  //
  // Returns [Future<String>] that completes with the path to encrypted file
  // once the entire operation has completed.
  Future<String> encryptFile(
      String srcFilePath, String destFilePath) async {
    final File inFile = File(srcFilePath);
    if (!await inFile.exists()) {
      throw AesCryptFsException(
          'Source file $srcFilePath does not exist.',
          srcFilePath);
    } else if (!inFile.isReadable()) {
      throw AesCryptFsException(
          'Source file $srcFilePath is not readable.',
          srcFilePath);
    }

    _log('ENCRYPTION', 'Started');

    _createDataParts();

    // Read file data for encryption

    final int inFileLength = inFile.lengthSync();
    final Uint8List srcData = Uint8List(inFileLength);

    _dp[_Data.fsmod] =
        Uint8List.fromList([inFileLength % 16]);
    _log('FILE SIZE MODULO', _dp[_Data.fsmod]);

    RandomAccessFile f;
    try {
      f = await inFile.open(mode: FileMode.read);
    } on FileSystemException catch (e) {
      throw AesCryptFsException(
          'Failed to open file $srcFilePath for reading.',
          e.path ?? ' ',
          e.osError);
    }
    try {
      await f.readInto(srcData);
    } on FileSystemException catch (e) {
      await f.close();
      throw AesCryptFsException(
          'Failed to read file $srcFilePath',
          e.path ?? ' ',
          e.osError);
    }
    await f.close();

    // Encrypt data

    _encryptDataAndCalculateHmac(srcData, _dp[_Data.key2]!,
        _dp[_Data.iv2]!, AesMode.cbc);
    _log('HMAC2', _dp[_Data.hmac2]);

    // Write encrypted data to file

    String destFilePath0 = _makeDestFilenameFromSource(
        srcFilePath, destFilePath, _Action.encrypting);
    destFilePath0 =
        await _modifyDestinationFilename(destFilePath0);
    final File outFile = File(destFilePath0);
    late RandomAccessFile raf;
    try {
      raf = await outFile.open(mode: FileMode.writeOnly);
    } on FileSystemException catch (e) {
      throw AesCryptFsException(
          'Failed to open file $destFilePath0 for writing.',
          e.path ?? ' ',
          e.osError);
    }
    try {
      await Future.forEach(
          _Chunks, (c) => raf.writeFrom(_dp[c]!));
    } on FileSystemException catch (e) {
      raf.closeSync();
      for (var v in _dp.values) {
        v.fillByZero();
      }
      throw AesCryptFsException(
          'Failed to write encrypted data to file $destFilePath0.',
          e.path ?? ' ',
          e.osError);
    }
    raf.closeSync();

    for (var v in _dp.values) {
      v.fillByZero();
    }
    _log('ENCRYPTION', 'Complete');

    return destFilePath0;
  }

  // Decrypts binary data from [srcFilePath] file synchronously.
  //
  // Returns [Uint8List] object containing decrypted data.
  Uint8List decryptDataFromFileSync(String srcFilePath) {
    assert(!_passBytes.isNullOrEmpty);

    _log('DECRYPTION', 'Started');
    _log('PASSWORD', _passBytes);

    final File inFile = File(srcFilePath);
    if (!inFile.existsSync()) {
      throw AesCryptFsException(
          'Source file $srcFilePath does not exist.');
    }

    RandomAccessFile f;
    try {
      f = inFile.openSync(mode: FileMode.read);
    } on FileSystemException catch (e) {
      throw AesCryptFsException(
          'Failed to open file $srcFilePath for reading.',
          e.path ?? ' ',
          e.osError);
    }

    final Map<_Data, Uint8List> keys = _readKeysSync(f);

    final Uint8List encrypted_data = _readChunkBytesSync(
        f,
        f.lengthSync() - f.positionSync() - 33,
        'encrypted data');
    _log('ENCRYPTED DATA', encrypted_data);

    final int file_size_modulo =
        _readChunkIntSync(f, 1, 'file size modulo');
    _log('FILE SIZE MODULO', file_size_modulo);
    if (file_size_modulo < 0 || file_size_modulo >= 16) {
      throw AesCryptDataException(
          'Invalid file size modulo: $file_size_modulo');
    }

    final Uint8List hmac_2 =
        _readChunkBytesSync(f, 32, 'HMAC 2');
    _log('HMAC_2', hmac_2);
    f.closeSync();

    _validateHMAC(keys[_Data.key2]!, encrypted_data, hmac_2,
        _HmacType.HMAC2);

    _aes.aesSetParams(
        keys[_Data.key2]!, keys[_Data.iv2]!, AesMode.cbc);
    final Uint8List decrypted_data_full =
        _aes.aesDecrypt(encrypted_data);

    final Uint8List decrypted_data =
        decrypted_data_full.buffer.asUint8List(
            0,
            decrypted_data_full.length -
                (file_size_modulo == 0
                    ? 0
                    : 16 - file_size_modulo));

    _log('DECRYPTION', 'Completed');
    return decrypted_data;
  }

  // Decrypts binary data from [srcFilePath] file asynchronously.
  //
  // Returns [Future<Uint8List>] that completes with decrypted data
  // once the entire operation has completed.
  Future<Uint8List> decryptDataFromFile(
      String srcFilePath) async {
    assert(!_passBytes.isNullOrEmpty);

    _log('DECRYPTION', 'Started');
    _log('PASSWORD', _passBytes);

    final File inFile = File(srcFilePath);
    if (!await inFile.exists()) {
      throw AesCryptFsException(
          'Source file $srcFilePath does not exist.');
    }

    RandomAccessFile f;
    try {
      f = await inFile.open(mode: FileMode.read);
    } on FileSystemException catch (e) {
      throw AesCryptFsException(
          'Failed to open file $srcFilePath for reading.',
          e.path ?? ' ',
          e.osError);
    }

    final Map<_Data, Uint8List> keys = await _readKeys(f);

    final Uint8List encrypted_data = await _readChunkBytes(
        f,
        f.lengthSync() - f.positionSync() - 33,
        'encrypted data');
    _log('ENCRYPTED DATA', encrypted_data);

    final int file_size_modulo =
        await _readChunkInt(f, 1, 'file size modulo');
    _log('FILE SIZE MODULO', file_size_modulo);
    if (file_size_modulo < 0 || file_size_modulo >= 16) {
      throw AesCryptDataException(
          'Invalid file size modulo: $file_size_modulo');
    }

    final Uint8List hmac_2 =
        await _readChunkBytes(f, 32, 'HMAC 2');
    _log('HMAC_2', hmac_2);
    f.closeSync();

    _validateHMAC(keys[_Data.key2]!, encrypted_data, hmac_2,
        _HmacType.HMAC2);

    _aes.aesSetParams(
        keys[_Data.key2]!, keys[_Data.iv2]!, AesMode.cbc);
    final Uint8List decrypted_data_full =
        _aes.aesDecrypt(encrypted_data);

    final Uint8List decrypted_data =
        decrypted_data_full.buffer.asUint8List(
            0,
            decrypted_data_full.length -
                (file_size_modulo == 0
                    ? 0
                    : 16 - file_size_modulo));

    _log('DECRYPTION', 'Completed');

    return decrypted_data;
  }

  // Decrypts [srcFilePath] file to [destFilePath] file synchronously.
  //
  // If the argument [destFilePath] is not specified, decrypted file name is created
  // by removing '.aes' file extension from [srcFilePath].
  // If it has no '.aes' extension, then decrypted file name is created by adding
  // '.decrypted' file extension to [srcFilePath].
  //
  // If decrypted file exists, the behaviour depends on [AesCryptOwMode].
  //
  // Returns [String] object containing the path to decrypted file.
  String decryptFileSync(
      String srcFilePath, String destFilePath) {
    assert(!_passBytes.isNullOrEmpty);

    _log('DECRYPTION', 'Started');
    _log('PASSWORD', _passBytes);

    final File inFile = File(srcFilePath);
    if (!inFile.existsSync()) {
      throw FileSystemException(
          'Source file $srcFilePath does not exist.');
    }

    RandomAccessFile f;
    try {
      f = inFile.openSync(mode: FileMode.read);
    } on FileSystemException catch (e) {
      throw FileSystemException(
          'Failed to open file $srcFilePath for reading.',
          e.path,
          e.osError);
    }

    final Map<_Data, Uint8List> keys = _readKeysSync(f);

    final Uint8List encrypted_data = _readChunkBytesSync(
        f,
        f.lengthSync() - f.positionSync() - 33,
        'encrypted data');
    _log('ENCRYPTED DATA', encrypted_data);

    final int file_size_modulo =
        _readChunkIntSync(f, 1, 'file size modulo');
    _log('FILE SIZE MODULO', file_size_modulo);
    if (file_size_modulo < 0 || file_size_modulo >= 16) {
      throw AesCryptDataException(
          'Invalid file size modulo: $file_size_modulo');
    }

    final Uint8List hmac_2 =
        _readChunkBytesSync(f, 32, 'HMAC 2');
    _log('HMAC_2', hmac_2);
    f.closeSync();

    _validateHMAC(keys[_Data.key2]!, encrypted_data, hmac_2,
        _HmacType.HMAC2);

    _aes.aesSetParams(
        keys[_Data.key2]!, keys[_Data.iv2]!, AesMode.cbc);
    final Uint8List decrypted_data_full =
        _aes.aesDecrypt(encrypted_data);

    _log('WRITE', 'Started');
    String destFilePath0 = _makeDestFilenameFromSource(
        srcFilePath, destFilePath, _Action.decripting);
    destFilePath0 =
        _modifyDestinationFilenameSync(destFilePath0);
    final File outFile = File(destFilePath0);
    RandomAccessFile raf;
    try {
      raf = outFile.openSync(mode: FileMode.writeOnly);
    } on FileSystemException catch (e) {
      throw AesCryptFsException(
          'Failed to open $srcFilePath for writing.',
          e.path ?? ' ',
          e.osError);
    }
    try {
      raf.writeFromSync(
          decrypted_data_full,
          0,
          decrypted_data_full.length -
              (file_size_modulo == 0
                  ? 0
                  : 16 - file_size_modulo));
    } on FileSystemException catch (e) {
      raf.closeSync();
      throw AesCryptFsException(
          'Failed to write to file $srcFilePath.',
          e.path ?? ' ',
          e.osError);
    }
    raf.closeSync();

    decrypted_data_full.fillByZero();
    _log('DECRYPTION', 'Completed');
    return destFilePath0;
  }

  // Decrypts [srcFilePath] file to [destFilePath] file asynchronously.
  //
  // If the argument [destFilePath] is not specified, decrypted file name is created
  // by removing '.aes' file extension from [srcFilePath].
  // If it has no '.aes' extension, then decrypted file name is created by adding
  // '.decrypted' file extension to [srcFilePath].
  //
  // If decrypted file exists, the behaviour depends on [AesCryptOwMode].
  //
  // Returns [Future<String>] that completes with the path to decrypted file
  // once the entire operation has completed.
  Future<String> decryptFile(
      String srcFilePath, String destFilePath) async {
    assert(!_passBytes.isNullOrEmpty);

    _log('DECRYPTION', 'Started');
    _log('PASSWORD', _passBytes);

    final File inFile = File(srcFilePath);
    if (!await inFile.exists()) {
      throw FileSystemException(
          'Source file $srcFilePath does not exist.');
    }

    RandomAccessFile f;
    try {
      f = await inFile.open(mode: FileMode.read);
    } on FileSystemException catch (e) {
      throw FileSystemException(
          'Failed to open file $srcFilePath for reading.',
          e.path,
          e.osError);
    }

    Map<_Data, Uint8List> keys = await _readKeys(f);

    final Uint8List encrypted_data = await _readChunkBytes(
        f,
        f.lengthSync() - f.positionSync() - 33,
        'encrypted data');
    _log('ENCRYPTED DATA', encrypted_data);

    final int file_size_modulo =
        await _readChunkInt(f, 1, 'file size modulo');
    _log('FILE SIZE MODULO', file_size_modulo);
    if (file_size_modulo < 0 || file_size_modulo >= 16) {
      throw AesCryptDataException(
          'Invalid file size modulo: $file_size_modulo');
    }

    final Uint8List hmac_2 =
        await _readChunkBytes(f, 32, 'HMAC 2');
    _log('HMAC_2', hmac_2);
    f.closeSync();

    _validateHMAC(keys[_Data.key2]!, encrypted_data, hmac_2,
        _HmacType.HMAC2);

    _aes.aesSetParams(
        keys[_Data.key2]!, keys[_Data.iv2]!, AesMode.cbc);
    final Uint8List decrypted_data_full =
        _aes.aesDecrypt(encrypted_data);

    _log('WRITE', 'Started');
    String destFilePath0 = _makeDestFilenameFromSource(
        srcFilePath, destFilePath, _Action.decripting);
    destFilePath0 =
        await _modifyDestinationFilename(destFilePath0);
    final File outFile = File(destFilePath0);
    RandomAccessFile raf;
    try {
      raf = await outFile.open(mode: FileMode.writeOnly);
    } on FileSystemException catch (e) {
      throw AesCryptFsException(
          'Failed to open $srcFilePath for writing.',
          e.path ?? ' ',
          e.osError);
    }
    try {
      await raf.writeFrom(
          decrypted_data_full,
          0,
          decrypted_data_full.length -
              (file_size_modulo == 0
                  ? 0
                  : 16 - file_size_modulo));
    } on FileSystemException catch (e) {
      raf.closeSync();
      throw AesCryptFsException(
          'Failed to write to file $srcFilePath.',
          e.path ?? ' ',
          e.osError);
    }
    raf.closeSync();

    decrypted_data_full.fillByZero();
    _log('DECRYPTION', 'Completed');

    return destFilePath0;
  }

//****************************************************************************
//****************************      SHA256      ******************************
//****************************************************************************

  static const _K = [
    0x428a2f98,
    0x71374491,
    0xb5c0fbcf,
    0xe9b5dba5,
    0x3956c25b,
    0x59f111f1,
    0x923f82a4,
    0xab1c5ed5,
    0xd807aa98,
    0x12835b01,
    0x243185be,
    0x550c7dc3,
    0x72be5d74,
    0x80deb1fe,
    0x9bdc06a7,
    0xc19bf174,
    0xe49b69c1,
    0xefbe4786,
    0x0fc19dc6,
    0x240ca1cc,
    0x2de92c6f,
    0x4a7484aa,
    0x5cb0a9dc,
    0x76f988da,
    0x983e5152,
    0xa831c66d,
    0xb00327c8,
    0xbf597fc7,
    0xc6e00bf3,
    0xd5a79147,
    0x06ca6351,
    0x14292967,
    0x27b70a85,
    0x2e1b2138,
    0x4d2c6dfc,
    0x53380d13,
    0x650a7354,
    0x766a0abb,
    0x81c2c92e,
    0x92722c85,
    0xa2bfe8a1,
    0xa81a664b,
    0xc24b8b70,
    0xc76c51a3,
    0xd192e819,
    0xd6990624,
    0xf40e3585,
    0x106aa070,
    0x19a4c116,
    0x1e376c08,
    0x2748774c,
    0x34b0bcb5,
    0x391c0cb3,
    0x4ed8aa4a,
    0x5b9cca4f,
    0x682e6ff3,
    0x748f82ee,
    0x78a5636f,
    0x84c87814,
    0x8cc70208,
    0x90befffa,
    0xa4506ceb,
    0xbef9a3f7,
    0xc67178f2
  ];

  static const _mask32 = 0xFFFFFFFF;
  static const _mask32Bits = [
    0xFFFFFFFF,
    0x7FFFFFFF,
    0x3FFFFFFF,
    0x1FFFFFFF,
    0x0FFFFFFF,
    0x07FFFFFF,
    0x03FFFFFF,
    0x01FFFFFF,
    0x00FFFFFF,
    0x007FFFFF,
    0x003FFFFF,
    0x001FFFFF,
    0x000FFFFF,
    0x0007FFFF,
    0x0003FFFF,
    0x0001FFFF,
    0x0000FFFF,
    0x00007FFF,
    0x00003FFF,
    0x00001FFF,
    0x00000FFF,
    0x000007FF,
    0x000003FF,
    0x000001FF,
    0x000000FF,
    0x0000007F,
    0x0000003F,
    0x0000001F,
    0x0000000F,
    0x00000007,
    0x00000003,
    0x00000001,
    0x00000000
  ];

  final Uint32List _chunkBuff = Uint32List(64);
  late int _h0;
  late int _h1;
  late int _h2;
  late int _h3;
  late int _h4;
  late int _h5;
  late int _h6;
  late int _h7;
  late int _a;
  late int _b;
  late int _c;
  late int _d;
  late int _e;
  late int _f;
  late int _g;
  late int _h;
  late int _s0;
  late int _s1;

  Uint8List sha256(Uint8List data, [Uint8List? hmacIpad]) {
    AesCryptArgumentError.checkNullOrEmpty(
        data, 'Empty data.');

    late ByteData chunk;

    final int length = data.length;
    final int lengthPadded =
        length + 8 - ((length + 8) & 0x3F) + 64;
    final int lengthToWrite =
        (hmacIpad == null ? length : length + 64) * 8;

    _h0 = 0x6a09e667;
    _h1 = 0xbb67ae85;
    _h2 = 0x3c6ef372;
    _h3 = 0xa54ff53a;
    _h4 = 0x510e527f;
    _h5 = 0x9b05688c;
    _h6 = 0x1f83d9ab;
    _h7 = 0x5be0cd19;

    late Uint8List chunkLast;
    late Uint8List chunkLastPre;
    late int chanksToProcess;

    if (length < lengthPadded - 64) {
      chanksToProcess = lengthPadded - 128;
      chunkLastPre = Uint8List(64)
        ..setAll(
            0,
            data.buffer.asUint8List(
                length - (length & 0x3F), length & 0x3F))
        ..[length & 0x3F] = 0x80;
      chunkLast = Uint8List(64)
        ..buffer.asByteData().setInt64(56, lengthToWrite);
    } else {
      chanksToProcess = lengthPadded - 64;
      chunkLast = Uint8List(64)
        ..setAll(
            0,
            data.buffer.asUint8List(lengthPadded - 64,
                length - (lengthPadded - 64)))
        ..[length - (lengthPadded - 64)] = 0x80
        ..buffer.asByteData().setInt64(56, lengthToWrite);
    }

    if (hmacIpad != null) {
      for (int i = 0; i < 16; ++i) {
        _chunkBuff[i] =
            hmacIpad.buffer.asByteData().getUint32(i * 4);
      }
      _processChunk();
    }

    for (int n = 0; n < chanksToProcess; n += 64) {
      chunk = data.buffer.asByteData(n, 64);
      for (int i = 0; i < 16; ++i) {
        _chunkBuff[i] = chunk.getUint32(i * 4);
      }
      _processChunk();
    }

    if (length < lengthPadded - 64) {
      for (int i = 0; i < 16; ++i) {
        _chunkBuff[i] = chunkLastPre.buffer
            .asByteData()
            .getUint32(i * 4);
      }
      _processChunk();
    }

    for (int i = 0; i < 16; ++i) {
      _chunkBuff[i] =
          chunkLast.buffer.asByteData().getUint32(i * 4);
    }
    _processChunk();

    final Uint32List hash = Uint32List.fromList(
        [_h0, _h1, _h2, _h3, _h4, _h5, _h6, _h7]);
    for (int i = 0; i < 8; ++i) {
      hash[i] = _byteSwap32(hash[i]);
    }
    return hash.buffer.asUint8List();
  }

  void _processChunk() {
    int i;

    for (i = 16; i < 64; i++) {
      _s0 = _rotr(_chunkBuff[i - 15], 7) ^
          _rotr(_chunkBuff[i - 15], 18) ^
          (_chunkBuff[i - 15] >> 3);
      _s1 = _rotr(_chunkBuff[i - 2], 17) ^
          _rotr(_chunkBuff[i - 2], 19) ^
          (_chunkBuff[i - 2] >> 10);
      // _chunkBuff is Uint32List and because of that it does'n need in '& _mask32' at the end
      _chunkBuff[i] = _chunkBuff[i - 16] +
          _s0 +
          _chunkBuff[i - 7] +
          _s1;
    }

    _a = _h0;
    _b = _h1;
    _c = _h2;
    _d = _h3;
    _e = _h4;
    _f = _h5;
    _g = _h6;
    _h = _h7;

    // This implementation was taken from 'pointycastle' Dart library
    // https://pub.dev/packages/pointycastle
    int t = 0;
    for (i = 0; i < 8; ++i) {
      // t = 8 * i
      _h = (_h +
              _Sum1(_e) +
              _Ch(_e, _f, _g) +
              _K[t] +
              _chunkBuff[t++]) &
          _mask32;
      _d = (_d + _h) & _mask32;
      _h = (_h + _Sum0(_a) + _Maj(_a, _b, _c)) & _mask32;

      // t = 8 * i + 1
      _g = (_g +
              _Sum1(_d) +
              _Ch(_d, _e, _f) +
              _K[t] +
              _chunkBuff[t++]) &
          _mask32;
      _c = (_c + _g) & _mask32;
      _g = (_g + _Sum0(_h) + _Maj(_h, _a, _b)) & _mask32;

      // t = 8 * i + 2
      _f = (_f +
              _Sum1(_c) +
              _Ch(_c, _d, _e) +
              _K[t] +
              _chunkBuff[t++]) &
          _mask32;
      _b = (_b + _f) & _mask32;
      _f = (_f + _Sum0(_g) + _Maj(_g, _h, _a)) & _mask32;

      // t = 8 * i + 3
      _e = (_e +
              _Sum1(_b) +
              _Ch(_b, _c, _d) +
              _K[t] +
              _chunkBuff[t++]) &
          _mask32;
      _a = (_a + _e) & _mask32;
      _e = (_e + _Sum0(_f) + _Maj(_f, _g, _h)) & _mask32;

      // t = 8 * i + 4
      _d = (_d +
              _Sum1(_a) +
              _Ch(_a, _b, _c) +
              _K[t] +
              _chunkBuff[t++]) &
          _mask32;
      _h = (_h + _d) & _mask32;
      _d = (_d + _Sum0(_e) + _Maj(_e, _f, _g)) & _mask32;

      // t = 8 * i + 5
      _c = (_c +
              _Sum1(_h) +
              _Ch(_h, _a, _b) +
              _K[t] +
              _chunkBuff[t++]) &
          _mask32;
      _g = (_g + _c) & _mask32;
      _c = (_c + _Sum0(_d) + _Maj(_d, _e, _f)) & _mask32;

      // t = 8 * i + 6
      _b = (_b +
              _Sum1(_g) +
              _Ch(_g, _h, _a) +
              _K[t] +
              _chunkBuff[t++]) &
          _mask32;
      _f = (_f + _b) & _mask32;
      _b = (_b + _Sum0(_c) + _Maj(_c, _d, _e)) & _mask32;

      // t = 8 * i + 7
      _a = (_a +
              _Sum1(_f) +
              _Ch(_f, _g, _h) +
              _K[t] +
              _chunkBuff[t++]) &
          _mask32;
      _e = (_e + _a) & _mask32;
      _a = (_a + _Sum0(_b) + _Maj(_b, _c, _d)) & _mask32;
    }

/* This implementation is slower by about 5%
    int t1, t2, maj, ch;
    for (i = 0; i < 64; ++i) {
      _s0 = _rotr(_a, 2) ^ _rotr(_a, 13) ^ _rotr(_a, 22);
      maj = (_a & _b) ^ (_a & _c) ^ (_b & _c);
      t2 = _s0 + maj;
      _s1 = _rotr(_e, 6) ^ _rotr(_e, 11) ^ _rotr(_e, 25);
      ch = (_e & _f) ^ ((~_e & _mask32) & _g);
      t1 = h + _s1 + ch + _K[i] + _chunkBuff[i];
      _h = _g; _g = _f; _f = _e; _e = (_d + t1) & _mask32;
      _d = _c; _c = _b; _b = _a; _a = (t1 + t2) & _mask32;
    }
*/
    _h0 = (_h0 + _a) & _mask32;
    _h1 = (_h1 + _b) & _mask32;
    _h2 = (_h2 + _c) & _mask32;
    _h3 = (_h3 + _d) & _mask32;
    _h4 = (_h4 + _e) & _mask32;
    _h5 = (_h5 + _f) & _mask32;
    _h6 = (_h6 + _g) & _mask32;
    _h7 = (_h7 + _h) & _mask32;
  }

  int _byteSwap32(int value) {
    int value0 = ((value & 0xFF00FF00) >> 8) |
        ((value & 0x00FF00FF) << 8);
    value0 = ((value0 & 0xFFFF0000) >> 16) |
        ((value0 & 0x0000FFFF) << 16);
    return value0;
  }

/*
  int _byteSwap16(int value) => ((value & 0xFF00) >> 8) | ((value & 0x00FF) << 8);
  int _byteSwap64(int value) { return (_byteSwap32(value) << 32) | _byteSwap32(value >> 32); }
*/
  int _rotr(int x, int n) =>
      (x >> n) |
      (((x & _mask32Bits[32 - n]) << (32 - n)) & _mask32);

  int _Ch(int x, int y, int z) => (x & y) ^ ((~x) & z);

  int _Maj(int x, int y, int z) =>
      (x & y) ^ (x & z) ^ (y & z);

  int _Sum0(int x) =>
      _rotr(x, 2) ^ _rotr(x, 13) ^ _rotr(x, 22);

  int _Sum1(int x) =>
      _rotr(x, 6) ^ _rotr(x, 11) ^ _rotr(x, 25);

//****************************************************************************
//****************************    HMAC-SHA256   ******************************
//****************************************************************************

  final Int32x4 _magic_i = Int32x4(
      0x36363636, 0x36363636, 0x36363636, 0x36363636);
  final Int32x4 _magic_o = Int32x4(
      0x5C5C5C5C, 0x5C5C5C5C, 0x5C5C5C5C, 0x5C5C5C5C);

  // Computes HMAC-SHA256 code for binary data [data] using cryptographic key [key].
  //
  // Returns [Uint8List] object containing computed code.
  Uint8List hmacSha256(Uint8List key, Uint8List data) {
    AesCryptArgumentError.checkNullOrEmpty(
        key, 'Empty key.');

    final Int32x4List i_pad = Int32x4List(4);
    final Int32x4List o_pad = Int32x4List(6);
    Uint8List key0 = key;
    if (key.length > 64) key0 = sha256(key);
    key0 = Uint8List(64)..setRange(0, key.length, key);

    for (int i = 0; i < 4; i++) {
      i_pad[i] = key0.buffer.asInt32x4List()[i] ^ _magic_i;
    }
    for (int i = 0; i < 4; i++) {
      o_pad[i] = key0.buffer.asInt32x4List()[i] ^ _magic_o;
    }

    final Uint8List temp =
        sha256(data, i_pad.buffer.asUint8List());
    final Uint8List buff2 = o_pad.buffer.asUint8List()
      ..setRange(64, 96, temp);
    return sha256(buff2);
  }

//****************************************************************************
//*************************    HMAC, SHA256 and AES   ************************
//****************************************************************************

  void _encryptDataAndCalculateHmac(Uint8List srcData,
      Uint8List key, Uint8List iv, AesMode mode) {
    assert(!iv.isNullOrEmpty,
        'AES encryption key is null or empty.');
    assert(!key.isNullOrEmpty,
        'AES initialization vector is null or empty.');
    _aes.aesSetParams(key, iv, mode);

    final Int32x4List i_pad = Int32x4List(4);
    final Int32x4List o_pad = Int32x4List(6);
    final Uint8List keyForHmac = Uint8List(64)
      ..setAll(0, _aes.getKey());
    for (int i = 0; i < 4; i++) {
      i_pad[i] =
          keyForHmac.buffer.asInt32x4List()[i] ^ _magic_i;
    }
    for (int i = 0; i < 4; i++) {
      o_pad[i] =
          keyForHmac.buffer.asInt32x4List()[i] ^ _magic_o;
    }

    ByteData chunk;
    final int length =
        srcData.length; // unencrypted data length
    final int lengthPadded16 = length +
        ((length % 16 == 0)
            ? 0
            : 16 -
                length % 16); // AES encrypted data length
    final int lengthPadded64 = lengthPadded16 +
        8 -
        ((lengthPadded16 + 8) & 0x3F) +
        64; // length for SHA256
    final int lengthToWrite = (lengthPadded16 + 64) * 8;
    _h0 = 0x6a09e667;
    _h1 = 0xbb67ae85;
    _h2 = 0x3c6ef372;
    _h3 = 0xa54ff53a;
    _h4 = 0x510e527f;
    _h5 = 0x9b05688c;
    _h6 = 0x1f83d9ab;
    _h7 = 0x5be0cd19;

    Uint8List encData = Uint8List(lengthPadded16);
    Uint8List t = Uint8List(16);
    Uint8List block16 = Uint8List.fromList(_aes.getIV());

    // process first chunk for SHA256 (HMAC ipad, 64 bytes)
    for (int i = 0; i < 16; ++i) {
      _chunkBuff[i] =
          i_pad.buffer.asByteData().getUint32(i * 4);
    }
    _processChunk();

    int n;

    for (n = 0; n < lengthPadded64 - 64; n += 64) {
      for (int i = n; i < n + 64; i += 16) {
        for (int j = 0; j < 16; ++j) {
          t[j] = ((i + j) < length ? srcData[i + j] : 0) ^
              block16[j]; // zero padding
        }
        block16 = _aes.aesEncryptBlock(t);
        encData.setRange(i, i + 16, block16);
      }
      chunk = encData.buffer.asByteData(n, 64);
      for (int i = 0; i < 16; ++i) {
        _chunkBuff[i] = chunk.getUint32(i * 4);
      }
      _processChunk();
    }

    int i = n;
    if (n < lengthPadded16) {
      while (i < lengthPadded16) {
        for (int j = 0; j < 16; ++j) {
          t[j] = ((i + j) < length ? srcData[i + j] : 0) ^
              block16[j]; // zero padding
        }
        block16 = _aes.aesEncryptBlock(t);
        encData.setRange(i, i + 16, block16);
        i += 16;
      }
    }
    final Uint8List lastChunk = Uint8List(64)
      ..setAll(0, encData.buffer.asUint8List(n));
    chunk = lastChunk.buffer.asByteData();
    chunk.setUint8(i - n, 0x80);
    chunk.setInt64(56, lengthToWrite);
    for (int i = 0; i < 16; ++i) {
      _chunkBuff[i] = chunk.getUint32(i * 4);
    }
    _processChunk();

    final Uint32List hash = Uint32List.fromList(
        [_h0, _h1, _h2, _h3, _h4, _h5, _h6, _h7]);
    for (int i = 0; i < 8; ++i) {
      hash[i] = _byteSwap32(hash[i]);
    }
    final Uint8List buff2 = o_pad.buffer.asUint8List()
      ..setRange(64, 96, hash.buffer.asUint8List());

    _dp[_Data.hmac2] = sha256(buff2);
    _dp[_Data.encdata] = encData;
  }

//****************************************************************************
//***************************** PRIVATE HELPERS ******************************
//****************************************************************************

  Uint8List _keysJoin(Uint8List iv, Uint8List pass) {
    assert(iv != null);
    Uint8List key = Uint8List(32);
    key.setAll(0, iv);
    int len = 32 + pass.length;
    Uint8List buff = Uint8List(len);
    for (int i = 0; i < 8192; i++) {
      buff.setAll(0, key);
      buff.setRange(32, len, pass);
      key = sha256(buff);
    }
    return key;
  }

  void _validateHMAC(Uint8List key, Uint8List data,
      Uint8List hash, _HmacType ht) {
    final Uint8List calculated = hmacSha256(key, data);
    if (hash.isNotEqual(calculated)) {
      _log('CALCULATED HMAC', calculated);
      _log('ACTUAL HMAC', hash);
      switch (ht) {
        case _HmacType.HMAC1:
          throw const AesCryptDataException(
              'Failed to validate the integrity of encryption keys. Incorrect password or corrupted file.');
        case _HmacType.HMAC2:
          throw const AesCryptDataException(
              'Failed to validate the integrity of encrypted data. The file is corrupted.');
        case _HmacType.HMAC:
          throw const AesCryptDataException(
              'Failed to validate the integrity of decrypted data. Incorrect password or corrupted file.');
      }
    }
  }

  // Converts the given extension data in to binary data
  Uint8List _getUserDataAsBinary() {
    List<int> output = [];

    int len;
    for (MapEntry<String, List<int>> me
        in _userdata.entries) {
      len = me.key.length + 1 + me.value.length;
      output.addAll([0, len]);
      output
          .addAll([...utf8.encode(me.key), 0, ...me.value]);
    }

    //Also insert a 128 byte container
    output.addAll([0, 128]);
    output.addAll(List<int>.filled(128, 0));

    //2 finishing NULL bytes to signify end of extensions
    output.addAll([0, 0]);

    return Uint8List.fromList(output);
  }

  void _createDataParts() {
    _log('PASSWORD', _passBytes);

    for (var v in _dp.values) {
      v.fillByZero();
    }

    _dp[_Data.head] =
        Uint8List.fromList(<int>[65, 69, 83, 2, 0]);

    _dp[_Data.userdata] = _getUserDataAsBinary();

    // Create a random IV using the aes implementation
    // IV is based on the block size which is 128 bits (16 bytes) for AES
    _dp[_Data.iv1] = createIV();
    _log('IV_1', _dp[_Data.iv1]);

    // Use this IV and password to generate the first encryption key
    // We don't need to use AES for this as its just lots of sha hashing
    _dp[_Data.key1] =
        _keysJoin(_dp[_Data.iv1]!, _passBytes);
    _log('KEY_1', _dp[_Data.key1]);

    // Create another set of keys to do the actual file encryption
    _dp[_Data.iv2] = createIV();
    _log('IV_2', _dp[_Data.iv2]);
    _dp[_Data.key2] = createKey();
    _log('KEY_2', _dp[_Data.key2]);

    // Encrypt the second set of keys using the first keys
    _aes.aesSetParams(
        _dp[_Data.key1]!, _dp[_Data.iv1]!, AesMode.cbc);
    _dp[_Data.enckeys] = _aes.aesEncrypt(
        _dp[_Data.iv2]!.addList(_dp[_Data.key2]!));
    _log('ENCRYPTED KEYS', _dp[_Data.enckeys]);

    // Calculate HMAC1 using the first enc key
    _dp[_Data.hmac1] =
        hmacSha256(_dp[_Data.key1]!, _dp[_Data.enckeys]!);
    _log('HMAC_1', _dp[_Data.hmac1]);
  }

  Map<_Data, Uint8List> _readKeysSync(RandomAccessFile f) {
    Map<_Data, Uint8List> keys = {};

    final Uint8List head =
        _readChunkBytesSync(f, 3, 'file header');
    final Uint8List expected_head =
        Uint8List.fromList([65, 69, 83]);
    if (head.isNotEqual(expected_head)) {
      throw AesCryptDataException(
          "The chunk 'file header' was expected to be ${expected_head.toHexString()} but found ${head.toHexString()}");
    }

    final int version_chunk =
        _readChunkIntSync(f, 1, 'version byte');
    if (version_chunk == 0 || version_chunk > 2) {
      f.closeSync();
      throw AesCryptDataException(
          "Unsupported version chunk: $version_chunk");
    }

    _readChunkIntSync(f, 1, 'reserved byte', 0);

    // User data
    if (version_chunk == 2) {
      int ext_length =
          _readChunkIntSync(f, 2, 'extension length');
      while (ext_length != 0) {
        _readChunkBytesSync(
            f, ext_length, 'extension content');
        ext_length =
            _readChunkIntSync(f, 2, 'extension length');
      }
    }

    // Initialization Vector (IV) used for encrypting the IV and symmetric key
    // that is actually used to encrypt the bulk of the plaintext file.
    final Uint8List iv_1 =
        _readChunkBytesSync(f, 16, 'IV 1');
    _log('IV_1', iv_1);

    final Uint8List key_1 = _keysJoin(iv_1, _passBytes);
    _log('KEY DERIVED FROM IV_1 & PASSWORD', key_1);

    // Encrypted IV and 256-bit AES key used to encrypt the bulk of the file
    // 16 octets - initialization vector
    // 32 octets - encryption key
    final Uint8List enc_keys =
        _readChunkBytesSync(f, 48, 'Encrypted Keys');
    _log('ENCRYPTED KEYS', enc_keys);

    // HMAC
    final Uint8List hmac_1 =
        _readChunkBytesSync(f, 32, 'HMAC 1');
    _log('HMAC_1', hmac_1);

    _validateHMAC(key_1, enc_keys, hmac_1, _HmacType.HMAC1);

    _aes.aesSetParams(key_1, iv_1, AesMode.cbc);
    final Uint8List decrypted_keys =
        _aes.aesDecrypt(enc_keys);
    _log('DECRYPTED_KEYS', decrypted_keys);
    keys[_Data.iv2] = decrypted_keys.sublist(0, 16);
    _log('IV_2', keys[_Data.iv2]);
    keys[_Data.key2] = decrypted_keys.sublist(16);
    _log('ENCRYPTION KEY 2', keys[_Data.key2]);

    return keys;
  }

  Future<Map<_Data, Uint8List>> _readKeys(
      RandomAccessFile f) async {
    Map<_Data, Uint8List> keys = {};

    final Uint8List head =
        await _readChunkBytes(f, 3, 'file header');
    final Uint8List expected_head =
        Uint8List.fromList([65, 69, 83]);
    if (head.isNotEqual(expected_head)) {
      throw AesCryptDataException(
          "The chunk 'file header' was expected to be ${expected_head.toHexString()} but found ${head.toHexString()}");
    }

    final int version_chunk =
        await _readChunkInt(f, 1, 'version byte');
    if (version_chunk == 0 || version_chunk > 2) {
      f.closeSync();
      throw AesCryptDataException(
          'Unsupported version chunk: $version_chunk');
    }

    await _readChunkInt(f, 1, 'reserved byte', 0);

    // User data
    if (version_chunk == 2) {
      int ext_length =
          await _readChunkInt(f, 2, 'extension length');
      while (ext_length != 0) {
        await _readChunkBytes(
            f, ext_length, 'extension content');
        ext_length =
            await _readChunkInt(f, 2, 'extension length');
      }
    }

    // Initialization Vector (IV) used for encrypting the IV and symmetric key
    // that is actually used to encrypt the bulk of the plaintext file.
    final Uint8List iv_1 =
        await _readChunkBytes(f, 16, 'IV 1');
    _log('IV_1', iv_1);

    final Uint8List key_1 = _keysJoin(iv_1, _passBytes);
    _log('KEY DERIVED FROM IV_1 & PASSWORD', key_1);

    // Encrypted IV and 256-bit AES key used to encrypt the bulk of the file
    // 16 octets - initialization vector
    // 32 octets - encryption key
    final Uint8List enc_keys =
        await _readChunkBytes(f, 48, 'Encrypted Keys');
    _log('ENCRYPTED KEYS', enc_keys);

    // HMAC
    final Uint8List hmac_1 =
        await _readChunkBytes(f, 32, 'HMAC 1');
    _log('HMAC_1', hmac_1);

    _validateHMAC(key_1, enc_keys, hmac_1, _HmacType.HMAC1);

    _aes.aesSetParams(key_1, iv_1, AesMode.cbc);
    final Uint8List decrypted_keys =
        _aes.aesDecrypt(enc_keys);
    _log('DECRYPTED_KEYS', decrypted_keys);
    keys[_Data.iv2] = decrypted_keys.sublist(0, 16);
    _log('IV_2', keys[_Data.iv2]);
    keys[_Data.key2] = decrypted_keys.sublist(16);
    _log('ENCRYPTION KEY 2', keys[_Data.key2]);

    return keys;
  }

  String _makeDestFilenameFromSource(String srcFilePath,
      String destFilePath, _Action action) {
    assert(!srcFilePath.isNullOrEmpty);

    String destFilePath0 = destFilePath;
    if (destFilePath.isNullOrEmpty) {
      switch (action) {
        case _Action.encrypting:
          destFilePath0 = srcFilePath + _encFileExt;
          break;
        case _Action.decripting:
          if (srcFilePath != _encFileExt &&
              srcFilePath.endsWith(_encFileExt)) {
            destFilePath0 = srcFilePath.substring(
                0, srcFilePath.length - 4);
          } else {
            destFilePath0 = '$srcFilePath.decrypted';
          }
          break;
      }
    }

    return destFilePath0;
  }

  String _modifyDestinationFilenameSync(
      String destFilePath) {
    String destFilePath0 = destFilePath;
    switch (_owMode) {
      case AesCryptOwMode.rename:
        int i = 1;
        while (_isPathExistsSync(destFilePath0)) {
          destFilePath0 = destFilePath0.replaceAllMapped(
              RegExp(r'(.*/)?([^\.]*?)(\(\d+\)\.|\.)(.*)'),
              (Match m) =>
                  '${m[1] ?? ''}${m[2]}($i).${m[4]}');
          ++i;
        }
        break;
      case AesCryptOwMode.warn:
        if (_isPathExistsSync(destFilePath0)) {
          throw AesCryptException(
              "Failed to overwrite existing file $destFilePath0. An overwriting is forbidden by 'AesCryptOwMode.warn' mode.",
              AesCryptExceptionType.destFileExists);
        }
        break;
      case AesCryptOwMode.on:
        if (_isPathExistsSync(destFilePath0) &&
            FileSystemEntity.typeSync(destFilePath0) !=
                FileSystemEntityType.file) {
          throw AesCryptArgumentError(
              'Destination path $destFilePath0 is not a file and can not be overwritten.');
        }
        //File(destFilePath).deleteSync();
        break;
    }

    return destFilePath0;
  }

  Future<String> _modifyDestinationFilename(
      String destFilePath) async {
    String destFilePath0 = destFilePath;
    switch (_owMode) {
      case AesCryptOwMode.rename:
        int i = 1;
        while (await _isPathExists(destFilePath0)) {
          destFilePath0 = destFilePath0.replaceAllMapped(
              RegExp(r'(.*/)?([^.]*?)(\(\d+\)\.|\.)(.*)'),
              (Match m) =>
                  '${m[1] ?? ''}${m[2]}($i).${m[4]}');
          ++i;
        }
        break;
      case AesCryptOwMode.warn:
        if (await _isPathExists(destFilePath0)) {
          throw AesCryptException(
              "Failed to overwrite existing file $destFilePath0. An overwriting is forbidden by 'AesCryptOwMode.warn' mode.",
              AesCryptExceptionType.destFileExists);
        }
        break;
      case AesCryptOwMode.on:
        if ((await _isPathExists(destFilePath0)) &&
            (await FileSystemEntity.type(destFilePath0)) !=
                FileSystemEntityType.file) {
          throw AesCryptArgumentError(
              'Destination path $destFilePath0 is not a file and can not be overwritten.');
        }
        //await File(destFilePath).delete();
        break;
    }

    return destFilePath0;
  }

  int _readChunkIntSync(
      RandomAccessFile f, int num_bytes, String chunk_name,
      [int? expected_value]) {
    late int result;
    late Uint8List data;

    try {
      data = f.readSync(num_bytes);
    } on FileSystemException catch (e) {
      throw FileSystemException(
          "Failed to read chunk '$chunk_name' of $num_bytes bytes.",
          e.path,
          e.osError);
    }
    if (data.length != num_bytes) {
      throw AesCryptDataException(
          "Failed to read chunk '$chunk_name' of $num_bytes bytes, only found ${data.length} bytes.");
    }

    switch (num_bytes) {
      case 1:
        result = data[0];
        break;
      case 2:
        result = data[0] << 8 | data[1];
        break;
      case 3:
        result = data[0] << 16 | data[1] << 8 | data[2];
        break;
      case 4:
        result = data[0] << 24 |
            data[1] << 16 |
            data[2] << 8 |
            data[3];
        break;
    }

    if (expected_value != null &&
        result != expected_value) {
      throw AesCryptDataException(
          "The chunk '$chunk_name' was expected to be 0x${expected_value.toRadixString(16).toUpperCase()} but found 0x${data.toHexString()}");
    }

    return result;
  }

  Future<int> _readChunkInt(
      RandomAccessFile f, int num_bytes, String chunk_name,
      [int? expected_value]) async {
    late int result;
    late Uint8List data;

    try {
      data = await f.read(num_bytes);
    } on FileSystemException catch (e) {
      throw FileSystemException(
          "Failed to read chunk '$chunk_name' of $num_bytes bytes.",
          e.path,
          e.osError);
    }
    if (data.length != num_bytes) {
      throw AesCryptDataException(
          "Failed to read chunk '$chunk_name' of $num_bytes bytes, only found ${data.length} bytes.");
    }

    switch (num_bytes) {
      case 1:
        result = data[0];
        break;
      case 2:
        result = data[0] << 8 | data[1];
        break;
      case 3:
        result = data[0] << 16 | data[1] << 8 | data[2];
        break;
      case 4:
        result = data[0] << 24 |
            data[1] << 16 |
            data[2] << 8 |
            data[3];
        break;
    }

    if (expected_value != null &&
        result != expected_value) {
      throw AesCryptDataException(
          "The chunk '$chunk_name' was expected to be 0x${expected_value.toRadixString(16).toUpperCase()} but found 0x${data.toHexString()}");
    }

    return result;
  }

  Uint8List _readChunkBytesSync(RandomAccessFile f,
      int num_bytes, String chunk_name) {
    late Uint8List data;
    try {
      data = f.readSync(num_bytes);
    } on FileSystemException catch (e) {
      throw AesCryptFsException(
          "Failed to read chunk '$chunk_name' of $num_bytes bytes.",
          e.path ?? ' ',
          e.osError);
    }
    if (data.length != num_bytes) {
      throw AesCryptDataException(
          "Failed to read chunk '$chunk_name' of $num_bytes bytes, only found ${data.length} bytes.");
    }
    return data;
  }

  Future<Uint8List> _readChunkBytes(RandomAccessFile f,
      int num_bytes, String chunk_name) async {
    late Uint8List data;
    try {
      data = await f.read(num_bytes);
    } on FileSystemException catch (e) {
      throw AesCryptFsException(
          "Failed to read chunk '$chunk_name' of $num_bytes bytes.",
          e.path ?? ' ',
          e.osError);
    }
    if (data.length != num_bytes) {
      throw AesCryptDataException(
          "Failed to read chunk '$chunk_name' of $num_bytes bytes, only found ${data.length} bytes.");
    }
    return data;
  }

  void _log(String name, dynamic msg) {
    if (_debug) {
      debugPrint(
          '$name - ${msg is Uint8List ? msg.toHexString() : msg}');
    }
  }

  bool _isPathExistsSync(String path) {
    return FileSystemEntity.typeSync(path) !=
        FileSystemEntityType.notFound;
  }

  Future<bool> _isPathExists(String path) async {
    return (await FileSystemEntity.type(path)) !=
        FileSystemEntityType.notFound;
  }
}

/// Enum that specifies the type of [AesCryptException] exception.
enum AesCryptExceptionType {
  /// Exception of this type is thrown when [AesCryptOwMode] is set as
  /// [AesCryptOwMode.warn] and some encryption or decryption function
  /// tries to overwrite existing file.
  destFileExists,
}

/// Exception thrown when some error is happened. A type of the error is indicated
/// by [type] class member.
///
/// At present there is only one type: [AesCryptExceptionType.destFileExists].
/// AesCryptException having AesCryptExceptionType.destFileExists type is thrown
/// when overwrite mode set as [AesCryptOwMode.warn] and there is a file with the same name
/// as the file which is going to be written during encryption or decryption process.
class AesCryptException implements Exception {
  /// Message describing the problem.
  final String message;

  /// Type of an exception.
  final AesCryptExceptionType type;

  /// Creates a new AesCryptException with an error message [message] and type [type].
  const AesCryptException(this.message, this.type);

  /// Returns a string representation of this object.
  @override
  String toString() => message;
}

/// Error thrown when a function is passed an unacceptable argument.
class AesCryptArgumentError extends ArgumentError {
  /// Creates a new AesCryptArgumentError with an error message [message]
  /// describing the erroneous argument.
  AesCryptArgumentError(String message) : super(message);

  /// Throws [AesCryptArgumentError] if [argument] is: null [Object], empty [String] or empty [Iterable]
  static void checkNullOrEmpty(
      Object argument, String message) {
    // if (argument == null ||
    //     ((argument is String) ? argument.isEmpty : false) ||
    //     ((argument is Iterable) ? argument.isEmpty : false)) {
    //   throw AesCryptArgumentError(message);
    // }
    if (argument == null ||
        (argument is String && argument.isEmpty) ||
        (argument is Iterable && argument.isEmpty)) {
      throw AesCryptArgumentError(message);
    }
  }
}

/// Exception thrown when the file system operation fails.
class AesCryptFsException extends FileSystemException {
  /// Creates a new AesCryptFsException with an error message [message],
  /// optional file system path [path] and optional OS error [osError].
  const AesCryptFsException(String message,
      [String path = '', OSError? osError])
      : super(message, path, osError);
}

/// Exception thrown when an integrity of encrypted data is compromised.
class AesCryptDataException implements Exception {
  /// Message describing the problem.
  final String message;

  /// Creates a new AesCryptDataException with an error message [message].
  const AesCryptDataException(this.message);

  /// Returns a string representation of this object.
  @override
  String toString() => message;
}

extension _Uint8ListExtension on Uint8List {
  bool get isNullOrEmpty => this == null || isEmpty;

  Uint8List addList(Uint8List other) {
    int totalLength = length + other.length;
    Uint8List newList = Uint8List(totalLength);
    newList.setAll(0, this);
    newList.setRange(length, totalLength, other);
    return newList;
  }

  bool isNotEqual(Uint8List other) {
    if (identical(this, other)) return false;
    if (this != null && other == null) return true;
    int length = this.length;
    if (length != other.length) return true;
    for (int i = 0; i < length; i++) {
      if (this[i] != other[i]) return true;
    }
    return false;
  }

  // Converts bytes to UTF-16 string
  String toUtf16String([Endian endian = Endian.big]) {
    StringBuffer buffer = StringBuffer();
    int i = 0;
    if (this[0] == 0xFE && this[1] == 0xFF) {
      endian = Endian.big;
      i += 2;
    } else if (this[0] == 0xFF && this[1] == 0xFE) {
      endian = Endian.little;
      i += 2;
    }
    while (i < length) {
      int firstWord = (endian == Endian.big)
          ? (this[i] << 8) + this[i + 1]
          : (this[i + 1] << 8) + this[i];
      if (0xD800 <= firstWord && firstWord <= 0xDBFF) {
        int secondWord = (endian == Endian.big)
            ? (this[i + 2] << 8) + this[i + 3]
            : (this[i + 3] << 8) + this[i + 2];
        buffer.writeCharCode(((firstWord - 0xD800) << 10) +
            (secondWord - 0xDC00) +
            0x10000);
        i += 4;
      } else {
        buffer.writeCharCode(firstWord);
        i += 2;
      }
    }
    return buffer.toString();
  }

  // Converts bytes to UTF-8 string
  String toUtf8String() {
    Uint8List data = this;
    if (this[0] == 0xEF &&
        this[1] == 0xBB &&
        this[2] == 0xBF) {
      data = buffer.asUint8List(3, length - 3); // skip BOM
    }
    return utf8.decode(data);
  }

  String toHexString() {
    StringBuffer str = StringBuffer();
    forEach((item) {
      str.write(item
          .toRadixString(16)
          .toUpperCase()
          .padLeft(2, '0'));
    });
    return str.toString();
  }

  void fillByZero() => fillRange(0, length, 0);
}

extension _StringExtension on String {
  // Returns true if string is: null or empty
  bool get isNullOrEmpty => this == null || isEmpty;

  // Converts UTF-16 string to bytes
  Uint8List toUtf16Bytes(
      [Endian endian = Endian.big, bool bom = false]) {
    List<int> list = bom
        ? (endian == Endian.big
            ? [0xFE, 0xFF]
            : [0xFF, 0xFE])
        : [];
    for (var rune in runes) {
      if (rune >= 0x10000) {
        int firstWord =
            (rune >> 10) + 0xD800 - (0x10000 >> 10);
        int secondWord = (rune & 0x3FF) + 0xDC00;
        if (endian == Endian.big) {
          list.add(firstWord >> 8);
          list.add(firstWord & 0xFF);
          list.add(secondWord >> 8);
          list.add(secondWord & 0xFF);
        } else {
          list.add(firstWord & 0xFF);
          list.add(firstWord >> 8);
          list.add(secondWord & 0xFF);
          list.add(secondWord >> 8);
        }
      } else {
        if (endian == Endian.big) {
          list.add(rune >> 8);
          list.add(rune & 0xFF);
        } else {
          list.add(rune & 0xFF);
          list.add(rune >> 8);
        }
      }
    }
    return Uint8List.fromList(list);
  }

  // Converts string to UTF-8 bytes
  List<int> toUtf8Bytes([bool bom = false]) {
    if (bom) {
      final Uint8List data =
          Uint8List.fromList(utf8.encode(this));
      final Uint8List dataWithBom =
          Uint8List(data.length + 3)
            ..setAll(0, [0xEF, 0xBB, 0xBF])
            ..setRange(3, data.length + 3, data);
      return dataWithBom;
    }
    return utf8.encode(this);
  }
}

extension _FileExtension on File {
  bool isReadable() {
    RandomAccessFile f;

    try {
      f = openSync(mode: FileMode.read);
    } on FileSystemException {
      return false;
    }

    try {
      f.lockSync(FileLock.shared);
    } on FileSystemException {
      f.closeSync();
      return false;
    }

    f.unlockSync();
    f.closeSync();
    return true;
  }
}
