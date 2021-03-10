//
//  LoginResponse.swift
//  duTest
//
//  Created by Prateek Kansara on 09/03/21.
//

/// Assumed Oauth implementation, can be changed as per the response being received.
struct LoginResponse : Decodable{
    var access_token : String
    var refresh_token : String
}

