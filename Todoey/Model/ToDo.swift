//
//  ToDoItem.swift
//  Todoey
//
//  Created by Arinze Anakor on 29/06/2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class ToDo: Object {
    
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    var todoCategory = LinkingObjects(fromType: ToDoCategory.self, property: "toDoItems")
}
