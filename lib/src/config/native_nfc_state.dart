
enum NativeNfcState {

  /// Unknown error (should check more log to find out the cause of the error)
  UNKNOWN,

  /// Successful NFC reading returns error in Log
  SUCCESS_WITH_WARNING,

  /// The device has NFC support but cannot connect to the system's NFC function
  CANNOT_OPEN_DEVICE,

  /// Can't identify card read
  CARD_NOT_FOUND,

  /// Wrong citizen ID code
  WRONG_CITIZEN_ID_CARD,

  /// The card is out of the NFC reading area or the connection to the card is lost (system error)
  CARD_LOST_CONNECTION,

  /// NFC is off
  NFC_IS_OFF,

  /// Devices that do not support NFC
  ERROR_CODE_UN_SUPPORT_NFC,

  /// Device OS lower than required (Api level 23 - Android 5)
  ERROR_CODE_UN_SUPPORT_API_VERSION,

  /// NFC read timeout (default 20s)
  ERROR_CODE_TIME_OUT
}