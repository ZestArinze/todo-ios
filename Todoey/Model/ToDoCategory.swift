//
//  ToDoCategory.swift
//  Todoey
//
//  Created by Arinze Anakor on 29/06/2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class ToDoCategory: Object {
    @objc dynamic var name: String = ""
    var toDoItems = List<ToDo>()
}
