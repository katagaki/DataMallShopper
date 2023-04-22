//
//  APIFetchers.swift
//  Buses
//
//  Created by 堅書 on 2022/04/14.
//

import Foundation

// API code from https://github.com/katagaki/Tsugi2
// API code here will not be updated unless an Issue is opened

let apiEndpoint = "http://datamall2.mytransport.sg/ltaodataservice"

func fetchAllBusStops() async throws -> [BusStop] {
    var allBusStops: [BusStop] = []
    var currentBusStopList: BusStopList?
    var currentSkipIndex: Int = 0
    repeat {
        currentBusStopList = try await fetchBusStops(from: currentSkipIndex)
        if let busStopList = currentBusStopList {
            allBusStops.append(contentsOf: busStopList.busStops)
            currentSkipIndex += 500
        } else {
            currentBusStopList = BusStopList()
        }
    } while currentBusStopList?.busStops.count != 0
    return allBusStops
}

func fetchBusStops(from firstIndex: Int = 0) async throws -> BusStopList {
    let busStopList: BusStopList = try await withCheckedThrowingContinuation({ continuation in
        var request = URLRequest(url: URL(string: "\(apiEndpoint)/BusStops?$skip=\(firstIndex)")!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if let apiKey = apiKeys["LTA"] {
            request.addValue(apiKey, forHTTPHeaderField: "AccountKey")
        } else {
            print("API key is missing! Request may fail ungracefully.")
        }
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print(error.localizedDescription)
                print(String(data: data ?? Data(), encoding: .utf8) ?? "No data found.")
                continuation.resume(throwing: error)
            } else {
                if let data = data {
                    if let busStopList: BusStopList = decode(fromData: data) {
                        print("Fetched bus stop data from the API for skip index \(firstIndex).")
                        continuation.resume(returning: busStopList)
                    } else {
                        print("Could not decode the data successfully.")
                        continuation.resume(throwing: NSError(domain: "", code: 1))
                    }
                } else {
                    print("No data was returned.")
                    continuation.resume(throwing: NSError(domain: "", code: 1))
                }
            }
        }.resume()
    })
    return busStopList
}

func fetchBusArrivals(for stopCode: String) async throws -> BusStop {
    let busArrivals: BusStop = try await withCheckedThrowingContinuation({ continuation in
        var request = URLRequest(url: URL(string: "\(apiEndpoint)/BusArrivalv2?BusStopCode=\(stopCode)")!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if let apiKey = apiKeys["LTA"] {
            request.addValue(apiKey, forHTTPHeaderField: "AccountKey")
        } else {
            print("API key is missing! Request may fail ungracefully.")
        }
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print(error.localizedDescription)
                print(String(data: data ?? Data(), encoding: .utf8) ?? "No data found.")
                continuation.resume(throwing: error)
            } else {
                if let data = data {
                    if let busArrivals: BusStop = decode(fromData: data) {
                        print("Fetched bus arrival data for \(stopCode) from the API.")
                        continuation.resume(returning: busArrivals)
                    } else {
                        print("Could not decode the data successfully.")
                        continuation.resume(throwing: NSError(domain: "", code: 1))
                    }
                } else {
                    print("No data was returned.")
                    continuation.resume(throwing: NSError(domain: "", code: 1))
                }
            }
        }.resume()
    })
    return busArrivals
}

func fetchAllBusRoutes() async throws -> BusRouteList {
    return try await withThrowingTaskGroup(of: BusRouteList.self, body: { group in
        let finalBusRouteList = BusRouteList()
        for index in 0...60 {
            group.addTask {
                let busRouteList = try await fetchBusRoutes(from: index * 500)
                return busRouteList
            }
        }
        let finalBusRoutePoints: [BusRoutePoint] = try await group.reduce(
            into: [BusRoutePoint](), { partialResult, busRouteList in
            partialResult.append(contentsOf: busRouteList.busRoutePoints)
        })
        finalBusRouteList.metadata = "processed.by.tsugi"
        finalBusRouteList.busRoutePoints = finalBusRoutePoints
        return finalBusRouteList
    })
}

func fetchBusRoutes(from firstIndex: Int = 0) async throws -> BusRouteList {
    let busRouteList: BusRouteList = try await withCheckedThrowingContinuation({ continuation in
        var request = URLRequest(url: URL(string: "\(apiEndpoint)/BusRoutes?$skip=\(firstIndex)")!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if let apiKey = apiKeys["LTA"] {
            request.addValue(apiKey, forHTTPHeaderField: "AccountKey")
        } else {
            print("API key is missing! Request may fail ungracefully.")
        }
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print(error.localizedDescription)
                print(String(data: data ?? Data(), encoding: .utf8) ?? "No data found.")
                continuation.resume(throwing: error)
            } else {
                if let data = data {
                    if let busRouteList: BusRouteList = decode(fromData: data) {
                        print("Fetched bus route data from the API for skip index \(firstIndex).")
                        continuation.resume(returning: busRouteList)
                    } else {
                        print("Could not decode the data successfully.")
                        continuation.resume(throwing: NSError(domain: "", code: 1))
                    }
                } else {
                    print("No data was returned.")
                    continuation.resume(throwing: NSError(domain: "", code: 1))
                }
            }
        }.resume()
    })
    return busRouteList
}
