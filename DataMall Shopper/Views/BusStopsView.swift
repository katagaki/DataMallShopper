//
//  BusStopsView.swift
//  DataMall Shopper
//
//  Created by 堅書 on 2023/04/22.
//

import SwiftUI

struct BusStopsView: View {

    @Binding var busStopList: BusStopList

    var body: some View {
        NavigationView {
            List(busStopList.busStops, id: \.id) { busStop in
                NavigationLink {
                    VStack(alignment: .leading) {
                        HStack {
                            TextField("Bus Stop Name", text: .constant(busStop.name()))
                            TextField("Road Name", text: .constant(busStop.roadName ?? "No Road Name"))
                            TextField("Bus Stop Code", text: .constant(busStop.code))
                        }
                        Divider()
                        Text("Latitude:")
                        TextField("Latitude", text: .constant(String(busStop.latitude ?? 0)))
                        Text("Longitude:")
                        TextField("Longitude", text: .constant(String(busStop.longitude ?? 0)))
                        Spacer()
                    }
                    .padding()
                } label: {
                    Text(busStop.name())
                }
            }
            .task {
                if busStopList.busStops.count == 0 {
                    do {
                        loadAPIKeys()
                        let newBusStopList = BusStopList()
                        newBusStopList.busStops = try await fetchAllBusStops()
                        newBusStopList.busStops.sort(by: { lhs, rhs in
                            lhs.description?.lowercased() ?? "" < rhs.description?.lowercased() ?? ""
                        })
                        busStopList = newBusStopList
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
}
