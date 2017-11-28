//
//  FileProviderItem.swift
//  MyFileProvider
//
//  Created by fred.a.brown on 11/28/17.
//  Copyright © 2017 Zebrasense. All rights reserved.
//

import FileProvider

class FileProviderItem: NSObject, NSFileProviderItem {

    // TODO: implement an initializer to create an item from your extension's backing model
    // TODO: implement the accessors to return the values from your extension's backing model
    
    // This file provider item implementation code copied from project created by Alexander Tkachenko on 11/16/17.
    //  Copyright © 2017 Alexander Tkachenko. All rights reserved.
    
    let identifier: NSFileProviderItemIdentifier
    let parent: NSFileProviderItemIdentifier
    let name: String
    let type: String
    
    
    init(itemIdentifier: NSFileProviderItemIdentifier, parentIdentifier: NSFileProviderItemIdentifier, filename: String, typeIdentifier: String) {
        identifier = itemIdentifier
        parent = parentIdentifier
        name = filename
        type = typeIdentifier
        super.init()
    }
    
    var itemIdentifier: NSFileProviderItemIdentifier {
        return identifier
    }
    
    var parentItemIdentifier: NSFileProviderItemIdentifier {
        return parent
    }
    
    var capabilities: NSFileProviderItemCapabilities {
        return .allowsAll
    }
    
    var filename: String {
        return name
    }
    
    var typeIdentifier: String {
        return type
    }
    
}
