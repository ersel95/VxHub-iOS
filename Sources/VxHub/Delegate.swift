//
//  Delegate.swift
//  VxHub
//
//  Created by Mr. t. on 18.09.2024.
//

public protocol VxHubInitDelegate {
    func inittedSuccess(_ data: VxDeviceData)
    func initFailWithError(_ error: VxErrorModel)
}
