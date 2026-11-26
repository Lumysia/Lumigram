import Foundation
import SwiftSignalKit

import SGRegDateScheme
import AccountContext
import SGSimpleSettings

// Known (user id, registration time) pairs from the GetIDs bot,
// https://github.com/wjclub/telegram-bot-getids (src/ages.json).
// Copyright (c) 2019 Jonas Zohren, MIT License.
private let registrationAnchors: [(id: Int64, timestamp: Int64)] = [
    (2768409, 1383264000),
    (7679610, 1388448000),
    (11538514, 1391212000),
    (15835244, 1392940000),
    (23646077, 1393459000),
    (38015510, 1393632000),
    (44634663, 1399334000),
    (46145305, 1400198000),
    (54845238, 1411257000),
    (63263518, 1414454000),
    (101260938, 1425600000),
    (101323197, 1426204000),
    (103151531, 1433376000),
    (103258382, 1432771000),
    (109393468, 1439078000),
    (111220210, 1429574000),
    (112594714, 1439683000),
    (116812045, 1437696000),
    (122600695, 1437782000),
    (124872445, 1439856000),
    (125828524, 1444003000),
    (130029930, 1441324000),
    (133909606, 1444176000),
    (143445125, 1448928000),
    (148670295, 1452211000),
    (152079341, 1453420000),
    (157242073, 1446768000),
    (171295414, 1457481000),
    (181783990, 1460246000),
    (222021233, 1465344000),
    (225034354, 1466208000),
    (278941742, 1473465000),
    (285253072, 1476835000),
    (294851037, 1479600000),
    (297621225, 1481846000),
    (328594461, 1482969000),
    (337808429, 1487707000),
    (341546272, 1487782000),
    (352940995, 1487894000),
    (369669043, 1490918000),
    (400169472, 1501459000),
    (805158066, 1563208000),
    (1974255900, 1634000000),
    (5795034000, 1662076800),
    (6227468000, 1679270400),
    (7583599300, 1739664000),
    (7947063900, 1754092800),
    (8235679900, 1758758400)
]

func estimatedRegistrationTimestamp(userId: Int64, now: Int64) -> Int64? {
    guard userId > 0, let first = registrationAnchors.first else {
        return nil
    }
    if userId <= first.id {
        return first.timestamp
    }
    var lower = first
    for upper in registrationAnchors.dropFirst() {
        if userId <= upper.id {
            return interpolate(userId, lower, upper)
        }
        lower = upper
    }
    let previous = registrationAnchors[registrationAnchors.count - 2]
    return min(interpolate(userId, previous, lower), now)
}

private func interpolate(_ id: Int64, _ a: (id: Int64, timestamp: Int64), _ b: (id: Int64, timestamp: Int64)) -> Int64 {
    let ratio = Double(id - a.id) / Double(b.id - a.id)
    return a.timestamp + Int64(ratio * Double(b.timestamp - a.timestamp))
}

public func getRegDate(context: AccountContext, peerId: Int64) -> Signal<RegDate?, NoError> {
    guard SGSimpleSettings.shared.showRegDate, let timestamp = estimatedRegistrationTimestamp(userId: peerId, now: Int64(Date().timeIntervalSince1970)) else {
        return .single(nil)
    }
    return .single(RegDate(from: timestamp, to: timestamp, validUntil: 0))
}
