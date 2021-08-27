//
//  translateTool.swift
//  LocalizabalTool
//
//  Created by 111 on 2021/8/24.
//

import Foundation

class TranslateTool: NSObject {
    var url : String = "https://translate.google.cn/translate_a/single"
    var TKK : String = "434674.96463358"
    var token : String = ""
    var header = [
        "accept": "*/*",
        "accept-language": "zh-CN,zh;q=0.9,en-US;q=0.8,en;q=0.7",
        "cookie": "NID=188=M1p_rBfweeI_Z02d1MOSQ5abYsPfZogDrFjKwIUbmAr584bc9GBZkfDwKQ80cQCQC34zwD4ZYHFMUf4F59aDQLSc79_LcmsAihnW0Rsb1MjlzLNElWihv-8KByeDBblR2V1kjTSC8KnVMe32PNSJBQbvBKvgl4CTfzvaIEgkqss",
        "referer": "https://translate.google.cn/",
        "user-agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1",
        "x-client-data": "CJK2yQEIpLbJAQjEtskBCKmdygEIqKPKAQi5pcoBCLGnygEI4qjKAQjxqcoBCJetygEIza3KAQ==",
    ]

    var data : NSMutableDictionary = ["client": "webapp",  // 基于网页访问服务器
                                      "sl": "auto",  // 源语言,auto表示由谷歌自动识别
                                      "tl": "en",  // 翻译的目标语言
                                      "hl": "zh-CN",  // 界面语言选中文，毕竟URL是cn后缀
                                      "dt": ["at", "bd", "ex", "ld", "md", "qca", "rw", "rm", "ss", "t"],  // dt表示要求服务器返回的数据类型
                                      "otf": "2",
                                      "ssel": "0",
                                      "tsel": "0",
                                      "kc": "1",
                                      "tk": "",  // 谷歌服务器会核对的token
                                      "q": ""  // 待翻译的字符串
    ]
    
    
//    override init() {
//        data.setValue(<#T##value: Any?##Any?#>, forKey: <#T##String#>)
//    }
    
    // 获取google翻译接口的token
    func getToken(_ text : String, complete : @escaping (_ tokenData : String, _ errorMsg : String) -> Void = {_,_ in }) {
        let tkk = self.TKK.replacingOccurrences(of: "'", with: "").replacingOccurrences(of: "tkk:", with: "")
        let url = "https://api.yooul.net/api/google/token?text=\(self.urlencode(url: text))&tkk=\(tkk)"
        self.requestTranslate(url, "GET", [:]) { data , error in
            let respDict = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? Dictionary<String, String>
            complete(respDict?["token"] ?? "", error.localizedDescription)
        }
    }
    
    func urlencode(url : String) -> String {
        var encodedString : String = ""
        let charactersToEscape = "?!@#$^&%*+,:;='\"`<>()[]{}/\\| "
        let allowedCharacters = CharacterSet(charactersIn: charactersToEscape).inverted
        encodedString = url.addingPercentEncoding(withAllowedCharacters: allowedCharacters) ?? url
        return encodedString
    }

    func translate(_ text : String, _ languageCode : String, complete : @escaping (_ originalText : String, _ originalLanguageCode : String, _ translatedText : String, _ targetLanguageCode : String, _ errorMsg : String) -> Void = {_,_,_,_,_  in }) {
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        DispatchQueue.global().async {
            self.getToken(text) { tokenData, errorMsg in
                self.token = tokenData
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: DispatchQueue.global()) {
            self.data.setValue(self.urlencode(url:text), forKey: "q")
            self.data.setValue(self.token, forKey: "tk")
            self.data.setValue(languageCode, forKey: "tl")
//            let apiurl = self.con
            
        }
        
    }

//    func <#name#>(<#parameters#>) -> <#return type#> {
//        dispatch_group_notify(_dispatchGroup, globalQueue, ^{
//            self.data[@"q"] = [text urlencode];
//            self.data[@"tk"] = self.token;
//            self.data[@"tl"] = languageCode;
//            NSString *apiurl = [self constructUrl];
//            [self requestWithUrl:apiurl method:@"GET" header:self.header completionHandler:^(NSData * _Nullable respData, NSError * _Nullable error) {
//                if (error) {
//                    completionHandler(text, nil, nil, nil, error.localizedDescription);
//                    return;
//                }
//                NSError *translatedError = nil;
//                NSArray *respArr = [NSJSONSerialization JSONObjectWithData:respData options:NSJSONReadingAllowFragments error:&translatedError];
//                if (translatedError) {
//                    completionHandler(text, nil, nil, nil, translatedError.localizedDescription);
//                    return;
//                }
//                NSString *translatedText = @"";
//                for (NSArray *subarr in [respArr firstObject]) {
//                    if ([subarr isKindOfClass:[NSArray class]]) {
//                        if ([subarr firstObject] == [NSNull null]) {
//                            break;
//                        }
//                        translatedText = [NSString stringWithFormat:@"%@%@", translatedText, [subarr firstObject]];
//                    }
//                }
//                if ([translatedText length] <= 0) {
//                      translatedText = [[[respArr firstObject] firstObject] firstObject];
//                }
//                NSString *originLanguageCode = respArr[2];
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    completionHandler(text, originLanguageCode, translatedText, languageCode, nil);
//                });
//            }];
//        });
//    }

    
//    func constructUrl() -> String {
//        var base : String = ""
//        for key in self.data.allKeys {
//            let value = self.data.value(forKey: key as! String)
//
//            if valu {
//                <#code#>
//            }
//        }
//
//    }
//
//    - (NSString *)constructUrl {
//        NSString *base = @"";
//        for (NSString *key in [self.data allKeys]) {
//            if ([self.data[key] isKindOfClass:[NSArray class]]) {
//                NSArray *valueArr = self.data[key];
//                NSString *dtStr = @"";
//                for (NSString *s in valueArr) {
//                    if ([dtStr length] > 0) {
//                        dtStr = [NSString stringWithFormat:@"%@&dt=%@", dtStr, s];
//                    } else {
//                        dtStr = [NSString stringWithFormat:@"%@dt=%@", dtStr, s];
//                    }
//                }
//                base = [NSString stringWithFormat:@"%@%@&", base, dtStr];
//            } else {
//                base = [NSString stringWithFormat:@"%@%@=%@&", base, key, self.data[key]];
//            }
//        }
//        base = [base substringToIndex:[base length] - 1];
//        base = [NSString stringWithFormat:@"%@?%@", self.url, base];
//
//        return base;
//    }

    
    
    //获取翻译
    func requestTranslate(_ apiUrlStr : String, _ method :String, _ header : [String : String], complete : @escaping (Data, Error) -> Void = {_,_ in }) {
        let url = URL(string: apiUrlStr)!
        var request = URLRequest(url: url)
        request.httpMethod = method
        if header.count > 0 {
            request.allHTTPHeaderFields = header
        }
        let configuration:URLSessionConfiguration = URLSessionConfiguration.default
        let session: URLSession = URLSession(configuration: configuration)
        // NSURLSessionTask
        let task:URLSessionDataTask = session.dataTask(with: request) { data , respond , error in
            if error == nil {
                do {
                    let result:NSDictionary = try JSONSerialization.jsonObject(with: data!,options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
                    print(result)
                    
                    DispatchQueue.main.async {
                        let message:String = result.object(forKey: "msg") as! String
                    }
                    
                } catch {
                    
                }
            }
        }

        // 启动任务
        task.resume()
        
    }
}
