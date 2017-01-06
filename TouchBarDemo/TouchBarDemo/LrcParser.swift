//
//  LrcParser.swift
//  TouchBarDemo
//
//  Created by 朱德坤 on 2016/12/30.
//  Copyright © 2016年 朱德坤. All rights reserved.
//

import Foundation

/// 音乐信息
enum MusicInfoTag: String, CustomStringConvertible {
    case ti
    case ar
    case al
    case by
    case offset
    case t_time
    case empty
    
    var description: String {
        switch self {
        case .ti:       return "歌曲名"
        case .ar:       return "歌手名"
        case .al:       return "专辑"
        case .by:       return "编辑者"
        case .offset:   return "补偿"
        case .t_time:   return "时长"
        case .empty:    return ""
        }
    }
}

struct MusicInfo {
    var ti =        ""
    var ar =        ""
    var al =        ""
    var by =        ""
    var offset =    ""
    var t_time =    ""
}
/// 一行歌词的信息
struct LrcLine {
    var lrc: String!
    var s: Int = 0
    var m: Int = 0
    var ms: Int = 0
    // 当前行所在秒数
    var sec: Double {
        return Double(m * 60 + s) + Double(ms) / 1000.0
    }
    var secString: String!
    init(secString: String, lrc: String) {
        self.lrc = lrc
        self.secString = secString
        //        m = Int( secString.subString(from: 0, to: 2)) ?? 0
        //        s = Int( secString.subString(from: 3, to: 5)) ?? 0
        //        ms = Int( secString.subString(from: 6, to: 8)) ?? 0
        let scan = Scanner(string: secString)
        scan.scanUpToCharacters(from: .decimalDigits, into: nil)
        scan.scanInt(&m)
        scan.scanUpToCharacters(from: .decimalDigits, into: nil)
        scan.scanInt(&s)
        scan.scanUpToCharacters(from: .decimalDigits, into: nil)
        scan.scanInt(&ms)
    }
    
}

class LrcParser {
    var musicInfo: MusicInfo = MusicInfo()
    var lrcLines = [LrcLine]()
    private let emptyLine = LrcLine(secString: "00:00:00 ", lrc: "")
    public init(_ string: String) {
        if string.isEmpty {
            return
        }
        // 1.将歌词拆成行
        let lines = string.components(separatedBy: "\n")
        for aLine in lines {
            // 2.解析歌词信息
            // 空白行继续
            if (aLine as NSString).length == 0 {
                continue
            } else if aLine.hasPrefix("[") && aLine.hasSuffix("]") {
                let tempindex = (string as NSString).range(of: ":").location
                switch MusicInfoTag(rawValue: aLine.subString(from: 1, to: tempindex)) ?? MusicInfoTag.empty {
                case .ti: musicInfo.ti = aLine.subString(fromStart: tempindex + 1, toEnd: 1)
                case .al: musicInfo.al = aLine.subString(fromStart: tempindex + 1, toEnd: 1)
                case .by: musicInfo.by = aLine.subString(fromStart: tempindex + 1, toEnd: 1)
                case .offset: musicInfo.offset = aLine.subString(fromStart: tempindex + 5, toEnd: 1)
                case .ar: musicInfo.ar = aLine.subString(fromStart: tempindex + 1, toEnd: 1)
                case .t_time: musicInfo.t_time = aLine.subString(fromStart: tempindex + 4, toEnd: 1)
                default: break
                }
            } else {
                // 3.将每行歌词转换成LrcString
                do {
                    let timeRegular = try NSRegularExpression(pattern: "\\[(\\d{0,2}:\\d{0,2}[.|:]\\d{0,2})\\].*?", options: .caseInsensitive)
                    let timeMatches = timeRegular.matches(in: aLine, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSRange(location: 0, length: (aLine as NSString).length))
                    if timeMatches.count > 0 {
                        let range = timeMatches[0].rangeAt(1)
                        let secString = aLine.subString(from: range.location, to: range.location + range.length)
                        let lrc = aLine.subString(fromStart: range.location + range.length + 1, toEnd: 0)
                        lrcLines.append(LrcLine(secString: secString, lrc: lrc))
                        // print(secString+" : "+lrc)
                    }
                } catch {
                    print("LrcPrase Error")
                }
                
            }
        }
        
    }
    // 4.添加其他功能函数
    
    /// 根据时间点返回歌词行
    ///
    /// - Parameter timeSecond: 时间点（秒数）
    /// - Returns: 一行歌词
    func lineAt(timeSecond: Double) -> LrcLine {
        if lrcLines.count <= 0 { return emptyLine }
        switch timeSecond {
        case 0:
            return lrcLines.first!
        case 0...lrcLines.last!.sec:
            for index in 0..<lrcLines.count - 1 {
                if lrcLines[index].sec <= timeSecond && lrcLines[index + 1].sec > timeSecond {
                    return lrcLines[index]
                }
            }
            return lrcLines.last!
        case lrcLines.last!.sec...Double(Int.max):
            return lrcLines.last!
        default:
            return emptyLine
        }
    }
    
    /// 返回时间段内的歌词行
    ///
    /// - Parameters:
    ///   - fromTime: 开始时间
    ///   - toTime: 结束时间
    /// - Returns: 歌词行数组
    func linesIn(fromTime: Double, toTime: Double) -> [LrcLine] {
        
        let startTime = fromTime > toTime ? toTime : fromTime
        let endTime = fromTime > toTime ? toTime : fromTime
        var lines: [LrcLine] = [LrcLine]()
        
        for index in 0..<lrcLines.count - 1 {
            if lrcLines[index].sec <= startTime && lrcLines[index + 1].sec > startTime {
                lines.append(lrcLines[index])
            }else if lrcLines[index].sec >= startTime && lrcLines[index].sec <= endTime {
                lines.append(lrcLines[index])
            }else if lrcLines[index].sec <= endTime && lrcLines[index + 1].sec > endTime {
                lines.append(lrcLines[index])
            }
        }
        return lines
    }
}

extension String {
    
    /// 截取子字符串 from..<to
    ///
    /// - Parameters:
    ///   - from: 起始位置(包括)
    ///   - to: 结束位置（不包括）
    /// - Returns: 子字符串
    func subString(from: Int, to: Int) -> String {
        return substring(with: Range<String.Index>(uncheckedBounds: (lower: index(startIndex, offsetBy: from), upper: index(startIndex, offsetBy: to))))
    }
    
    /// 截取子串|...fromStart.....toEnd...|
    ///
    /// - Parameters:
    ///   - fromStart: 从前往后第几个字符开始（取得到）
    ///   - toEnd: 从后往前第几个字符结束（取得到）
    /// - Returns: 子字符串
    func subString(fromStart: Int, toEnd: Int) -> String {
        return substring(with: Range<String.Index>(uncheckedBounds: (lower: index(startIndex, offsetBy: fromStart), upper: index(endIndex, offsetBy: 0 - toEnd))))
    }
}
