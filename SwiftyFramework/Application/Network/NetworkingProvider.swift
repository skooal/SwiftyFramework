//
//  SwiftyFramework
//
//  Created by BANYAN on 2020/1/7.
//  Copyright © 2020 BANYAN. All rights reserved.
//
//
                                // ---------
                                // Providers
                                // _________


// MARK: 用户认证相关
struct AuthenticationNetworking: NetworkingType {
    typealias T = AuthenticationAPI
    
    let provider: OnlineProvider<AuthenticationAPI>
}

extension AuthenticationNetworking {
    func request(_ token: AuthenticationAPI) -> Observable<Moya.Response> {
        let autualRequest = self.provider.request(token)
        return autualRequest
    }
    
    static func stubbingAuthenticationNetworking() -> AuthenticationNetworking {
        return AuthenticationNetworking(provider: OnlineProvider(endpointClosure: endpointsClosure(), requestClosure: endpointResolver(), stubClosure: MoyaProvider.neverStub, plugins: plugins, online: .just(true)))
    }
}



