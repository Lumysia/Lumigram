import Foundation

// Known (user id, registration time) pairs from the GetIDs bot,
// https://github.com/wjclub/telegram-bot-getids (src/ages.json).
// Copyright (c) 2019 Jonas Zohren, MIT License.
private let anchors: [(id: Int64, time: Int64)] = [
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
    (8235679900, 1758758400),
]

/// When an account was probably registered, estimated on the device by
/// interpolating between known ids. User ids grow with time, so this is good to
/// a few months; nothing is looked up anywhere.
func lumigramEstimatedRegistrationDate(userId: Int64) -> Date? {
    guard let first = anchors.first, let last = anchors.last, userId > 0 else {
        return nil
    }
    let time: Double
    if userId <= first.id {
        time = Double(first.time)
    } else if let upper = anchors.firstIndex(where: { $0.id >= userId }) {
        let a = anchors[upper - 1], b = anchors[upper]
        time = Double(a.time) + Double(b.time - a.time) * Double(userId - a.id) / Double(b.id - a.id)
    } else {
        let a = anchors[anchors.count - 2]
        let slope = Double(last.time - a.time) / Double(last.id - a.id)
        time = min(Double(last.time) + slope * Double(userId - last.id), Date().timeIntervalSince1970)
    }
    return Date(timeIntervalSince1970: time)
}
