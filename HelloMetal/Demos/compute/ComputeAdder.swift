//
//  ComputeAdder.swift
//  HelloMetal
//
//  Created by yaoxp on 2022/8/10.
//

import Foundation
import Metal

//fileprivate let arrayLength = 1 << 16
//fileprivate let bufferSize = arrayLength * MemoryLayout.stride(ofValue: Float.self)
fileprivate let arrayLength = 1 << 16
fileprivate let bufferSize = arrayLength * MemoryLayout<Float>.stride
class ComputeAdder {
    
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var addFunctionPSO: MTLComputePipelineState!
    var bufferA: MTLBuffer!
    var bufferB: MTLBuffer!
    var bufferResult: MTLBuffer!
    
    init?(with GPUDevice: MTLDevice) {
        device = GPUDevice
        guard let library = device.makeDefaultLibrary() else {
            logger.error("Failed to find the default library")
            return nil
        }
        guard let addFunc = library.makeFunction(name: "add_arrays") else {
            logger.error("Failed to find the add function")
            return nil
        }
        
        do {
            addFunctionPSO = try device.makeComputePipelineState(function: addFunc)
        } catch {
            logger.error("Failed to create a compute pipeline state.")
            return nil
        }
        commandQueue = device.makeCommandQueue()
    }
    
    func createBufferData() {
        bufferA = device.makeBuffer(length: bufferSize, options: .storageModeShared)
        bufferB = device.makeBuffer(length: bufferSize, options: .storageModeShared)
        bufferResult = device.makeBuffer(length: bufferSize, options: .storageModeShared)
        
        let pointA = bufferA.contents().bindMemory(to: Float.self, capacity: arrayLength)
        let pointB = bufferB.contents().bindMemory(to: Float.self, capacity: arrayLength)
        for index in 0..<arrayLength {
            pointA[index] = Float.random(in: -1000000.0...1000000.0)
            pointB[index] = Float.random(in: -1000000.0...1000000.0)
        }
    }
    
    func sendComputeCommand() {
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            logger.error("Failed to make command buffer.")
            return
        }
        guard let commandEncode = commandBuffer.makeComputeCommandEncoder() else {
            logger.error("Failed to make compute command encoder.")
            return
        }
        
        commandEncode.setComputePipelineState(addFunctionPSO)
        commandEncode.setBuffer(bufferA, offset: 0, index: 0)
        commandEncode.setBuffer(bufferB, offset: 0, index: 1)
        commandEncode.setBuffer(bufferResult, offset: 0, index: 2)
        
        let gridSize = MTLSizeMake(arrayLength, 1, 1)
        let threadGroupSize = MTLSizeMake(min(addFunctionPSO.maxTotalThreadsPerThreadgroup, arrayLength), 1, 1)
        commandEncode.dispatchThreadgroups(gridSize, threadsPerThreadgroup: threadGroupSize)
        commandEncode.endEncoding()

        logger.debug("gpu compute start.")
        let date = Date()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        // ns
        let timeInterval = Int(Date().timeIntervalSince(date) * 1000 * 1000)
        logger.debug("gpu compute time interval: \(timeInterval) ns")
        verifyResult()
    }
    
    func verifyResult() {
        let pointA = bufferA.contents().bindMemory(to: Float.self, capacity: arrayLength)
        let pointB = bufferB.contents().bindMemory(to: Float.self, capacity: arrayLength)
        let pointResult = bufferResult.contents().bindMemory(to: Float.self, capacity: arrayLength)
        for index in 0..<arrayLength {
            if pointResult[index] != pointA[index] + pointB[index] {
                logger.error("meta compute error: index: \(index):  \(pointA[index]) + \(pointB[index]) == \(pointResult[index])")
                break
            }
        }
    }
    
    func testGPUCompute() {
        createBufferData()
        sendComputeCommand()
    }
    
    func testCPUCompute() {
        autoreleasepool {
            var array1: [Float] = Array(repeating: 0, count: arrayLength);
            var array2: [Float] = Array(repeating: 0, count: arrayLength);
            var array3: [Float] = Array(repeating: 0, count: arrayLength);
            for index in 0..<arrayLength {
                array1[index] = Float.random(in: -1000000.0...1000000.0)
                array2[index] = Float.random(in: -1000000.0...1000000.0)
            }
            logger.debug("cpu compute start.")
            let date = Date()
            for index in 0..<arrayLength {
                array3[index] = array1[index] + array2[index]
            }
            // ns
            let timeInterval = Int(Date().timeIntervalSince(date) * 1000 * 1000)
            logger.debug("cpu compute time interval: \(timeInterval) ns")
        }
    }
}
