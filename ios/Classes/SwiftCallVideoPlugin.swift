import Flutter
import UIKit
import NFCReader

let NFC_READY_TO_SCAN = "Vui lòng đặt CCCD vào để bắt đầu đọc"
let NFC_READING_DATA = "Đang đọc dữ liệu"
let NFC_SUCCESSFUL = "Thành công"
let NFC_ERROR = "Có lỗi xảy ra"

@available(iOS 13, *)
public class SwiftCallVideoPlugin: NSObject, FlutterPlugin {
    var saveResult: FlutterResult?
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "com.example/call_video", binaryMessenger: registrar.messenger())
    let instance = SwiftCallVideoPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      switch call.method {
      case "startNFC":
          print("handle nfc with arguments", call.arguments as Any)
          if let arg = call.arguments as? [String: String],
             let dob = arg["dob"],
             let id = arg["id"],
             let doe = arg["doe"] {
              let nfc = NFCManager(dateOfBirthYYMMDD: dob,
                                   dateOfExpireYYMMDD: doe,
                                   cardID: id,
                                   isCheckBCA: true)
            saveResult = result
            nfc.delegate = self
            // Set URL API
//              nfc.setDomainURL("https://apig.idcheck.xplat.online/real-id/v1/api-gateway/check-nfc-objdg")
            // Set Token
//              nfc.setToken(token)
            nfc.scanPassport()
          }

      default:
          result(nil)
      }
  }

}
@available(iOS 13, *)
extension SwiftCallVideoPlugin: NFCDelegate {
    public func NFCSuccess(data: [String : Any]) {
        let result = data
        saveResult?(result.description)
    }
    
    public func NFCSuccess(model: NFCReader.NFCPassportModel) {}
    
    public func NFCNotAvaiable() {
        saveResult?(["error": "NFCNotSupported"])
    }

    public func NFCMessageDisplay(_ messages: NFCViewDisplayMessage) -> String {

        switch messages {
        case .requestPresentPassport:
            return  NFC_READY_TO_SCAN
        case .authenticatingWithPassport(_):
            return   ""
        case .readingDataGroupProgress( _, let progress):
            let progressString = handleProgress(percentualProgress: progress)
            return "\(NFC_READING_DATA).....\n\n\(progressString)"
        case .readingDataGroupProgress(let dataGroup , let progress):
            let progressString = handleProgress(percentualProgress: progress)
            return "\(NFC_READING_DATA): \(dataGroup) \n\n\(progressString)"
        case .successfulRead:
            return  NFC_SUCCESSFUL
        case .error(_):
            return  NFC_ERROR
        @unknown default:
            return ""
        }
    }

    public func NFCSuccess() {}

    public func NFCFail(_ error: NFCReader.NFCPassportReaderError) {
        var errorCode = ""
        switch error {
        case .InvalidResponse:
            errorCode = "InvalidResponse"
        case .UnexpectedError:
            errorCode = "UnexpectedError"
        case .NFCNotSupported:
            errorCode = "NFCNotSupported"
        case .NoConnectedTag:
            errorCode = "NoConnectedTag"
        case .D087Malformed:
            errorCode = "D087Malformed"
        case .InvalidResponseChecksum:
            errorCode = "InvalidResponseChecksum"
        case .MissingMandatoryFields:
            errorCode = "MissingMandatoryFields"
        case .CannotDecodeASN1Length:
            errorCode = "CannotDecodeASN1Length"
        case .InvalidASN1Value:
            errorCode = "InvalidASN1Value"
        case .UnableToProtectAPDU:
            errorCode = "UnableToProtectAPDU"
        case .UnableToUnprotectAPDU:
            errorCode = "UnableToUnprotectAPDU"
        case .UnsupportedDataGroup:
            errorCode = "UnsupportedDataGroup"
        case .DataGroupNotRead:
            errorCode = "DataGroupNotRead"
        case .UnknownTag:
            errorCode = "UnknownTag"
        case .UnknownImageFormat:
            errorCode = "UnknownImageFormat"
        case .NotImplemented:
            errorCode = "NotImplemented"
        case .TagNotValid:
            errorCode = "TagNotValid"
        case .ConnectionError:
            errorCode = "ConnectionError"
        case .UserCanceled:
            errorCode = "UserCanceled"
        case .InvalidMRZKey:
            errorCode = "InvalidMRZKey"
        case .MoreThanOneTagFound:
            errorCode = "MoreThanOneTagFound"
        case .InvalidHashAlgorithmSpecified:
            errorCode = "InvalidHashAlgorithmSpecified"
        case .Timeout:
            errorCode = "Timeout"
        case .ResponseError(_, _, _):
            errorCode = "UnknowError"
        case .InvalidDataPassed(_):
            errorCode = "UnknowError"
        case .NotYetSupported(_):
            errorCode = "UnknowError"
        @unknown default:
            errorCode = "UnknowError"
        }
        saveResult?(["error": errorCode])
    }

    public func VerifySuccess(jsonData: NFCReader.JSON) {
        print("handle nfc with arguments")
        saveResult?(jsonData.rawString())
    }

    public func VerifyFail(_ error: NFCReader.AFError) {}

    func handleProgress(percentualProgress: Int) -> String {
        let p = (percentualProgress/20)
        let full = String(repeating: "🔵 ", count: p)
        let empty = String(repeating: "⚪️ ", count: 5-p)
        return "\(full)\(empty)"
    }

}
