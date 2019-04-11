//
//  ItemList.swift
//  BDD_Project
//
//  Created by lpiem on 11/04/2019.
//  Copyright © 2019 lpiem. All rights reserved.
//

import Foundation

extension ItemList{
    func toDictionary() -> [String: Any] {
        return ["title": title ?? "",
                "description": descriptions ?? "",
                "category": category ?? "Category",
                "image": image?.base64EncodedString() ?? "",
                "creationDate": creationDate?.timeIntervalSince1970 ?? "",
                "modificationDate": modificationDate?.timeIntervalSince1970 ?? "",
                "checked": checked]
    }
}
