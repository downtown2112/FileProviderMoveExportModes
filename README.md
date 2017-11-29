# Issue Enabling MoveToService and ExportToService in iOS11 File Provider

# Description - (Update: Partially Resolved - see comments at end)
In iOS10, I have an application that contains both a document provider and file provider.  My document provider supports all 4 UIDocumentPicker modes....open, import, move and export.

For iOS11, I want to replicate the same functionality - supporting all four modes - without the use of a document provider at all.  (Side note - iOS10-based document providers do not even show up in the standard UI when performing a .moveToService or .exportToService.)

This project represents a dummy project which illustrates my primary issue - I cannot determine how to enable "moveToService" and "exportToService" modes of my new file provider.



# Steps to Reproduce
You will need an application which will create and present a UIDocumentPickerViewController similar to following.  (.exportToService is shown, but the same issue exists for .moveToService)

```
let picker = UIDocumentPickerViewController.init(urls: [<some url>], in: .exportToService)
picker.delegate = self
picker.modalPresentationStyle = .formSheet

self.present(picker, animated: true, completion: nil)
```

The standard iOS11 UI displays, showing iOS 11 file providers.
iCloud appears and is enabled.
My new file provider shows in this list but is disabled.


# Questions

1) In iOS 11 (as in this project), I will have no document provider.  How do I get my file provider to be enabled for selection in .moveToService and .exportToService use cases?

2) In iOS 10, my document provider defined supported modes and file types with the following information in its info.plist.  Where/how do I specify similar attributes in my iOS11 file provider?

```
<key>NSExtension</key>
<dict>
    <key>NSExtensionAttributes</key>
    <dict>
       <key>UIDocumentPickerModes</key>
       <array>
           <string>UIDocumentPickerModeImport</string>
           <string>UIDocumentPickerModeOpen</string>
           <string>UIDocumentPickerModeExportToService</string>
           <string>UIDocumentPickerModeMoveToService</string>
      </array>
      <key>UIDocumentPickerSupportedFileTypes</key>
      <array>
           <string>public.content</string>
      </array>
    </dict>
    <key>NSExtensionMainStoryboard</key>
    <string>MainInterface</string>
    <key>NSExtensionPointIdentifier</key>
    <string>com.apple.fileprovider-ui</string>
</dict>
```

# Resolution

The root container must itself be represented as a FileProviderItem in order to support move/export.  Since it is a FileProviderItem, it contains capabilities that can be programmatically set to either allow or disallow its use as a destination for a move/export/copy.

See SampleVideo-ResolvedIssue.mov for a demonstration of the new code
See comments in FileProviderExtension.swift for more details



