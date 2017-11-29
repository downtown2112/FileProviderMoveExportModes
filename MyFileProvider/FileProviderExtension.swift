//
//  FileProviderExtension.swift
//  MyFileProvider
//
//  Created by fred.a.brown on 11/28/17.
//  Copyright © 2017 Zebrasense. All rights reserved.
//

import FileProvider

class FileProviderExtension: NSFileProviderExtension {
    
    var fileManager = FileManager()
    
    override init() {
        super.init()
    }
    
    // Original code returned NSFileProviderItem? instead of NSFileProviderItem - template
    //   code fixed in XCode
    override func item(for identifier: NSFileProviderItemIdentifier) throws -> NSFileProviderItem {

        /******************************************************************
         In "real" code, this would resolve to a record in our model.
         However, for demonstration purposes, I'm just recreating the
         FileProviderItems here.
 
         The key to enabling our file provider as a destination for a move
         or export appears to be to make sure that our rootContainer is
         itself represented as a FileProviderItem with appropriate
         capabilities.
 
         Updating project with a new video to show how this can be verified
         *******************************************************************/
        
        // setting parentIdentifier here to identifier - just because I didn't
        //   want to take the time to rework the interface to support optional
        //   values. In a "real" provider, this would be done completely differently
        //   anyway.
        if identifier == NSFileProviderItemIdentifier.rootContainer {
            return FileProviderItem(itemIdentifier: identifier,
                                    parentIdentifier: identifier,
                                    filename: "Root",
                                    typeIdentifier: "public.folder")
            
        } else {
            
            var fileName:String? = nil
            var typeIdentifier:String? = nil
                
            if identifier.rawValue == "item1" {
                fileName = "File 1"
                typeIdentifier = "public.text"
            } else if identifier.rawValue == "item2" {
                fileName = "File 2"
                typeIdentifier = "public.text"
            } else {
                fileName = "Folder 1"
                typeIdentifier = "public.folder"
            }
 
            return FileProviderItem(itemIdentifier: identifier,
                                    parentIdentifier: NSFileProviderItemIdentifier.rootContainer,
                                    filename: fileName!,
                                    typeIdentifier: typeIdentifier!)
          
        }

    }
    
    override func urlForItem(withPersistentIdentifier identifier: NSFileProviderItemIdentifier) -> URL? {
        // resolve the given identifier to a file on disk
    
        guard let item = try? self.item(for: identifier) else {
            return nil
        }
        
        // in this implementation, all paths are structured as <base storage directory>/<item identifier>/<item file name>
        let manager = NSFileProviderManager.default
        let perItemDirectory = manager.documentStorageURL.appendingPathComponent(identifier.rawValue, isDirectory: true)
        
        return perItemDirectory.appendingPathComponent(item.filename, isDirectory:false)
    }
    
    override func persistentIdentifierForItem(at url: URL) -> NSFileProviderItemIdentifier? {
        // resolve the given URL to a persistent identifier using a database
        let pathComponents = url.pathComponents
        
        // exploit the fact that the path structure has been defined as
        // <base storage directory>/<item identifier>/<item file name> above
        assert(pathComponents.count > 2)
        
        return NSFileProviderItemIdentifier(pathComponents[pathComponents.count - 2])
    }
    
    override func startProvidingItem(at url: URL, completionHandler: ((_ error: Error?) -> Void)?) {
        // Should ensure that the actual file is in the position returned by URLForItemWithIdentifier:, then call the completion handler
        
        /* TODO:
         This is one of the main entry points of the file provider. We need to check whether the file already exists on disk,
         whether we know of a more recent version of the file, and implement a policy for these cases. Pseudocode:
         
         if !fileOnDisk {
             downloadRemoteFile()
             callCompletion(downloadErrorOrNil)
         } else if fileIsCurrent {
             callCompletion(nil)
         } else {
             if localFileHasChanges {
                 // in this case, a version of the file is on disk, but we know of a more recent version
                 // we need to implement a strategy to resolve this conflict
                 moveLocalFileAside()
                 scheduleUploadOfLocalFile()
                 downloadRemoteFile()
                 callCompletion(downloadErrorOrNil)
             } else {
                 downloadRemoteFile()
                 callCompletion(downloadErrorOrNil)
             }
         }
         */
        
        completionHandler?(NSError(domain: NSCocoaErrorDomain, code: NSFeatureUnsupportedError, userInfo:[:]))
    }
    
    
    override func itemChanged(at url: URL) {
        // Called at some point after the file has changed; the provider may then trigger an upload
        
        /* TODO:
         - mark file at <url> as needing an update in the model
         - if there are existing NSURLSessionTasks uploading this file, cancel them
         - create a fresh background NSURLSessionTask and schedule it to upload the current modifications
         - register the NSURLSessionTask with NSFileProviderManager to provide progress updates
         */
    }
    
    override func stopProvidingItem(at url: URL) {
        // Called after the last claim to the file has been released. At this point, it is safe for the file provider to remove the content file.
        // Care should be taken that the corresponding placeholder file stays behind after the content file has been deleted.
        
        // Called after the last claim to the file has been released. At this point, it is safe for the file provider to remove the content file.
        
        // TODO: look up whether the file has local changes
        let fileHasLocalChanges = false
        
        if !fileHasLocalChanges {
            // remove the existing file to free up space
            do {
                _ = try FileManager.default.removeItem(at: url)
            } catch {
                // Handle error
            }
            
            // write out a placeholder to facilitate future property lookups
            self.providePlaceholder(at: url, completionHandler: { error in
                // TODO: handle any error, do any necessary cleanup
            })
        }
    }
    
    // MARK: - Actions
    
    /* TODO: implement the actions for items here
     each of the actions follows the same pattern:
     - make a note of the change in the local model
     - schedule a server request as a background task to inform the server of the change
     - call the completion block with the modified item in its post-modification state
     */
    
    // MARK: - Enumeration
    
    override func enumerator(for containerItemIdentifier: NSFileProviderItemIdentifier) throws -> NSFileProviderEnumerator {
        
        let maybeEnumerator: NSFileProviderEnumerator?
        if (containerItemIdentifier == NSFileProviderItemIdentifier.rootContainer) {
            maybeEnumerator = FileProviderEnumerator(enumeratedItemIdentifier: containerItemIdentifier)
        } else if (containerItemIdentifier == NSFileProviderItemIdentifier.workingSet) {
            maybeEnumerator = FileProviderEnumerator(enumeratedItemIdentifier: containerItemIdentifier)
            // TODO: instantiate an enumerator for the working set
        } else {
            // TODO: determine if the item is a directory or a file
            // - for a directory, instantiate an enumerator of its subitems
            // - for a file, instantiate an enumerator that observes changes to the file
            maybeEnumerator = FileProviderEnumerator(enumeratedItemIdentifier: containerItemIdentifier)
        }
        guard let enumerator = maybeEnumerator else {
            throw NSError(domain: NSCocoaErrorDomain, code: NSFeatureUnsupportedError, userInfo:[:])
        }
        return enumerator
    
    }
    
}
