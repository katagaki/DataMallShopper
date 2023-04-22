//
//  PolylinesView.swift
//  DataMall Shopper
//
//  Created by 堅書 on 2023/04/22.
//

import CoreLocation
import SwiftUI

struct PolylinesView: View {

    @State var coordinateList: String = ""
    @State var encodedPolylineList: String = ""

    var body: some View {
        VStack {
            Text("List of Coordinates:")
            TextEditor(text: $coordinateList)
            Button {
                var previousCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
                var coordinates: [CLLocationCoordinate2D] = []
                for coordinatesString in coordinateList.components(separatedBy: .newlines) {
                    let latLongSplit = coordinatesString.components(separatedBy: .init(charactersIn: ","))
                    if latLongSplit.count == 2,
                       let latitude = Double(latLongSplit[0]), let longitude = Double(latLongSplit[1]) {
                        let differenceInLatitude = roundToFive(latitude) - roundToFive(previousCoordinate.latitude)
                        let differenceInLongitude = roundToFive(longitude) - roundToFive(previousCoordinate.longitude)
                        let newCoordinate = CLLocationCoordinate2D(latitude: differenceInLatitude,
                                                                   longitude: differenceInLongitude)
                        coordinates.append(newCoordinate)
                        previousCoordinate = CLLocationCoordinate2D(latitude: latitude,
                                                                    longitude: longitude)
                        print("\(newCoordinate.latitude), \(newCoordinate.longitude)")
                    }
                }
                encodedPolylineList = "Encoded Polyline\n\n"
                for coordinate in coordinates {
                    encodedPolylineList.append("\(encode(coordinate))")
                }
                encodedPolylineList.append("\n\nEncoded Levels (for use on" +
                    "https://developers.google.com/maps/documentation/utilities/polylineutility)\n\n")
                for _ in coordinates {
                    encodedPolylineList.append("B")
                }
            } label: {
                Text("Encode to Polylines")
            }
            Text("Encoded Polylines:")
            TextEditor(text: $encodedPolylineList)
            Spacer()
        }
        .padding()
    }

}
