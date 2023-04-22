//
//  CoordinatesView.swift
//  DataMall Shopper
//
//  Created by 堅書 on 2023/04/22.
//

import SwiftUI

struct CoordinatesView: View {

    @Binding var busStopList: BusStopList

    @State var busStopCodeList: String = ""
    @State var coordinateList: String = ""

    var body: some View {
        VStack {
            Text("List of Bus Stop Codes:")
            TextEditor(text: $busStopCodeList)
            Button {
                coordinateList = ""
                let busStopCodes = busStopCodeList.components(separatedBy: .newlines)
                for busStopCode in busStopCodes {
                    if let busStop = busStopList.busStops.first(where: { busStop in
                        busStop.code == busStopCode
                    }),
                       let latitude = busStop.latitude,
                       let longitude = busStop.longitude {
                        coordinateList += "\(latitude),\(longitude)\n"
                    } else {
                        coordinateList += "<no latitude/longitude>\n"
                    }
                }
            } label: {
                Text("Convert to Coordinates")
            }
            Text("List of Coordinates:")
            TextEditor(text: $coordinateList)
            Spacer()
        }
        .padding()
    }
}
