//
//  CatalogListViewModel.swift
//  MasterCoredata
//
//  Created by Hosamane, Vinay K N on 11/05/21.
//

import Foundation

enum RowType {
    case A
    case B
}

struct SectionModel: Hashable, Equatable {
    var title: String
    var rows: [RowModel]
    
    let uniqueId = UUID()
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(uniqueId)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.uniqueId == rhs.uniqueId
    }
}

struct RowModel: Hashable {
    var name: String
    var detail: String
    var type: RowType
}

class CatalogCardsViewModel {
    var cards = [SectionModel]()
    
    init() {
        buildCatalogCards()
    }
    
    private func buildCatalogCards() {
        let friendsSectionModel = SectionModel(title: "Friends", rows: [
            RowModel(name: "Vinay Hosamane", detail: "vinayhosamane07@gmail.com", type: .A),
            RowModel(name: "Sandy", detail: "sandy@gmail.com", type: .A),
            RowModel(name: "Varun Gupta", detail: "varun.gupta@gmail.com", type: .A)
        ])
        
        let familySectionModel = SectionModel(title: "Family", rows: [
            RowModel(name: "Rashmi Hosamane", detail: "xxx@gmail.com", type: .B),
            RowModel(name: "Pallavi K N", detail: "xxx@gmail.com", type: .B),
            RowModel(name: "Chandana Hosamane", detail: "xxx@gmail.com", type: .B),
            RowModel(name: "Renuka G R", detail: "xxx@gmail.com", type: .B),
            RowModel(name: "Nijaguna K M", detail: "xxx@gmail.com", type: .B),
            RowModel(name: "Keerthana Basavaraj", detail: "xxx@gmail.com", type: .B)
        ])
        
        let colleagueSectionModel = SectionModel(title: "Co-Worker", rows:
                                                    [RowModel(name: "Nitin", detail: "xxx@gmail.com", type: .A),
                                                     RowModel(name: "Prashanth", detail: "xxx@gmail.com", type: .A),
                                                     RowModel(name: "Ramya B U", detail: "xxx@gmail.com", type: .A),
                                                     RowModel(name: "Sindhuja", detail: "xxx@gmail.com", type: .A),
                                                     RowModel(name: "Reshma", detail: "xxx@gmail.com", type: .A),
                                                     RowModel(name: "Apoorv", detail: "xxx@gmail.com", type: .A)])
        
        cards = [friendsSectionModel, familySectionModel, colleagueSectionModel]
    }
}
