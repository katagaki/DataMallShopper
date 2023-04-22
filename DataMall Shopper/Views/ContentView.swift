//
//  ContentView.swift
//  DataMall Shopper
//
//  Created by 堅書 on 2023/04/22.
//

import AppKit
import SwiftUI

struct ContentView: View {

    @State var busStopList: BusStopList = BusStopList()
    @State var busRouteList: BusRouteList = BusRouteList()

    var body: some View {
        TabView {
            BusStopsView(busStopList: $busStopList)
                .tabItem {
                    Text("Bus Stops")
                }
            BusRoutesView(busRouteList: $busRouteList)
                .tabItem {
                    Text("Bus Routes")
                }
            CoordinatesView(busStopList: $busStopList)
                .tabItem {
                    Text("Coordinates")
                }
            PolylinesView()
                .tabItem {
                    Text("Polylines")
                }
        }
        .padding()
    }

}
