//
//  ViewModelType.swift
//  SwiftyFramework
//
//  Created by BANYAN on 2020/1/7.
//  Copyright © 2020 BANYAN. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ObjectMapper

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}

class BaseViewModel: NSObject {
    
    // MARK: - Properties
    
    let loading = ActivityIndicator()
    let headerLoading = ActivityIndicator()
    let footerLoading = ActivityIndicator()
    
    let error = ErrorTracker()
    
    /// 解析服务器返回错误模型
    let parsedError = PublishSubject<APIError>()
    
    /// 自定义服务器返回错误模型
    let errorResponse = PublishSubject<ErrorResponse>()
    
    /// 初始化分页
    var currentPage = 1
    
    /// 分页总数
    var totalPage = 1
    
    /// 单次分页条数
    var pageSize = 100
        
    /// 用于判断是否到达最后一页
    let lastPageSubject = PublishSubject<Bool>()
    
    deinit {
        DDLogInfo("\(self.className)已释放")
    }
    
    override init() {
        super.init()
        
        // network request success
        error.asObservable().map { (error) -> APIError? in
            do {
                let errorResponse = error as? MoyaError
                if let body = try errorResponse?.response?.mapJSON() as? [String: Any],
                    let errorResponse = Mapper<ErrorResponse>().map(JSON: body) {
                    DDLogInfo("\(errorResponse)")
                    if errorResponse.code != nil {
                        self.errorResponse.onNext(errorResponse)
                    }

                    return APIError.serverError(response: errorResponse)
                }
            } catch {
                DDLogError(error.localizedDescription)
            }
            return nil
        }.filterNil().bind(to: parsedError).disposed(by: rx.disposeBag)
        
        // network request failed
        error.asDriver().drive(onNext: { [weak self] (error) in
            guard let self = self else { return }
            
            // TODO: 需要将错误转换成中文
            DDLogError(" \(self.className) 服务器错误：\(error.localizedDescription)")
        }).disposed(by: rx.disposeBag)
    }
    
}
