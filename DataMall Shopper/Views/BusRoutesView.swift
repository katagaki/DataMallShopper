//
//  BusRoutesView.swift
//  DataMall Shopper
//
//  Created by 堅書 on 2023/04/22.
//

import SwiftUI

struct BusRoutesView: View {

    @Binding var busRouteList: BusRouteList

    @State var busRouteSearchService: String = ""
    @State var busRouteSearchDirection: Int = 1

    var body: some View {
        VSplitView {
            HStack {
                TextField("Bus Service Name", text: $busRouteSearchService)
                Text("Direction:")
                TextField("Direction", value: $busRouteSearchDirection, formatter: NumberFormatter())
                    .frame(width: 50)
                Stepper(value: $busRouteSearchDirection, in: 1...2) {
                    EmptyView()
                }
                Button {
                    let busRouteListFiltered = busRouteList.busRoutePoints.filter({ busRoutePoint in
                        busRoutePoint.serviceNo == busRouteSearchService &&
                        busRoutePoint.direction.rawValue == busRouteSearchDirection
                    }).sorted(by: { lhs, rhs in
                        lhs.stopSequence < rhs.stopSequence
                    })
                    var busStopCodeList: String = ""
                    for busRoutePoint in busRouteListFiltered {
                        busStopCodeList += "\(busRoutePoint.stopCode)\n"
                    }
                    busStopCodeList = busStopCodeList.trimmingCharacters(in: .whitespacesAndNewlines)
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(busStopCodeList, forType: .string)
                } label: {
                    Text("Copy List of Bus Stops")
                }
            }
            .padding()
            NavigationView {
                List(busRouteList.busRoutePoints, id: \.id) { busRoutePoint in
                    NavigationLink {
                        VStack(alignment: .leading) {
                            HStack {
                                TextField("Bus Service No", text: .constant(busRoutePoint.serviceNo))
                                TextField("Bus Stop Code", text: .constant(busRoutePoint.stopCode))
                                TextField("Bus Stop Sequence", text: .constant(String(busRoutePoint.stopSequence)))
                            }
                            Divider()
                            Text("Distance:")
                            TextField("Distance", text: .constant(String(busRoutePoint.distance)))
                            Text("Direction:")
                            TextField("Direction", text: .constant(String(busRoutePoint.direction.rawValue)))
                            Spacer()
                        }
                        .padding()
                    } label: {
                        HStack {
                            Text(String(busRoutePoint.stopSequence))
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(busRoutePoint.serviceNo)
                        }
                    }
                }
                .task {
                    if busRouteList.busRoutePoints.count == 0 {
                        do {
                            loadAPIKeys()
                            let newBusRouteList = BusRouteList()
                            newBusRouteList.busRoutePoints = (try await fetchAllBusRoutes()).busRoutePoints
                                .sorted(by: { lhs, rhs in
                                    lhs.stopSequence < rhs.stopSequence
                                })
                                .sorted(by: { lhs, rhs in
                                    lhs.direction.rawValue < rhs.direction.rawValue
                                })
                                .sorted(by: { lhs, rhs in
                                    lhs.serviceNo < rhs.serviceNo
                                })
                            busRouteList = newBusRouteList
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
            .padding()
        }
    }
}
