//
//  Delegate.swift
//  VxHub
//
//  Created by Mr. t. on 18.09.2024.
//

public protocol VxHubDelegate {
    func inittedSuccess(_ data: VxDeviceData)
    func initFailWithError(_ error: VxErrorModel)
}
